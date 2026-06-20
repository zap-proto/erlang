%%
%%  Copyright 2014, Andreas Stenius <kaos@astekk.se>
%%
%%   Licensed under the Apache License, Version 2.0 (the "License");
%%   you may not use this file except in compliance with the License.
%%   You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%%   Unless required by applicable law or agreed to in writing, software
%%   distributed under the License is distributed on an "AS IS" BASIS,
%%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%   See the License for the specific language governing permissions and
%%   limitations under the License.
%%

%% @copyright 2014, Andreas Stenius
%% @author Andreas Stenius <kaos@astekk.se>
%% @doc VAT server module.
%%
%% One VAT server per connection.

-module(ezap_vat).
-author("Andreas Stenius <kaos@astekk.se>").
-behaviour(gen_server).

%% API
-export([start/0, start_link/0, start_link/1, start_link/2, stop/1,
         send/2, import_capability/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%%-define(EZAP_DEBUG,1). %% un-comment to enable debug messages, or
%%-define(EZAP_TRACE,1). %% un-comment to enable debug messages and trace the gen_server

-include("ezap.hrl").

-record(id_queue, {
          next_id = queue:new(),
          values = []
         }).

-record(state, {
          owner,
          transport,
          restorer,
          questions = #id_queue{},
          exports = #id_queue{},
          answers = [],
          imports = [],
          cont_data = <<>>
         }).


%% ===================================================================
%% API functions
%% ===================================================================

start() ->
    gen_server:start(?MODULE, setup_state(), ?EZAP_GEN_OPTS).

start_link() ->
    gen_server:start_link(?MODULE, setup_state(), ?EZAP_GEN_OPTS).

start_link(Transport) ->
    gen_server:start_link(?MODULE, setup_state(Transport), ?EZAP_GEN_OPTS).

start_link(Transport, Restorer) ->
    gen_server:start_link(?MODULE, setup_state(Transport, Restorer), ?EZAP_GEN_OPTS).

stop(Vat) when is_pid(Vat) ->
    gen_server:call(Vat, stop).

send(Vat, Req) when is_pid(Vat) ->
    {ok, Promise} = ezap_promise_sup:start_promise(),
    ok = gen_server:cast(Vat, {send_req, Promise, Req}),
    Promise.

import_capability(Vat, ObjectId) when is_pid(Vat) ->
    {ok, Promise} = ezap_promise_sup:start_promise(),
    ok = gen_server:cast(Vat, {import_req, Promise, ObjectId}),
    Promise.


%% ===================================================================
%% gen server callbacks
%% ===================================================================

init(State) ->
    {ok, State}.

handle_call(stop, _From, State) ->
    {stop, normal, ok, State}.

handle_cast({send_req, Promise, Req}, State) ->
    {noreply, send_req(Promise, Req, State)};
handle_cast({import_req, Promise, ObjectId}, State) ->
    {noreply, import_req(Promise, ObjectId, State)};
handle_cast({stop, Reason}, State) ->
    {stop, Reason, State};
handle_cast(_Cast, State) ->
    {noreply, State}.

handle_info({receive_data, Data}, State) ->
    handle_data(Data, State);
handle_info({{answer, Message}, {ok, _Result}}, State) ->
    {noreply, send_message(Message, process_outgoing_message(Message, State))};
%% handle_info({'DOWN', MonRef, process, _Pid, _Info}, State) ->
%%     purge_ref(MonRef, State);
handle_info(_Info, State) ->
    io:format(
      standard_error, "~p:ezap_vat(~p): unhandled info: ~n   ~p~n",
      [self(), State#state.transport, _Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% ===================================================================
%% internal server functions
%% ===================================================================

%% ===================================================================
send_req(Promise, Req, State) ->
    case Req#rpc_call.target of
        {export, _} ->
            send_local_req(Promise, Req, State);
        {import, _} ->
            send_remote_req(Promise, Req, State);
        {CapPromise, _} when is_pid(CapPromise) ->
            send_remote_req(Promise, Req, State)
    end.

%% -------------------------------------------------------------------
send_remote_req(Promise, Req, State) ->
    {Id, State1} = new_request(Promise, State),
    Call = restore_call(Req#rpc_call.params),
    Target = target_props(Req#rpc_call.target, State),

    ezap:set(
      [{questionId, Id},
       {interfaceId, Req#rpc_call.interface},
       {methodId, Req#rpc_call.method},
       {target, Target}
      ], Call),

    State2 = update_cap_table(ezap:get(params, Call), State1),
    send_message(Call, State2).

%% -------------------------------------------------------------------
send_local_req(Promise, #rpc_call{ target = {export, Id} } = Req, State) ->
    {Id, {_Refs, Cap}} = find_export(Id, 1, State),
    #promise{ pid = InnerPromise } = ezap:send(Req#rpc_call{ target = Cap }),
    ok = ezap_promise:chain(InnerPromise, Promise),
    State.

%% -------------------------------------------------------------------
restore_call(#object{ ref = #ref{ data = Data } }) ->
    %% hackish approach. getting at the root element has not been implemented yet..
    Msg = ezap_obj:from_ref(
            ezap_ref:get(0, 0, Data),
            'Message', rpc_zap),
    {call, Call} = ezap:get(Msg),
    Call.

%% -------------------------------------------------------------------
target_props({import, Id}, _State) -> [{{importedCap, Id}}];
target_props({Promise, Ts}, State) when is_pid(Promise) ->
    {Id, Promise} = find_request(Promise, 2, State),
    [{{promisedAnswer, [{questionId, Id}, {transform, lists:reverse(Ts)}] }}].

%% ===================================================================
import_req(Promise, ObjectId, State) ->
    {Id, State1} = new_request(Promise, State),
    Restore = new_message(restore),
    ok = ezap:set(questionId, Id, Restore),
    ok = ezap:set(objectId, ObjectId, Restore),
    send_message(Restore, State1).

%% ===================================================================
handle_data(<<>>, State) -> {noreply, State};
handle_data(Data, #state{ cont_data = Cont }=State) ->
    case ezap_message:read(Data, Cont) of
        {cont, Cont1} -> {noreply, State#state{ cont_data = Cont1 }};
        {ok, Message, Rest} ->
            {ok, Root} = ezap_get:root(rpc_zap:'Message'(), Message),
            handle_data(
              Rest, handle_message(Root, State#state{ cont_data = <<>> }))
    end.

%% ===================================================================


%% ===================================================================
%% server utils
%% ===================================================================

%% ===================================================================
setup_state() ->
    #state{ owner = self() }.

setup_state(Transport) ->
    (setup_state())#state{ transport = Transport }.

setup_state(Transport, Restorer) ->
    (setup_state(Transport))#state{ restorer = Restorer }.

%% ===================================================================
new_message() ->
    {ok, Msg} = ezap:set_root('Message', rpc_zap), Msg.

%%--------------------------------------------------------------------
new_message(Type) ->
    ezap:init(Type, new_message()).

%% ===================================================================
new_request(Promise, State) ->
    pop_id(Promise, #state.questions, State).

%%--------------------------------------------------------------------
new_export(Cap, State) ->
    ?DBG("<= EXPORT ~p", [Cap]),
    pop_id({1, Cap}, #state.exports, State).

%%--------------------------------------------------------------------
new_answer(Id, Promise, #state{ answers = As } = State) ->
    State#state{ answers = [{Id, Promise}|As] }.

%% ===================================================================
find_request(Key, Idx, #state{ questions = Q }) ->
    lists:keyfind(Key, Idx, Q#id_queue.values).

%%--------------------------------------------------------------------
find_export(Key, Idx, #state{ exports = Q }) ->
    lists:keyfind(Key, Idx, Q#id_queue.values).

%%--------------------------------------------------------------------
find_answer(Id, #state{ answers = As }) ->
    lists:keyfind(Id, 1, As).

%% ===================================================================
ref_export(Id, Count, State) ->
    {Id, {Ref, Cap}} = find_export(Id, 1, State),
    %% ?DBG("++ EXPORT(~p) ~p/~p: ~p", [Id, Count, Ref, Cap]),
    case {Ref, Count} of
        {_, release} ->
            push_id(Id, #state.exports, State);
        {A, B} when A + B =< 0 ->
            push_id(Id, #state.exports, State);
        {A, B} ->
            update_id(Id, {A + B, Cap}, #state.exports, State)
    end.

%% ===================================================================
purge_answer(Id, ReleaseResults, State) ->
    {Id, _Promise} = find_answer(Id, State),
    if ReleaseResults -> todo;
       true -> nop
    end,
    %% ?DBG(" -- ANSWER(~p) ~p", [Id, Promise]),
    %% ok = ezap_promise:stop(Promise),
    State#state{ answers = lists:keydelete(Id, 1, State#state.answers) }.

%% ===================================================================
pop_id(Value, Idx, State) ->
    Ids0 = element(Idx, State),
    {Id, Ids1} = do_pop_id(Value, Ids0),
    {Id, setelement(Idx, State, Ids1)}.

%%--------------------------------------------------------------------
do_pop_id(Value, #id_queue{ next_id = Q0, values = Vs } = Ids) ->
    {Id, Q} =
        case queue:out(Q0) of
            {{value, V}, Q1} -> {V, Q1};
            {empty, Q0} -> {length(Vs), Q0}
        end,

    {Id, Ids#id_queue{ next_id = Q, values = [{Id, Value}|Vs] }}.

%% ===================================================================
push_id(Id, Idx, State) ->
    Ids0 = element(Idx, State),
    Ids1 = do_push_id(Id, Ids0),
    setelement(Idx, State, Ids1).

%%--------------------------------------------------------------------
do_push_id(Id, #id_queue{ next_id = Q, values = Vs } = Ids) ->
    Ids#id_queue{
      next_id = queue:in(Id, Q),
      values = lists:keydelete(Id, 1, Vs)
     }.

%% ===================================================================
update_id(Id, Value, Idx, State) ->
    Ids0 = element(Idx, State),
    Vs = Ids0#id_queue.values,
    Ids1 = Ids0#id_queue{ values = lists:keystore(Id, 1, Vs, {Id, Value}) },
    setelement(Idx, State, Ids1).

%% ===================================================================
send_message(Msg, #state{ transport = {Mod, Handle} }=State) ->
    ?DBG("<< MESSAGE~s", [?DUMP(Msg)]),
    case Mod:send(Handle, ezap_message:write(Msg)) of
        ok -> State;
        Err ->
            gen_server:cast(self(), {stop, Err}),
            State
    end.

%% ===================================================================
process_outgoing_message(Message, State) ->
    case ezap:get(Message) of
        {call, Call} ->
            update_cap_table(ezap:get(params, Call), State);
        {return, Return} ->
            case ezap:get(Return) of
                {results, Payload} ->
                    update_cap_table(Payload, State)
            end;
        _ -> State
    end.

%% ===================================================================
update_cap_table(Payload, State) ->
    {ok, Caps} = ezap_obj:get_cap_table(Payload),
    CapTable = ezap:set(capTable, length(Caps), Payload),
    lists:foldl(
      fun set_cap_descriptor/2,
      State, lists:zip(Caps, CapTable)).

%%--------------------------------------------------------------------
set_cap_descriptor({Cap, CapDesc}, State) ->
    Vat = self(),
    case Cap of
        #interface_ref{ owner = {ezap_capability, _} } ->
            {Id, State1} = new_export(Cap, State),
            ok = ezap:set({senderHosted, Id}, CapDesc),
            State1;
        #interface_ref{ owner = {?MODULE, Vat}, id = {export, Id} } ->
            ok = ezap:set({senderHosted, Id}, CapDesc),
            ref_export(Id, 1, State);
        #interface_ref{ owner = {?MODULE, Vat}, id = {import, Id} } ->
            ok = ezap:set({receiverHosted, Id}, CapDesc),
        %%     State;
        %% #interface_ref{ owner = {?MODULE, Vat}, id = {Promise, Ts} }
        %%   when Pid =:= self() ->
        %%     PromisedAnswer = ezap:init(receiverAnswer, CapDesc),
        %%     set_promised_answer(Id, Ts, PromisedAnswer),
            State
    end.

%% ===================================================================
get_message_target(MessageTarget, State) ->
    case ezap:get(MessageTarget) of
        {importedCap, Id} ->
            #interface_ref{ owner = {?MODULE, self()}, id = {export, Id} };
        {promisedAnswer, PromisedAnswer} ->
            translate_promised_answer(PromisedAnswer, State)
    end.

%% ===================================================================
get_payload_content(Payload, State) ->
    ezap:get(
      content, ezap_obj:set_cap_table(
                 [translate_cap_descriptor(C, State)
                  || C <- ezap:get(capTable, Payload)],
                 Payload)
     ).

%% ===================================================================
translate_cap_descriptor(CapDescriptor, State) ->
    Owner = {?MODULE, self()},
    case ezap:get(CapDescriptor) of
        {none, void} -> undefined;
        {senderHosted, Id} ->
            #interface_ref{ owner = Owner, id = {import, Id} };
        {senderPromise, Id} ->
            #interface_ref{ owner = Owner, id = {resolve, Id} };
        {receiverHosted, Id} ->
            #interface_ref{ owner = Owner, id = {export, Id} };
        {receiverAnswer, PromisedAnswer} ->
            translate_promised_answer(PromisedAnswer, State);
        {thirdPartyHosted, _} -> throw('level 3 stuff, NYI')
    end.

%% ===================================================================
translate_promised_answer(PromisedAnswer, State) ->
    Id = ezap:get(questionId, PromisedAnswer),
    Ts = [ezap:get(T) || T <- ezap:get(transform, PromisedAnswer)],
    {Id, Promise} = find_answer(Id, State),
    #interface_ref{ owner = promise, id = {Promise, Ts} }.

%% ===================================================================
fullfill_request(Id, Result, State) ->
    case find_request(Id, 1, State) of
        false -> State;
        {Id, Promise} ->
            ok = ezap_promise:fullfill(Promise, Result),
            State
    end.

%% ===================================================================

%% ===================================================================
%% Message processing
%% ===================================================================

%% ===================================================================
-spec handle_message(Message::ezap:object(), #state{}) -> #state{}.
handle_message(Message, State) ->
    ?DBG(">> MESSAGE~s", [?DUMP(Message)]),
    {MsgKind, MsgValue} = ezap:get(Message),
    case MsgKind of
        call -> handle_call(MsgValue, State);
        return -> handle_return(MsgValue, State);
        restore -> handle_restore(MsgValue, State);
        finish -> handle_finish(MsgValue, State);
        release -> handle_release(MsgValue, State);
        abort -> handle_abort(MsgValue, State);
        unimplemented -> throw({blarg, unimplemented, MsgValue}); %% TODO
        _ ->
            Reply = new_message(),
            ezap:set({unimplemented, Message}, Reply),
            send_message(Reply, State)
    end.

%% ===================================================================
handle_call(Call, State) ->
    Target = get_message_target(ezap:get(target, Call), State),
    Payload = ezap:get(params, Call),
    Id = ezap:get(questionId, Call),

    Message = new_message(),
    Return = ezap:init(return, Message),
    ok = ezap:set(answerId, Id, Return),
    %% need to set releaseParamsCaps = false here!!
    %% (but will not do until the ref counting issue has been resolved)
    RetPayload = ezap:init(results, Return),

    Req = #rpc_call{
             target = Target,
             interface = ezap:get(interfaceId, Call),
             method = ezap:get(methodId, Call),
             params = get_payload_content(Payload, State),
             results = RetPayload
            },

    #promise{ pid = Promise } = ezap:send(Req),
    ok = ezap_promise:notify(Promise, self(), {answer, Message}),
    new_answer(Id, Promise, State).

%% ===================================================================
handle_return(Return, State) ->
    %% TODO: check if releaseParamCaps == true
    case ezap:get(Return) of
        {results, Results} ->
            Id = ezap:get(answerId, Return),
            Content = get_payload_content(Results, self()),
            fullfill_request(Id, {ok, Content}, State)
    end.

%% ===================================================================
handle_restore(Restore, State) ->
    Vat = self(),
    Id = ezap:get(questionId, Restore),
    Message = new_message(),
    {ok, Promise} = ezap_promise_sup:start_promise(
                      [{fullfiller,
                        fun () ->
                                {ok, Cap} = (State#state.restorer)
                                              (ezap:get(objectId, Restore), Vat),
                                Return = ezap:init(return, Message),
                                ok = ezap:set(answerId, Id, Return),
                                Payload = ezap:init(results, Return),
                                _Content = ezap:set(content, Cap, Payload),
                                {ok, Cap}
                        end}
                      ]),
    ok = ezap_promise:notify(Promise, Vat, {answer, Message}),
    new_answer(Id, Promise, State).

%% ===================================================================
handle_finish(Finish, State) ->
    Id = ezap:get(questionId, Finish),
    Release = ezap:get(releaseResultCaps, Finish),
    purge_answer(Id, Release, State).

%% ===================================================================
handle_release(Release, State) ->
    Id = ezap:get(id, Release),
    Count = ezap:get(referenceCount, Release),
    ref_export(Id, -Count, State).

%% ===================================================================
handle_abort(Exception, State) ->
    error_logger:error_msg(
      "vat(~p) received abort message from peer:~n~s~n",
      [self(), ezap:dump(Exception)]),
    State.

%% ===================================================================
