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
%% @doc Calculator server sample application.
%%
%% The operations are based on the calculator server sample from the
%% zap distribution.

-module('calculator-server').

-export([dbg/0, run/0, init/1, handle_call/5]).

-include_lib ("ezap/include/ezap.hrl").

dbg() ->
    io:format(
      "dbg: ~p~n",
      [[dbg:tracer(),
        dbg:p(new, [c]),
        %dbg:tpl(?MODULE, []),
        dbg:tpl(ezap_capability, [])
        %dbg:tp(ezap_rpc, []),
        %dbg:tpl(ezap_vat, []),
        %dbg:tp(ezap, [])
       ]]).

run() ->
    spawn_link(
      fun () ->
              ezap_promise_sup:start_link(),
              ezap_capability_sup:start_link(),
              CapRestorer = fun (ObjectId, Vat) ->
                                    case ezap_obj:to_text(ObjectId) of
                                        <<"calculator">> ->
                                            ezap_capability_sup:start_capability(
                                              ?MODULE, calculator_zap:'Calculator'(),
                                              [{monitor, Vat}])
                                    end
                            end,
              listen({localhost, 55000}, CapRestorer)
      end).

listen({_Addr, Port}, CapRestorer) ->
    {ok, Socket} = gen_tcp:listen(Port, [binary, {active, false}, {reuseaddr, true}]),
    accept(Socket, CapRestorer).

accept(Socket, CapRestorer) ->
    case gen_tcp:accept(Socket) of
        {ok, Client} ->
            spawn_link(fun () -> accept(Socket, CapRestorer) end),
            {ok, Vat} = ezap_vat:start_link({gen_tcp, Client}, CapRestorer),
            %%sys:trace(Vat, true),
            read_socket(Client, Vat),
            accept(Socket, CapRestorer);
        {error, closed} ->
            io:format("~ntcp server socket closed~n");
            %%halt(0);
        {error, Reason} ->
            io:format("~ntcp server socket error: ~p~n", [Reason])
            %%halt(1)
    end.

read_socket(Sock, Vat) ->
    case gen_tcp:recv(Sock, 0) of
        {ok, Data} ->
            Vat ! {receive_data, Data},
            read_socket(Sock, Vat);
        {error, closed} ->
            io:format("~ntcp client socket closed~n");
        {error, Reason} ->
            io:format("~ntcp client socket error: ~p~n", [Reason])
    end.


%% Capability callbacks

%% since I'm lazy, all calculator capabilities call back to this
%% module, so it's kind of messy here..

init({defFunction, Params}) ->
    ParamCount = ezap:get(paramCount, Params),
    Body = ezap:get(body, Params),
    {def, ParamCount, Body};
init(State) -> State.

handle_call('Calculator', evaluate, Params, Results, State) ->
    Expr = ezap:get(expression, Params),
    Value = evaluate(Expr),
    {ezap:set(value, cap('Value', Value), Results), State};
handle_call('Calculator', getOperator, Params, Results, State) ->
    {ezap:set(func, cap('Function', {op, ezap:get(op, Params)}), Results), State};
handle_call(['Calculator', 'Value'], read, _Params, Results, Value) ->
    {ezap:set(value, ezap:wait(Value), Results), Value};
handle_call(['Calculator', 'Function'], call, Params, Results, {op, Operator}=State) ->
    [Op1, Op2] = ezap:get(params, Params),
    Value =
        case Operator of
            add -> Op1 + Op2;
            subtract -> Op1 - Op2;
            multiply -> Op1 * Op2;
            divide -> Op1 / Op2
        end,
    {ezap:set(value, Value, Results), State};
handle_call(['Calculator', 'Function'], call, Params, Results, {def, ParamCount, Body}=State) ->
    CallParams = ezap:get(params, Params),
    if length(CallParams) == ParamCount ->
            {ezap:set(value, ezap:wait(evaluate(Body, CallParams)), Results), State}
    end;
handle_call('Calculator', defFunction, Params, Results, State) ->
    {ezap:set(func, cap('Function', {defFunction, Params}), Results), State}.


%% Cap utils

evaluate(Expr) -> evaluate(Expr, []).
evaluate(Expr, EvalParams) ->
    {ok, Promise} =
        ezap_promise_sup:start_promise(
          [{fullfiller,
            fun () ->
                    Result =
                        case ezap:get(Expr) of
                            {literal, Literal} -> Literal;
                            {previousResult, Value} ->
                                ReadReq = ezap:request(read, Value),
                                ezap:get(value, ezap:send(ReadReq));
                            {parameter, Idx} ->
                                lists:nth(Idx + 1, EvalParams);
                            {call, Call} ->
                                Func = ezap:get(function, Call),
                                CallParams = [evaluate(E, EvalParams)
                                              || E <- ezap:get(params, Call)],
                                CallReq = ezap:request(call, Func),
                                ezap:set(params, [ezap:wait(P) || P <- CallParams], CallReq),
                                ezap:get(value, ezap:send(CallReq))
                        end,
                    {ok, Result}
            end}
          ]),
    #promise{ pid = Promise }.

cap(Type, Init) ->
    {ok, Cap} = ezap_capability_sup:start_capability(
                  ?MODULE, calculator_zap:schema(['Calculator', Type]),
                  [{monitor, self()}, {init, Init}]),
    Cap.
