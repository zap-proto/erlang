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

-module(ezap_rpc_tests).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-include("include/ezap.hrl").

-import(ezap_test_utils, [meck/2, setup_meck/2, teardown_meck/1, stop_sup/1]).
-import(ezap_capability_tests, [basicCap_funs/0]).

-record(test, {
          sup, basic, pipelines, mods, bridge, vat
         }).

%%-define(RUN,1).
-ifdef(RUN).
%% code to easily run test in debugger..
-export([run/0]).
run() ->
    {setup, S, T, {with, Ts}} = rpc_local_test_(),
    %%{setup, S, T, {with, Ts}} = rpc_remote_test_(),
    X = S(),
    [case P of
         #capability{ id = {local, Pid} } ->
             io:format("trace cap ~p~n", [Pid]),
             sys:trace(Pid, true);
         Pid when is_pid(Pid) ->
             io:format("trace pid ~p~n", [Pid]),
             sys:trace(Pid, true);
         _ -> nop
     end || P <- lists:flatten(erlang:tuple_to_list(X)), P /= X#test.bridge],
    (lists:nth(?RUN, Ts))(X),
    T(X).
-endif.

rpc_local_test_() ->
    {setup,
     fun () ->
             Mods = [setup_meck(Mod, Funs)
                     || {Mod, Funs} <-
                            [{basicCap, basicCap_funs()},
                             {pipelines, pipelines_funs()}
                            ]
                    ],
             {ok, CapS} = ezap_capability_sup:start_link(),
             {ok, ProS} = ezap_promise_sup:start_link(),
             {ok, BasicCap} = ezap_capability_sup:start_capability(basicCap, test_zap:'BasicCap'()),
             {ok, PipelinesCap} = ezap_capability_sup:start_capability(pipelines, test_zap:'Pipelines'(), [{init, BasicCap}]),
             #test{ sup = [CapS, ProS], basic = BasicCap, pipelines = PipelinesCap, mods = Mods }
     end,
     fun (#test{ sup = Sups, mods = Mods }) ->
             [stop_sup(S) || S <- Sups],
             [teardown_meck(Mod) || Mod <- Mods]
     end,
     {with,
      [fun test_request/1,
       fun test_send/1,
       fun test_pipeline/1
      ]}}.

rpc_remote_test_() ->
    %% the remote test really is a local test, using two bridged
    %% client vat processes, so works exactly the same as for a real
    %% remote one, except there's no TCP/IP stack involved here..
    {setup,
     fun () ->
             Mods = [setup_meck(Mod, Funs)
                     || {Mod, Funs} <-
                            [{basicCap, basicCap_funs()},
                             {pipelines, pipelines_funs()},
                             {bridge_echo, echo_funs()}
                            ]
                    ],
             {ok, CapS} = ezap_capability_sup:start_link(),
             {ok, ProS} = ezap_promise_sup:start_link(),
             {ok, BasicCap} = ezap_capability_sup:start_capability(basicCap, test_zap:'BasicCap'()),
             {ok, PipelinesCap} = ezap_capability_sup:start_capability(pipelines, test_zap:'Pipelines'(), [{init, BasicCap}]),
             Bridge = spawn_link(
                       fun () ->
                               Loop = fun (F, VatA, VatB) ->
                                              receive
                                                  {From, stop} ->
                                                      [ezap_vat:stop(Vat) || Vat <- [VatA, VatB]],
                                                      From ! self();
                                                  {VatA, Data} ->
                                                      VatB ! {receive_data, Data},
                                                      F(F, VatA, VatB);
                                                  {VatB, Data} ->
                                                      VatA ! {receive_data, Data},
                                                      F(F, VatA, VatB);
                                                  Other ->
                                                      %% doesn't expect anything here..
                                                      io:format("bridge: ~p~n", [Other]),
                                                      F(F, VatA, VatB)
                                              end
                                      end,
                               receive
                                   {VatA, VatB} ->
                                       Loop(Loop, VatA, VatB)
                               end
                       end),
             {ok, Client} = ezap_vat:start_link({bridge_echo, Bridge}),
             {ok, Server} = ezap_vat:start_link({bridge_echo, Bridge},
                                                  cap_restorer([{<<"basic">>, BasicCap},
                                                                {<<"pipelines">>, PipelinesCap}])),
             Bridge ! {Client, Server},
             io:format("VAT A: ~p~nVAT B: ~p~n", [Client, Server]),
             sys:trace(Server, true),
             #test{ sup = [CapS, ProS], basic = BasicCap, pipelines = PipelinesCap,
                    mods = Mods, bridge = Bridge, vat = Client }
     end,
     fun (#test{ sup = Sups, mods = Mods, bridge = Bridge }) ->
             Bridge ! {self(), stop},
             receive Bridge -> ok end,
             [stop_sup(S) || S <- Sups],
             [teardown_meck(Mod) || Mod <- Mods]
     end,
     {with,
      [fun test_remote_basic/1
       %%fun test_pipeline/1
      ]}}.

echo_funs() ->
    [{send, fun (Pid, Data) -> Pid ! {self(), Data}, ok end}].

pipelines_funs() ->
    [{init, fun (State) -> State end},
     {handle_call, fun ('Pipelines', getBasic, _Params, Result, BasicCap) ->
                           ezap:set(basic, BasicCap, Result),
                           {ok, BasicCap}
                   end}].

cap_restorer(Caps) ->
    fun (ObjectId, _Vat) ->
            case lists:keyfind(ezap_obj:to_text(ObjectId), 1, Caps) of
                false -> undefined;
                {_, Cap} -> {ok, Cap}
            end
    end.

test_request(#test{ basic=Cap }) ->
    Req = ezap:request(add, Cap),
    Params = Req#rpc_call.params,
    Schema = test_zap:'BasicCap'(),
    Method = hd(Schema#schema_node.kind#interface.methods),
    ?assertEqual(
       #rpc_call{
          target = Cap#object.ref#ref.kind,
          interface = Schema#schema_node.id,
          method = Method#method.id,
          params = Params,
          resultSchema = test_zap:schema(Method#method.resultType)
         }, Req),
    ?assertEqual(
       ['BasicCap', [add, '$Params']],
       Params#object.schema#schema_node.name).

test_send(#test{ basic=Cap }) ->
    Req = ezap:request(sub, Cap),
    Params = Req#rpc_call.params,

    %% test set of both request object and the params directly
    ok = ezap:set(a, 333, Req),
    ok = ezap:set(b, 222, Params),
    %% test get of both params directly as well as from the request
    ?assertEqual(333, ezap:get(a, Params)),
    ?assertEqual(222, ezap:get(b, Req)),

    Promise = ezap:send(Req),
    {ok, Res} = ezap:wait(Promise),
    ?assertEqual(111, ezap:get(result, Res)).

test_pipeline(#test{ pipelines = Cap }) ->
    BasicReq = ezap:request(getBasic, Cap),
    BasicPromise = ezap:send(BasicReq),
    PromisedBasicCap = ezap:get(basic, BasicPromise),
    AddReq = ezap:request(add, PromisedBasicCap),
    ok = ezap:set(a, 123, AddReq),
    ok = ezap:set(b, 321, AddReq),
    AddPromise = ezap:send(AddReq),
    %% get data on a promise will wait until fulfilled, then proceed
    ?assertEqual(444, ezap:get(result, AddPromise)).

test_remote_basic(#test{ vat = Vat }) ->
    Promise = ezap:import_capability(Vat, {text, <<"basic">>}, test_zap:'BasicCap'()),
    test_send(#test{ basic=Promise }).

-endif.
