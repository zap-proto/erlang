-file("c++.zap", 1).

%% This file was generated 2016-08-18 19:40:29 UTC by ezap 0.2.
%% https://github.com/zap-proto/erlang
-module('c++_zap').

-vsn(13688829037717245569).

-export([schema/1, namespace/0, namespace/1, '13386661402618388268'/0, root/0, root/1,
	 '13688829037717245569'/0]).

-types([{13386661402618388268, namespace}, {13688829037717245569, root}]).

-file("/Users/aadt/lib/erl/global/ezap/include/ezap_schema.hrl", 1).

-ezap_schema_version(4).

-record(schema_node,
	{module  :: atom(), name  :: ezap:type_name(), id = 0  :: ezap:type_id(),
	 src = <<>>  :: ezap:text(), kind = file  :: ezap:schema_kind(), annotations = []  :: list(),
	 nodes = []  :: ezap:schema_nodes(), scope = 0  :: ezap:type_id()}).

-record(struct,
	{dsize = 0  :: ezap:word_count(), psize = 0  :: ezap:ptr_count(),
	 esize = inlineComposite  :: ezap:element_size(),
	 union_field = none  :: none | ezap:field_type(), fields = []  :: ezap:struct_fields()}).

-record(enum, {values = []  :: ezap:enum_values()}).

-record(interface, {extends = []  :: list(), methods = []  :: list()}).

-record(const, {field}).

-record(annotation, {type, targets = []  :: [atom()]}).

-record(field, {id, name, kind, annotations = []}).

-record(ptr,
	{type  :: term(), idx = 0  :: ezap:ptr_index(),
	 default = <<0:64/integer-little>>  :: ezap:value()}).

-record(data, {type  :: term(), align = 0  :: ezap:bit_count(), default  :: ezap:value()}).

-record(group, {id = 0  :: ezap:type_id()}).

-record(method, {id, name, paramType, resultType}).

-file("c++.zap", 1).

schema(13386661402618388268) -> '13386661402618388268'();
schema(namespace) -> '13386661402618388268'();
schema([namespace]) -> '13386661402618388268'();
schema(13688829037717245569) -> '13688829037717245569'();
schema(root) -> '13688829037717245569'();
schema([root]) -> '13688829037717245569'();
schema(_) -> undefined.

root() -> '13688829037717245569'().

root([]) -> '13688829037717245569'().

'13688829037717245569'() ->
    #schema_node{module = 'c++_zap', name = root, id = 13688829037717245569, scope = 0,
		 src = <<"c++.zap">>, annotations = [{13386661402618388268, <<"zap::annotations">>}],
		 kind = file,
		 nodes =
		     [13386661402618388268]}.  %% namespace

namespace() -> '13386661402618388268'().

namespace([]) -> '13386661402618388268'().

'13386661402618388268'() ->
    #schema_node{module = 'c++_zap', name = namespace, id = 13386661402618388268,
		 scope = 13688829037717245569, src = <<"c++.zap:namespace">>,
		 kind = #annotation{type = #ptr{type = text, idx = 0, default = <<>>}, targets = [targetsFile]}}.