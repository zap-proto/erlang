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

%% @copyright 2013, Andreas Stenius
%% @author Andreas Stenius <kaos@astekk.se>
%% @doc Write support.
%%
%% Everything for writing data into a message.

-module(ezap_set).
-author("Andreas Stenius <kaos@astekk.se>").

-export([root/1, root/2, field/2, field/3, fields/2, union/2]).

-include("ezap.hrl").


%% ===================================================================
%% API functions
%% ===================================================================

-spec root(type_name(), schema()) -> {ok, object()}.
%% @doc Get root object for a new message.
root(Type, Schema) ->
    root(Schema:schema(Type)).

-spec root(schema_node()) -> {ok, object()}.
%% @doc Get root object for a new message.
root(Node) when is_record(Node, schema_node) ->
    {ok, Data} = ezap_data:start_link(default),
    {ok, ezap_obj:alloc(Node, 0, Data)}.

-spec field(field_name(), field_value(), object()) -> ok | list().
%% @doc Write field value to object.
field(FieldName, Value, #rpc_call{ params = Object }) ->
    field(FieldName, Value, Object);
field(FieldName, Value, Object) ->
    case ezap_obj:field(FieldName, Object) of
        false -> throw({unknown_field, FieldName});
        Field -> set_field(Field, Value, Object)
    end.

field(FieldName, #rpc_call{ params = Object }) -> field(FieldName, Object);
field(FieldName, Object) ->
    case ezap_obj:field(FieldName, Object) of
        false -> union(FieldName, Object);
        Field -> set_field(Field, {default}, Object)
    end.

fields(FieldValues, Object) ->
    [case Value of
         {F, V} -> field(F, V, Object);
         {V} -> union(V, Object)
     end || Value <- FieldValues].

-spec union({field_name(), field_value()} | field_name(), object()) -> ok.
%% @doc Write unnamed union value in object.
union(Value, #rpc_call{ params = Object }) -> union(Value, Object);
union(Value, #object{
                schema=#schema_node{
                          kind=#struct{ union_field=Union }}
               }=Object) ->
    if Union /= none -> set_field(Union, Value, Object);
       true -> throw({no_unnamed_union_in_object, Object})
    end.


%% ===================================================================
%% internal functions
%% ===================================================================

set_field(#field{ kind=void }, _, _) -> ok;
set_field(#field{ kind=Kind }, Value, Obj) ->
    set_field(Kind, Value, Obj);
set_field(#data{ type=Type, align=Align, default=Default }=D,
          Value0, #object{ ref=StructRef }=Obj) ->
    Value = if Value0 == {default} -> Default;
               true -> Value0
            end,
    case Type of
        {enum, EnumType} ->
            #schema_node{ kind=#enum{ values=Values } }
                = ezap_schema:lookup(EnumType, Obj),
            Tag = if is_atom(Value) ->
                          {Idx, Value} = lists:keyfind(Value, 2, Values),
                          Idx;
                     is_integer(Value) -> Value
                  end,
            set_field(D#data{ type=uint16 }, Tag, Obj);
        {union, Fields} ->
            {Tag, Field} = union_tag(Value, Fields),
            set_field(D#data{ type=uint16 }, Tag, Obj),
            case Field of
                void -> ok;
                {FieldType, FieldValue} ->
                    set_field(FieldType, FieldValue, Obj)
            end;
        Type ->
            Size = ezap_val:size(Type),
            ezap_ref:write_struct_data(
              Align, Size,
              ezap_val:set(Type, Value, Default),
              StructRef)
    end;

set_field(#ptr{ idx=Idx, type=Type, default=Default }=Ptr,
          Value0, #object{ ref=StructRef }=Obj) ->
    Value = if Value0 == {default} -> Default;
               true -> Value0
            end,
    case Type of
        text -> ezap_ref:write_text(
                  Value,
                  ezap_ref:ptr(Idx, StructRef),
                  StructRef);
        data -> ezap_ref:write_data(
                  Value,
                  ezap_ref:ptr(Idx, StructRef),
                  StructRef);
        object ->
            case Value of
                {ObjType, ObjValue} ->
                    set_field(Ptr#ptr{ type=ObjType }, ObjValue, Obj);
                _ ->
                    {ObjType, ObjValue}
                        = if is_integer(Value); is_atom(Value) ->
                                  {ezap_schema:lookup(Value, Obj), Default};
                             is_record(Value, schema_node) ->
                                  {Value, Default};
                             is_record(Value, object);
                             is_binary(Value) ->
                                  {object, Value};
                             true ->
                                  throw({error, {invalid_object_value, Value}})
                          end,
                    write_obj(ObjType, ObjValue, ezap_ref:ptr(Idx, StructRef), Obj)
            end;
        {struct, StructType} ->
            write_obj(StructType, Value, ezap_ref:ptr(Idx, StructRef), Obj);
        {interface, InterfaceType} ->
            write_obj(InterfaceType, Value, ezap_ref:ptr(Idx, StructRef), Obj);
        {list, ElementType} ->
            if is_integer(Value) -> %% init list
                    ezap_obj:from_ref(
                      ezap_ref:alloc_list(
                        Idx, #list_ref{
                                size=list_element_size(ElementType, Obj),
                                count=Value },
                        StructRef),
                      Type, Obj);
               is_tuple(Value), size(Value) == 2 -> %% {Idx, Value}
                    case ElementType of
                        object -> throw(not_yet_implemented);
                        interface -> throw(not_yet_implemented);
                        {list, _} -> throw(not_yet_implemented);
                        {struct, StructType} ->
                            case element(2, Value) of %% {Idx, {Field, Value}}
                                {FieldName, FieldValue} ->
                                    List = ezap_ref:read_struct_ptr(
                                             Idx, StructRef),
                                    field(FieldName, FieldValue,
                                          ezap_obj:from_ref(
                                            ezap_ref:ptr(
                                              element(1, Value), List),
                                            StructType, Obj))
                            end;
                        text ->
                            List = ezap_ref:read_struct_ptr(Idx, StructRef),
                            ezap_ref:write_text(
                              element(2, Value),
                              ezap_ref:ptr(element(1, Value), List),
                              List);
                        data ->
                            List = ezap_ref:read_struct_ptr(Idx, StructRef),
                            ezap_ref:write_data(
                              element(2, Value),
                              ezap_ref:ptr(element(1, Value), List),
                              List);
                        _ ->
                            ezap_ref:write_list(
                              Idx,
                              element(1, Value),
                              ezap_val:set(ElementType, element(2, Value)),
                              StructRef)
                    end;
               is_list(Value) -> %% [Value...]
                    set_field(Ptr, length(Value), Obj),
                    [ok = set_field(Ptr, V, Obj)
                     || V <- lists:zip(
                               lists:seq(0, length(Value) - 1),
                               Value)], ok
            end
    end;
set_field(#group{ id=Type }, {default}, #object{ ref=StructRef }=Obj) ->
    ezap_obj:from_ref(StructRef, Type, Obj);
set_field(#group{ id=Type }, Value, #object{ ref=StructRef }=Obj) ->
    case ezap_obj:from_ref(StructRef, Type, Obj) of
        #object{
           schema = #schema_node{
                       kind = #struct{
                                 union_field = Union,
                                 fields = []
                                }}}=Group
          when Union =/= none ->
            %% set named union (which are represented as an unnamed
            %% union wrapped in a group)
            set_field(Union, Value, Group);
        Group ->
            %% set group field (or group unnamed union)
            case Value of
                {FieldName, FieldValue} ->
                    field(FieldName, FieldValue, Group);
                _ ->
                    field(Value, Group)
            end
    end.

write_obj(Type, Value, Ref, Obj) when is_binary(Value) ->
    ezap_obj:from_ref(
      ezap_ref:paste(Value, Ref),
      Type, Obj);
write_obj(Type, {FieldName, FieldValue}, Ref, Obj) ->
    Self = ezap_obj:init(ezap_obj:from_ref(Ref, Type, Obj)),
    {Self, field(FieldName, FieldValue, Self)};
write_obj(Type, Values, Ref, Obj) when is_list(Values) ->
    Self = ezap_obj:init(ezap_obj:from_ref(Ref, Type, Obj)),
    {Self, fields(Values, Self)};
write_obj(Type, #object{ ref=Value, schema=_Schema }, Ref, Obj) ->
    %% todo: check that Schema is compatible with Type
    case Value of
        #ref{ kind = Kind } when is_record(Kind, interface_ref) ->
            ezap_ref:set(Kind, Ref), ok;
        _ ->
            write_obj(Type, ezap_ref:copy(Value), Ref, Obj)
    end.

union_tag({FieldName, Value}, [#field{ id = Tag, name = FieldName }=FieldType|_]) ->
    {Tag, union_field_value(FieldType, Value)};
union_tag(FieldName, [#field{ id = Tag, name = FieldName }=FieldType|_]) ->
    {Tag, union_field_value(FieldType)};
union_tag({Tag, Value}, [#field{ id = Tag }=FieldType|_]) ->
    {Tag, union_field_value(FieldType, Value)};
union_tag(Tag, [#field{ id = Tag }=FieldType|_]) ->
    {Tag, union_field_value(FieldType)};
union_tag(Value, [_|Fields]) ->
    union_tag(Value, Fields).

union_field_value(FieldType) ->
    union_field_value(FieldType, {default}).

union_field_value(_, void) -> void;
union_field_value(#field{ kind=void }, _) -> void;
union_field_value(FieldType, Value) -> {FieldType, Value}.

list_element_size(text, _) -> pointer;
list_element_size(data, _) -> pointer;
list_element_size(object, _) -> pointer;
list_element_size({list, _}, _) -> pointer;
list_element_size({Simple, _}, _)
  when Simple == enum; Simple == union -> 16;
list_element_size({_, Type}, Obj) ->
    #schema_node{ kind=Kind } = ezap_schema:lookup(Type, Obj),
    case Kind#struct.esize of
        empty -> 0;
        bit -> 1;
        byte -> 8;
        twoBytes -> 16;
        fourBytes -> 32;
        eightBytes -> 64;
        pointer -> pointer;
        inlineComposite ->
            {inlineComposite, ezap_schema:get_ref_kind(Kind)}
    end;
list_element_size(Type, _) ->
    ezap_val:size(Type).
