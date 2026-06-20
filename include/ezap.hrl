-ifndef(ezap_hrl).
-define(ezap_hrl,1).

-include("ezap_records.hrl").

-type annotation() :: ezap:annotation().
-type bit_count() :: ezap:bit_count().
-type const() :: ezap:const().
-type data() :: ezap:data().
-type element_size() :: ezap:element_size().
-type enum() :: ezap:enum().
-type enum_values() :: ezap:enum_values().
-type far_ref() :: ezap:far_ref().
-type field_name() :: ezap:field_name().
-type field_type() :: ezap:field_type().
-type field_value() :: ezap:field_value().
-type group() :: ezap:group().
-type interface() :: ezap:interface().
-type list_ref() :: ezap:list_ref().
-type message() :: ezap:message().
-type msg() :: ezap:msg().
-type node_type() :: ezap:node_type().
-type node_types() :: ezap:node_types().
-type object() :: ezap:object().
-type object_field() :: ezap:object_field().
-type object_fields() :: ezap:object_fields().
-type ptr() :: ezap:ptr().
-type ptr_count() :: ezap:ptr_count().
-type ptr_index() :: ezap:ptr_index().
-type ref() :: ezap:ref().
-type ref_kind() :: ezap:ref_kind().
-type schema() :: ezap:schema().
-type schema_kind() :: ezap:schema_kind().
-type schema_node() :: ezap:schema_node().
-type schema_nodes() :: ezap:schema_nodes().
-type schema_type() :: ezap:schema_type().
-type segment_id() :: ezap:segment_id().
-type segment_offset() :: ezap:segment_offset().
-type segment_pos() :: ezap:segment_pos().
-type struct() :: ezap:struct().
-type struct_fields() :: ezap:struct_fields().
-type struct_ref() :: ezap:struct_ref().
-type text() :: ezap:text().
-type type_id() :: ezap:type_id().
-type type_name() :: ezap:type_name().
-type value() :: ezap:value().
-type value_type() :: ezap:value_type().
-type word_count() :: ezap:word_count().


-ifdef(EZAP_TRACE).

-ifndef(EZAP_GEN_OPTS).
-define(EZAP_GEN_OPTS,[{debug, [trace]}]).
-endif.

-define(EZAP_DEBUG,1).

-else.

-ifndef(EZAP_GEN_OPTS).
-define(EZAP_GEN_OPTS,[]).
-endif.

-endif.

-ifndef(EZAP_DEBUG).
-define(DBG(F,A),ok).
-define(DUMP(D),).

-else.
-define(DBG(F,A),
        _ = io:format(%%standard_error,
                      "~-10w ~20s:~-4w\t~s~n",
                      [self(), ?MODULE, ?LINE, io_lib:format(F, A)])
       ).
-define(DUMP(D), ezap:dump(D)).

-endif.

-endif.
