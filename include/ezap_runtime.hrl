-record(builder, {
          pid :: pid()
         }).

-record(reader, {
          data :: list(binary()) | binary(),
          caps = [] :: list()
         }).

-record(ref, {
          segment :: ezap:segment_id(),
          pos = -1 :: ezap:segment_pos(),
          offset = 0 :: ezap:segment_offset(), %% or capability index in CapTable for #interface_ref{}'s
          align = 0 :: ezap:bit_count(),
          kind = null :: ezap:ref_kind(),
          data :: #builder{} | #reader{}
         }).

-record(struct_ref, {
          dsize = 0 :: ezap:word_count(),
          psize = 0 :: ezap:ptr_count()
         }).

-record(list_ref, {
          size = 0 :: ezap:bit_count() | pointer | {inlineComposite, #struct_ref{}},
          count = 0 :: non_neg_integer() %% ALWAYS number of elements in list
         }).

-record(far_ref, {
          segment = 0 :: non_neg_integer(),
          double_far = false :: boolean()
         }).

-record(interface_ref, {
          owner :: {atom(), pid()},
          id :: term()
         }).

-record(object, {
          ref = null :: #ref{},
          schema :: atom() | ezap:schema_node()
         }).

-record(rpc_call, {
          target :: term(),
          interface :: ezap:type_id(),
          method :: non_neg_integer(),
          params :: ezap:object(),
          results :: ezap:object(),
          resultSchema = object :: ezap:schema_node() | object
         }).

-record(promise, {
          owner :: {atom(), pid()},
          pid :: pid(), %% ezap_promise pid
          transform = [] :: list(),
          schema :: ezap:schema_node()
         }).
