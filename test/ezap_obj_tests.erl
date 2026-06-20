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

-module(ezap_obj_tests).
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-include("include/ezap.hrl").

-import(ezap_test_utils, [data/1]).

from_ref_test() ->
    Data = data([<<0,0,0,0, 2,0,3,0>>]),
    Ref = ezap_ref:get(0, 0, Data),
    ?assertEqual(
       #object{ ref=Ref, schema=test_zap },
       ezap_obj:from_ref(Ref, object, test_zap)).

field_test() ->
    T = test_zap:'Test'(),
    ?assertEqual(
       #field{ id = 0, name=intField,
               kind=#data{ type=uint8, align=0, default= <<33>> } },
       ezap_obj:field(intField, #object{ schema=T })).

copy_test() ->
    Bin = <<0,0,0,0, 2,0,2,0,
            1234:32/integer, 5678:32/integer,
            8765:32/integer, 4321:32/integer,
            0:64/integer,
            1,0,0,0, 106,0,0,0,
            "Hello World!", 0,
            0:24/integer
          >>,
    Data = data([Bin]),
    Ref = ezap_ref:get(0, 0, Data),
    Obj = ezap_obj:from_ref(Ref, object, test_zap),
    ?assertEqual(#object{ ref=Ref, schema=test_zap }, Obj),
    ?assertEqual(Bin, ezap_obj:copy(Obj)).

object_test() ->
    Data = data([]),

    NullRef = #ref{ data=Data },
    NullObj = ezap_obj:from_ref(NullRef, object, test_zap),

    ListRef = #ref{ kind=#list_ref{ size=8 }, data=Data },
    ListObj = ezap_obj:from_ref(ListRef, object, test_zap),

    T = test_zap:'Test'(),
    ?assertEqual(
      #object{ schema=T, ref=NullRef },
      ezap_obj:to_struct('Test', NullObj)),

    ?assertEqual([], ezap_obj:to_list('Simple', ListObj)),
    ?assertEqual(<<>>, ezap_obj:to_text(ListObj)),
    ?assertEqual(<<>>, ezap_obj:to_data(ListObj)).

-endif.
