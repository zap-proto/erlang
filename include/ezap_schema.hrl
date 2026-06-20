%% ezap schema records
%%
%% Bump version number on ANY change in ANY of the records in this file.
%% Must have the same version in both ezap runtime libs and compiled schemas.
-ezap_schema_version(4).

%% Common record for all schema nodes
-record(schema_node, {
          module :: atom(),
          name :: ezap:type_name(),
          id = 0 :: ezap:type_id(),
          src = <<>> :: ezap:text(),
          kind = file :: ezap:schema_kind(),
          annotations = [] :: list(),
          nodes = [] :: ezap:schema_nodes(),
          scope = 0 :: ezap:type_id()
         }).

%% Struct node
-record(struct, {
          dsize = 0 :: ezap:word_count(),
          psize = 0 :: ezap:ptr_count(),
          esize = inlineComposite :: ezap:element_size(),
          union_field = none :: none | ezap:field_type(),
          fields = [] :: ezap:struct_fields()
         }).

%% Enum node
-record(enum, {
          values = [] :: ezap:enum_values()
         }).

%% Interface node
-record(interface, {
          extends = [] :: list(),
          methods = [] :: list()
         }).

%% Const node
-record(const, {
          field
         }).

%% Annotation node
-record(annotation, {
          type,
          targets = [] :: list(atom())
         }).

%% Struct field
-record(field, {
          id,
          name,
          kind,
          annotations = []
         }).

%% Schema Field types
-record(ptr, {
          type :: term(),
          idx = 0 :: ezap:ptr_index(),
          default = <<0:64/integer-little>> :: ezap:value()
         }).

-record(data, {
          type :: term(),
          align = 0 :: ezap:bit_count(),
          default :: ezap:value()
         }).

-record(group, {
          id = 0 :: ezap:type_id()
         }).

%% Interface methods
-record(method, {
          id,
          name,
          paramType,
          resultType
         }).
