%%
%%  Copyright 2013, Andreas Stenius <kaos@astekk.se>
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

-module(ezap_capability_tests).
-ifdef(TEST).
-export([basicCap_funs/0]).
-import(ezap_test_utils, [meck/3, setup_meck/2, teardown_meck/1]).

-include_lib("eunit/include/eunit.hrl").
-include("include/ezap.hrl").


basicCap_test_() ->
    {setup,
     fun () ->
             {ok, _} = ezap_promise_sup:start_link(),
             setup_meck(basicCap, basicCap_funs())
     end,
     fun (Mod) ->
             teardown_meck(Mod)
     end,
     [fun () ->
              {ok, Pid} = ezap_capability:start([basicCap, [test_zap:'BasicCap'()]]),
              ?assert(is_process_alive(Pid)),
              ok = ezap_capability:stop(Pid),
              receive after 100 -> ok end, %% ugly hack, I know..
              ?assert(not is_process_alive(Pid))
      end,
      fun () ->
              S = test_zap:'BasicCap'(),
              {ok, Pid} = ezap_capability:start_link([basicCap, [S]]),
              test_basicCap_add(Pid, S, 123, 456)
      end
     ]}.

thirdCap_test_() ->
    meck(thirdCap, thirdCap_funs(),
         [fun () ->
                  S = test_zap:'ThirdCap'(),
                  {ok, Pid} = ezap_capability:start_link([thirdCap, [S], {init, third}]),
                  test_basicCap_add(Pid, test_zap:'BasicCap'(), 333, 666),
                  test_otherCap_sqroot(Pid, test_zap:'OtherCap'(), 4),
                  test_thirdCap_square(Pid, S, 5)
          end
         ]).

basicCap_funs() ->
    [{handle_call, fun ('BasicCap', add, Params, Result, undefined) -> {basicCap_add(Params, Result), undefined};
                       ('BasicCap', sub, Params, Result, undefined) -> {basicCap_sub(Params, Result), undefined}
                   end}].

basicCap_add(Params, Results) ->
    ezap:set(result,
               ezap:get(a, Params)
               + ezap:get(b, Params),
               Results).

basicCap_sub(Params, Results) ->
    ezap:set(result,
               ezap:get(a, Params)
               - ezap:get(b, Params),
               Results).

test_basicCap_add(Pid, S, A, B) ->
    {ok, Params} = ezap:set_root(['BasicCap', [add, '$Params']], test_zap),
    ok = ezap:set(a, A, Params),
    ok = ezap:set(b, B, Params),
    Req = #rpc_call{
             interface = S#schema_node.id,
             method = 0,
             params = Params
            },
    Promise = ezap_capability:send(Pid, Req),
    {ok, Result} = ezap_promise:wait(Promise, 1000),
    ?assertEqual(A+B, ezap:get(result, Result)).

otherCap_sqroot(Params, Results) ->
    Sqrt = math:sqrt(ezap:get(a, Params)),
    ezap:set(root1, Sqrt, Results),
    ezap:set(root2, -Sqrt, Results).

test_otherCap_sqroot(Pid, S, A) ->
    {ok, Params} = ezap:set_root(['OtherCap', [sqroot, '$Params']], test_zap),
    ok = ezap:set(a, A, Params),
    {ok, Result} = ezap_promise:wait(
                     ezap_capability:send(
                       Pid, #rpc_call{ interface = S#schema_node.id,
                                       method = 0, params = Params }),
                     1000),
    R1 = ezap:get(root1, Result),
    R2 = ezap:get(root2, Result),
    ?assertEqual(float(-A), R1*R2).

thirdCap_funs() ->
    [{init, fun (third) -> {state, []} end},
     {handle_call,
      fun ('BasicCap', add, Params, Result, {state, []}) -> {basicCap_add(Params, Result), {state, []}};
          ('OtherCap', sqroot, Params, Result, {state, []}) -> {otherCap_sqroot(Params, Result), {state, []}};
          ('ThirdCap', square, Params, Result, {state, []}) -> {thirdCap_square(Params, Result), {state, []}}
      end}].

thirdCap_square(Params, Results) ->
    A = ezap:get(a, Params),
    ezap:set(sq, A * A, Results).

test_thirdCap_square(Pid, S, A) ->
    {ok, Params} = ezap:set_root(['ThirdCap', [square, '$Params']], test_zap),
    ok = ezap:set(a, A, Params),
    {ok, Result} = ezap_promise:wait(
                     ezap_capability:send(
                       Pid, #rpc_call{ interface = S#schema_node.id,
                                       method = 0, params = Params }),
                     1000),
    ?assertEqual(A*A, ezap:get(sq, Result)).

-endif.
