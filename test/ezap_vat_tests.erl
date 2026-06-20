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

-module(ezap_vat_tests).
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-include("include/ezap.hrl").
-import(ezap_test_utils, [meck/3]).

%% export_capability_test() ->
%%     {ok, Vat} = ezap_vat:start_link(),
%%     Cap = #capability{},
%%     {ok, ExportId} = ezap_vat:export_capability(Cap, Vat),
%%     ?assertEqual(0, ExportId),
%%     ?assertEqual({ok, Cap}, ezap_vat:find_capability(ExportId, Vat)).

%% restore_capability_test__() ->
%%     meck(echo, transport_funs(),
%%          [fun test_restore_capability/0
%%           %%,fun test_process_restore_message/0
%%          ]).

%% transport_funs() ->
%%     [{send, fun (Tester, Data) -> Tester ! {captured, Data}, ok end}].

%% test_restore_capability() ->
%%     {ok, Vat} = ezap_vat:start_link({echo, self()}),
%%     {ok, _Promise} = ezap_vat:import_capability(<<"test-cap">>, Vat),
%%     {ok, Req} = receive {captured, Data} -> {ok, Data} after 10 -> missing_data end,
%%     {ok, Msg} = ezap_get:root('Message', rpc_zap, ezap_message:read(Req)),
%%     {restore, Res} = ezap:get(Msg),
%%     Obj = ezap_obj:to_text(ezap:get(objectId, Res)),
%%     ?assertEqual(<<"test-cap">>, Obj).

%% test_process_restore_message() ->
%%     {ok, Vat} = ezap_vat:start_link({echo, self()}),
%%     {ok, ExportId} = ezap_capability:start_link(basicCap, test_zap:'BasicCap'()),
%%     {ok, ReqMsg} = ezap:set_root('Message', rpc_zap),
%%     Res = ezap_obj:init(ezap:set(restore, ReqMsg)),
%%     ok = ezap:set(objectId, {text, <<"test-cap">>}, Res),
%%     Vat ! {message, ezap_message:write(ReqMsg)},
%%     {ok, Rsp} = receive {captured, Data} -> {ok, Data} after 10 -> missing_data end,
%%     {ok, RspMsg} = ezap_get:root('Message', rpc_zap, ezap_message:read(Rsp)),
%%     {return, Ret} = ezap:get(RspMsg),
%%     {results, Payload} = ezap:get(Ret),
%%     _Content = ezap:get(content, Payload),
%%     [Cap] = ezap:get(capTable, Payload),
%%     ?assertEqual({senderHosted, ExportId}, ezap:get(Cap)).


%% sturdy_capability_test() ->
%%     ezap_vat:register_capability("Basic", basicCap, test_zap:'BasicCap'()).


%% basic_server_test() ->
%%     %% setup expectations
%%     setup_meck(basicCap, [{add,
%%                            fun(Params, Results) ->
%%                                    ezap:set(result,
%%                                         ezap:get(a, Params)
%%                                         + ezap:get(b, Params),
%%                                         Results)
%%                            end}
%%                          ]),
%%     %% start server for capability
%%     {ok, Cap} = ezap_capability:start('BasicCap', basicCap, test_zap),
%%     %% prepare request
%%     {ok, Request} = ezap_capability:request(add, Cap),
%%     %%check_request('BasicCap', add, Request),
%%     Params = ezap_capability:params(Request),
%%     ok = ezap:set(a, 123, Params),
%%     ok = ezap:set(b, 456, Params),
%%     %% send request
%%     {ok, Result} = ezap_capability:send(Request),
%%     %% check_promise(...),
%%     %% wait for then verify response
%%     ok = ezap_capability:wait(Result),
%%     ?assertEqual(579, ezap:get(result, Result)),
%%     %% clean up
%%     ezap_capability:stop(Cap),
%%     teardown_meck(basicCap).

%% pipeline_test() ->
%%     %% setup expectations
%%     setup_meck(basicCap, [{add,
%%                            fun(Params, Results) ->
%%                                    ezap:set(result,
%%                                         ezap:get(a, Params)
%%                                         + ezap:get(b, Params),
%%                                         Results)
%%                            end}
%%                          ]),
%%     setup_meck(pipelines, [{getBasic,
%%                             fun(_Params, Results) ->
%%                                     {ok, Basic} = ezap_capability:start('BasicCap', basicCap, test_zap),
%%                                     ezap:set(basic, Basic, Results), ok
%%                             end}
%%                           ]),
%%     %% start server for capabilities
%%     {ok, Pipe} = ezap_capability:start('Pipelines', pipelines, test_zap),
%%     %% prepare request
%%     {ok, Request} = ezap_capability:request(getBasic, Pipe),
%%     check_request('Pipelines', getBasic, Request),
%%     %% send request
%%     {ok, Result} = ezap_capability:send(Request),
%%     %% check_promise(...),
%%     %% pipeline request
%%     Basic = ezap:get(basic, Result),
%%     {ok, PipeRequest} = ezap_capability:request(add, Basic),
%%     PipeParam = ezap_capability:param(PipeRequest),
%%     ok = ezap:set(a, 111, PipeParam),
%%     ok = ezap:set(b, 222, PipeParam),
%%     {ok, PipeResult} = ezap_capability:send(PipeRequest),
%%     %% wait for then verify response
%%     ok = ezap_capability:wait(Result),
%%     ok = ezap_capability:wait(PipeResult),
%%     ?assertEqual(333, ezap:get(result, PipeResult)),
%%     %% clean up
%%     ezap_capability:stop(Pipe),
%%     teardown_meck(basicCap),
%%     teardown_meck(pipelines).


%% check_request(Cap, Method, Req) ->
%%     #request{ method=ActualMethod, param=Object } = Req,
%%     ?assertEqual(Method, ActualMethod),
%%     {ok, Node} = ezap_schema:lookup(Cap, test_zap),
%%     #method{ paramType=ParamType }
%%         = lists:keyfind(Method, #method.name,
%%                         (Node#schema_node.kind)#interface.methods),
%%     {ok, Params} = ezap_schema:lookup(ParamType, test_zap),
%%     #object{ schema=ParamsNode, ref=ParamsRef } = Object,
%%     ?assertEqual(Params, ParamsNode),
%%     #schema_node{ kind=#struct{ dsize=DSize, psize=PSize } } = Params,
%%     ?assertEqual(
%%        #ref{ segment=0, pos=0, offset=0,
%%              data=ParamsRef#ref.data, %% don't care (it's a new pid every time)
%%              kind=#struct_ref{ dsize=DSize, psize=PSize } },
%%        ParamsRef).


-endif.
