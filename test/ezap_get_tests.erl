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

-module(ezap_get_tests).
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-include("include/ezap.hrl").

root_test() ->
    Msg = [<<0,0,0,0, 2,0,3,0>>],
    {ok, Root} = ezap_get:root('Test', test_zap, Msg),
    T = ezap_schema:lookup('Test', test_zap),
    Data = (Root#object.ref)#ref.data,
    ?assertEqual(
       #object{
          ref=#ref{ segment=0, pos=0, offset=0, data=Data,
                    kind=#struct_ref{ dsize=2, psize=3 } },
          schema=T
         }, Root).

field_defaults_test() ->
    Msg= [<<0,0,0,0, 2,0,6,0, %% struct, 2 word data, 6 pointers
            %% data
            0:64/integer-unit:2,
            %% pointers
            0:64/integer-unit:6
          >>],
    check_default_values(Msg),
    check_default_values([<<0:64/integer>>]).

check_default_values(Msg) ->
    {ok, Root} = ezap:get_root('Test', test_zap, Msg),
    ?assertEqual(33, ezap:get(intField, Root)),
    ?assertEqual(<<"test">>, ezap:get(textField, Root)),
    ?assertEqual({boolField, false}, ezap:get(Root)),
    ?assertEqual({bool, true}, ezap:get(opts, Root)),
    Meta = ezap:get(meta, Root),
    ?assertEqual(0, ezap:get(id, Meta)),
    ?assertEqual(<<>>, ezap:get(tag, Meta)),
    ?assertEqual(<<"1234">>, ezap:get(data, Meta)),
    Struct = ezap:get(structField, Root),
    ?assertEqual(<<"simple message">>, ezap:get(simpleMessage, Struct)),
    ?assertEqual(<<"default message">>, ezap:get(message, Struct)),
    ?assertEqual(222, ezap:get(value, Struct)),
    ?assertEqual(333, ezap:get(defaultValue, Struct)).

field_values_test() ->
    Msg = [<<0,0,0,0, 2,0,6,0, %% struct, 2 word data, 6 pointers
             %% data
             33: 8/integer-little, %% intField
             0: 8/integer-little, %% tag 0: boolField, 1: groupField.a
             1:16/integer-little, %% union tag
             %% 32
             55: 8/integer-little, %% tag 1: groupField.b
             22: 8/integer-little, %% tag 1: groupField.c

             0: 1/integer-little, %% opts tag 0: bool
             0:15/integer-little, %% padding
             %% 64
             3:16/integer-little, %% opts union tag
             1234:16/integer-little, %% meta.id
             %% 96
             0:32/integer-little, %% padding
             %% 128

             %% pointers
             1:32/integer-little, 2:32/integer-little, %% textField
             %% opts tag 1: text, 2: data, 3: object
             16:32/integer-little,
             1:16/integer-little,
             2:16/integer-little,

             0:64/integer-little, %% meta.tag
             0:64/integer-little, %% meta.data
             %% structField (offset -1, 0 data 0 ptrs), effectively a null ptr
             %% but doesn't use the default values defined for this field
             -4:32/integer-little, 0:32/integer-little,
             0:64/integer-little, %% meta.struct

             %% opts.object data (Simple struct)
             222:32/integer-little-unsigned, %% value
             0:32/integer-little-unsigned, %% defaultValue
             0:64/integer-little, %% message
             1:32/integer-little, 106:32/integer-little, %% simpleMessage
             "Hello World!", 0, 0:24/integer-little
           >>],
    {ok, Root} = ezap:get_root('Test', test_zap, Msg),
    ?assertEqual(0, ezap:get(intField, Root)),
    ?assertEqual(<<>>, ezap:get(textField, Root)),
    {groupField, Union} = ezap:get(Root),
    ?assertEqual(-44, ezap:get(a, Union)),
    ?assertEqual(0, ezap:get(b, Union)),
    ?assertEqual(22, ezap:get(c, Union)),
    {object, Obj} = ezap:get(opts, Root),
    Simple = ezap_obj:to_struct('Simple', Obj),
    ?assertEqual(<<"Hello World!">>, ezap:get(simpleMessage, Simple)),
    ?assertEqual(<<"default message">>, ezap:get(message, Simple)),
    ?assertEqual(0, ezap:get(value, Simple)),
    ?assertEqual(333, ezap:get(defaultValue, Simple)),
    Meta = ezap:get(meta, Root),
    ?assertEqual(1234, ezap:get(id, Meta)),
    ?assertEqual(<<>>, ezap:get(tag, Meta)),
    ?assertEqual(<<"1234">>, ezap:get(data, Meta)),
    Struct = ezap:get(structField, Root),
    ?assertEqual(<<"simple message">>, ezap:get(simpleMessage, Struct)),
    ?assertEqual(<<"default message">>, ezap:get(message, Struct)),
    ?assertEqual(222, ezap:get(value, Struct)),
    ?assertEqual(333, ezap:get(defaultValue, Struct)).


default_list_test() ->
    {ok, Root} = ezap:get_root('ListTest', test_zap, [<<0:64/integer>>]),
    ?assertEqual([456, 789, -123], ezap:get(listInts, Root)),
    ?assertEqual([], ezap_obj:to_list(bool, ezap:get(listAny, Root))),
    [Obj1, Obj2] = ezap:get(listSimples, Root),
    [?assertEqual(E, ezap:get(F, O))
     || {O, T} <- [{Obj1, [{value, 1}, {message, <<"first">>}]},
                   {Obj2, [{value, 2}, {message, <<"second">>}]}],
        {F, E} <- T].

text_list_test() ->
    Text1 = <<"abcdefghijklmnopqrstuvwxyz">>,
    Text2 = <<"0123456789">>,
    Text3 = <<"The end">>,
    Msg = <<0,0,0,0, 0,0,4,0,
            0:3/integer-little-unit:64,
            1,0,0,0, 30,0,0,0, %% listText: off 0, 3 ptrs
            9,0,0,0, 218,0,0,0, %% text 1, 26 bytes+NULL, 4 words
            21,0,0,0, 90,0,0,0, %% text 2, 10 bytes+NULL, 2 words
            25,0,0,0, 66,0,0,0, %% text 3, 7+NULL, 1 word
            Text1/binary, 0,
            0:5/integer-little-unit:8, %% padding
            Text2/binary, 0,
            0:5/integer-little-unit:8, %% padding
            Text3/binary, 0>>,
    {ok, Root} = ezap:get_root('ListTest', test_zap, [Msg]),
    [?assertEqual(Expect, Actual)
     || {Expect, Actual} <- 
            lists:zip(
              [Text1, Text2, Text3],
              ezap:get(listText, Root))].

get_cap_test() ->
    Msg = [<<0,0,0,0, 0,0,2,0, %% root struct w 2 ptrs
             3,0,0,0, 1,0,0,0, %% cap ptr 11 (basic)
             3,0,0,0, 2,0,0,0  %% cap ptr 22 (obj)
           >>],
    {ok, R} = ezap:get_root('CapTest', test_zap, Msg),
    Cap1 = #interface_ref{ id = 1 },
    Cap2 = #interface_ref{ id = 2 },
    Root = ezap_obj:set_cap_table([dummy, Cap1, Cap2], R),
    Basic = ezap:get(basic, Root),
    Obj = ezap:get(obj, Root),
    ?assertEqual(Cap1, Basic#object.ref#ref.kind),
    ?assertEqual(Cap2, Obj#object.ref#ref.kind).


-endif.
