-file("test.zap", 1).

%% This file was generated 2014-05-16 10:39:57 UTC by ezap 0.2.
%% https://github.com/zap-proto/erlang
-module(test_zap).

-vsn(16752831063434032545).

-export([schema/1, testAnno/0, testAnno/1, '17364400218949434058'/0, 'Test'/0, 'Test'/1,
	 '18038429679936549741'/0, '12292473172826227401'/0, '9356761420570873088'/0,
	 '12591081617868223671'/0, 'Simple'/0, 'Simple'/1, '15091335337902283752'/0, 'ListTest'/0,
	 'ListTest'/1, '17083831967670695846'/0, 'BasicCap'/0, 'BasicCap'/1, '17521612982906909583'/0,
	 '16325444167000491107'/0, '16351184016261359411'/0, '13875996178202423621'/0,
	 '10419494484650272988'/0, 'Pipelines'/0, 'Pipelines'/1, '16031390312538156137'/0,
	 '14503907271725109646'/0, '14869749728248688780'/0, 'OtherCap'/0, 'OtherCap'/1,
	 '10376444823742217855'/0, '18397524501497330844'/0, '14954489407150623152'/0, 'ThirdCap'/0,
	 'ThirdCap'/1, '18123859541809896974'/0, '14187451716366646039'/0, '16272584843106476340'/0,
	 'CapTest'/0, 'CapTest'/1, '17442731430661771208'/0, 'UnionTest'/0, 'UnionTest'/1,
	 '16940705001995499374'/0, 'PackedListTest'/0, 'PackedListTest'/1, '14810986415762040486'/0,
	 '17446286598800356999'/0, root/0, root/1, '16752831063434032545'/0]).

-types([{17364400218949434058, testAnno}, {18038429679936549741, 'Test'},
	{12292473172826227401, ['Test', meta]}, {9356761420570873088, ['Test', opts]},
	{12591081617868223671, ['Test', groupField]}, {15091335337902283752, 'Simple'},
	{17083831967670695846, 'ListTest'}, {17521612982906909583, 'BasicCap'},
	{16325444167000491107, ['BasicCap', [sub, '$Results']]},
	{16351184016261359411, ['BasicCap', [sub, '$Params']]},
	{13875996178202423621, ['BasicCap', [add, '$Results']]},
	{10419494484650272988, ['BasicCap', [add, '$Params']]}, {16031390312538156137, 'Pipelines'},
	{14503907271725109646, ['Pipelines', [getBasic, '$Results']]},
	{14869749728248688780, ['Pipelines', [getBasic, '$Params']]}, {10376444823742217855, 'OtherCap'},
	{18397524501497330844, ['OtherCap', [sqroot, '$Results']]},
	{14954489407150623152, ['OtherCap', [sqroot, '$Params']]}, {18123859541809896974, 'ThirdCap'},
	{14187451716366646039, ['ThirdCap', [square, '$Results']]},
	{16272584843106476340, ['ThirdCap', [square, '$Params']]}, {17442731430661771208, 'CapTest'},
	{16940705001995499374, 'UnionTest'}, {14810986415762040486, 'PackedListTest'},
	{17446286598800356999, ['PackedListTest', 'Opts']}, {16752831063434032545, root}]).

-file("/home/kaos/src/erl/libs/ezap/include/ezap_schema.hrl", 1).

-ezap_schema_version(3).

-record(schema_node,
	{module, name, id = 0, src = <<>>, kind = file, annotations = [], nodes = [], scope = 0}).


-record(struct, {dsize = 0, psize = 0, esize = inlineComposite, union_field = none, fields = []}).


-record(enum, {values = []}).


-record(interface, {extends = [], methods = []}).


-record(const, {field}).

-record(annotation, {type, targets = []}).


-record(field, {id, name, kind, annotations = []}).

-record(ptr, {type, idx = 0, default = null}).


-record(data, {type, align = 0, default}).


-record(group, {id = 0}).


-record(method, {id, name, paramType, resultType}).

-file("test.zap", 1).

schema(17364400218949434058) -> '17364400218949434058'();
schema(testAnno) -> '17364400218949434058'();
schema([testAnno]) -> '17364400218949434058'();
schema(18038429679936549741) -> '18038429679936549741'();
schema('Test') -> '18038429679936549741'();
schema(['Test']) -> '18038429679936549741'();
schema(12292473172826227401) -> '12292473172826227401'();
schema(['Test', meta]) -> '12292473172826227401'();
schema(9356761420570873088) -> '9356761420570873088'();
schema(['Test', opts]) -> '9356761420570873088'();
schema(12591081617868223671) -> '12591081617868223671'();
schema(['Test', groupField]) -> '12591081617868223671'();
schema(15091335337902283752) -> '15091335337902283752'();
schema('Simple') -> '15091335337902283752'();
schema(['Simple']) -> '15091335337902283752'();
schema(17083831967670695846) -> '17083831967670695846'();
schema('ListTest') -> '17083831967670695846'();
schema(['ListTest']) -> '17083831967670695846'();
schema(17521612982906909583) -> '17521612982906909583'();
schema('BasicCap') -> '17521612982906909583'();
schema(['BasicCap']) -> '17521612982906909583'();
schema(16325444167000491107) -> '16325444167000491107'();
schema(['BasicCap', [sub, '$Results']]) -> '16325444167000491107'();
schema(16351184016261359411) -> '16351184016261359411'();
schema(['BasicCap', [sub, '$Params']]) -> '16351184016261359411'();
schema(13875996178202423621) -> '13875996178202423621'();
schema(['BasicCap', [add, '$Results']]) -> '13875996178202423621'();
schema(10419494484650272988) -> '10419494484650272988'();
schema(['BasicCap', [add, '$Params']]) -> '10419494484650272988'();
schema(16031390312538156137) -> '16031390312538156137'();
schema('Pipelines') -> '16031390312538156137'();
schema(['Pipelines']) -> '16031390312538156137'();
schema(14503907271725109646) -> '14503907271725109646'();
schema(['Pipelines', [getBasic, '$Results']]) -> '14503907271725109646'();
schema(14869749728248688780) -> '14869749728248688780'();
schema(['Pipelines', [getBasic, '$Params']]) -> '14869749728248688780'();
schema(10376444823742217855) -> '10376444823742217855'();
schema('OtherCap') -> '10376444823742217855'();
schema(['OtherCap']) -> '10376444823742217855'();
schema(18397524501497330844) -> '18397524501497330844'();
schema(['OtherCap', [sqroot, '$Results']]) -> '18397524501497330844'();
schema(14954489407150623152) -> '14954489407150623152'();
schema(['OtherCap', [sqroot, '$Params']]) -> '14954489407150623152'();
schema(18123859541809896974) -> '18123859541809896974'();
schema('ThirdCap') -> '18123859541809896974'();
schema(['ThirdCap']) -> '18123859541809896974'();
schema(14187451716366646039) -> '14187451716366646039'();
schema(['ThirdCap', [square, '$Results']]) -> '14187451716366646039'();
schema(16272584843106476340) -> '16272584843106476340'();
schema(['ThirdCap', [square, '$Params']]) -> '16272584843106476340'();
schema(17442731430661771208) -> '17442731430661771208'();
schema('CapTest') -> '17442731430661771208'();
schema(['CapTest']) -> '17442731430661771208'();
schema(16940705001995499374) -> '16940705001995499374'();
schema('UnionTest') -> '16940705001995499374'();
schema(['UnionTest']) -> '16940705001995499374'();
schema(14810986415762040486) -> '14810986415762040486'();
schema('PackedListTest') -> '14810986415762040486'();
schema(['PackedListTest']) -> '14810986415762040486'();
schema(17446286598800356999) -> '17446286598800356999'();
schema(['PackedListTest', 'Opts']) -> '17446286598800356999'();
schema(16752831063434032545) -> '16752831063434032545'();
schema(root) -> '16752831063434032545'();
schema([root]) -> '16752831063434032545'();
schema(_) -> undefined.

root() -> '16752831063434032545'().

root([]) -> '16752831063434032545'().

'16752831063434032545'() ->
    #schema_node{module = test_zap, name = root, id = 16752831063434032545, scope = 0,
		 src = <<"test.zap">>, annotations = [{17364400218949434058, <<"file anno 2013">>}], kind = file,
		 nodes =
		     [17364400218949434058,  %% testAnno
		      18038429679936549741,  %% Test
		      15091335337902283752,  %% Simple
		      17083831967670695846,  %% ListTest
		      17521612982906909583,  %% BasicCap
		      16031390312538156137,  %% Pipelines
		      10376444823742217855,  %% OtherCap
		      18123859541809896974,  %% ThirdCap
		      17442731430661771208,  %% CapTest
		      16940705001995499374,  %% UnionTest
		      14810986415762040486]}.  %% PackedListTest

'PackedListTest'() -> '14810986415762040486'().

'PackedListTest'(['Opts']) -> '17446286598800356999'();
'PackedListTest'([]) -> '14810986415762040486'().

'14810986415762040486'() ->
    #schema_node{module = test_zap, name = 'PackedListTest', id = 14810986415762040486,
		 scope = 16752831063434032545, src = <<"test.zap:PackedListTest">>,
		 kind =
		     #struct{dsize = 0, psize = 1, esize = pointer, union_field = none,
			     fields =
				 [#field{id = 0, name = packedList,
					 kind =
					     #ptr{type = {list, {struct, 17446286598800356999}}, idx = 0,
						  default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]},
		 nodes =
		     [17446286598800356999]}.  %% Opts

'17446286598800356999'() ->
    #schema_node{module = test_zap, name = ['PackedListTest', 'Opts'], id = 17446286598800356999,
		 scope = 14810986415762040486, src = <<"test.zap:PackedListTest.Opts">>,
		 kind =
		     #struct{dsize = 1, psize = 0, esize = twoBytes, union_field = none,
			     fields =
				 [#field{id = 0, name = flag, kind = #data{type = bool, align = 7, default = <<0:1>>}},
				  #field{id = 1, name = value, kind = #data{type = uint8, align = 8, default = <<0>>}},
				  #field{id = 2, name = toggle, kind = #data{type = bool, align = 6, default = <<0:1>>}}]}}.

'UnionTest'() -> '16940705001995499374'().

'UnionTest'([]) -> '16940705001995499374'().

'16940705001995499374'() ->
    #schema_node{module = test_zap, name = 'UnionTest', id = 16940705001995499374,
		 scope = 16752831063434032545, src = <<"test.zap:UnionTest">>,
		 kind =
		     #struct{dsize = 1, psize = 1, esize = inlineComposite,
			     union_field =
				 #data{type =
					   {union,
					    [#field{id = 0, name = foo, kind = #data{type = bool, align = 7, default = <<0:1>>}},
					     #field{id = 1, name = test,
						    kind = #ptr{type = {struct, 18038429679936549741}, idx = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}},
					     #field{id = 2, name = any,
						    kind = #ptr{type = object, idx = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]},
				       align = 16, default = <<0, 0>>},
			     fields = []}}.

'CapTest'() -> '17442731430661771208'().

'CapTest'([]) -> '17442731430661771208'().

'17442731430661771208'() ->
    #schema_node{module = test_zap, name = 'CapTest', id = 17442731430661771208,
		 scope = 16752831063434032545, src = <<"test.zap:CapTest">>,
		 kind =
		     #struct{dsize = 0, psize = 2, esize = inlineComposite, union_field = none,
			     fields =
				 [#field{id = 0, name = basic,
					 kind =
					     #ptr{type = {interface, 17521612982906909583}, idx = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}},
				  #field{id = 1, name = obj,
					 kind = #ptr{type = object, idx = 1, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'ThirdCap'() -> '18123859541809896974'().

'ThirdCap'([[square, '$Results']]) -> '14187451716366646039'();
'ThirdCap'([[square, '$Params']]) -> '16272584843106476340'();
'ThirdCap'([]) -> '18123859541809896974'().

'18123859541809896974'() ->
    #schema_node{module = test_zap, name = 'ThirdCap', id = 18123859541809896974,
		 scope = 16752831063434032545, src = <<"test.zap:ThirdCap">>,
		 kind =
		     #interface{extends = [17521612982906909583, 10376444823742217855],
				methods =
				    [#method{id = 0, name = square, paramType = 16272584843106476340,
					     resultType = 14187451716366646039}]}}.

'14187451716366646039'() ->
    #schema_node{module = test_zap, name = ['ThirdCap', [square, '$Results']],
		 id = 14187451716366646039, scope = 0, src = <<"test.zap:ThirdCap.square$Results">>,
		 kind =
		     #struct{dsize = 1, psize = 0, esize = eightBytes, union_field = none,
			     fields =
				 [#field{id = 0, name = sq,
					 kind = #data{type = int64, align = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'16272584843106476340'() ->
    #schema_node{module = test_zap, name = ['ThirdCap', [square, '$Params']],
		 id = 16272584843106476340, scope = 0, src = <<"test.zap:ThirdCap.square$Params">>,
		 kind =
		     #struct{dsize = 1, psize = 0, esize = eightBytes, union_field = none,
			     fields =
				 [#field{id = 0, name = a,
					 kind = #data{type = int64, align = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'OtherCap'() -> '10376444823742217855'().

'OtherCap'([[sqroot, '$Results']]) -> '18397524501497330844'();
'OtherCap'([[sqroot, '$Params']]) -> '14954489407150623152'();
'OtherCap'([]) -> '10376444823742217855'().

'10376444823742217855'() ->
    #schema_node{module = test_zap, name = 'OtherCap', id = 10376444823742217855,
		 scope = 16752831063434032545, src = <<"test.zap:OtherCap">>,
		 kind =
		     #interface{extends = [],
				methods =
				    [#method{id = 0, name = sqroot, paramType = 14954489407150623152,
					     resultType = 18397524501497330844}]}}.

'18397524501497330844'() ->
    #schema_node{module = test_zap, name = ['OtherCap', [sqroot, '$Results']],
		 id = 18397524501497330844, scope = 0, src = <<"test.zap:OtherCap.sqroot$Results">>,
		 kind =
		     #struct{dsize = 2, psize = 0, esize = inlineComposite, union_field = none,
			     fields =
				 [#field{id = 0, name = root1,
					 kind = #data{type = float64, align = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}},
				  #field{id = 1, name = root2,
					 kind = #data{type = float64, align = 64, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'14954489407150623152'() ->
    #schema_node{module = test_zap, name = ['OtherCap', [sqroot, '$Params']],
		 id = 14954489407150623152, scope = 0, src = <<"test.zap:OtherCap.sqroot$Params">>,
		 kind =
		     #struct{dsize = 1, psize = 0, esize = eightBytes, union_field = none,
			     fields =
				 [#field{id = 0, name = a,
					 kind = #data{type = int64, align = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'Pipelines'() -> '16031390312538156137'().

'Pipelines'([[getBasic, '$Results']]) -> '14503907271725109646'();
'Pipelines'([[getBasic, '$Params']]) -> '14869749728248688780'();
'Pipelines'([]) -> '16031390312538156137'().

'16031390312538156137'() ->
    #schema_node{module = test_zap, name = 'Pipelines', id = 16031390312538156137,
		 scope = 16752831063434032545, src = <<"test.zap:Pipelines">>,
		 kind =
		     #interface{extends = [],
				methods =
				    [#method{id = 0, name = getBasic, paramType = 14869749728248688780,
					     resultType = 14503907271725109646}]}}.

'14503907271725109646'() ->
    #schema_node{module = test_zap, name = ['Pipelines', [getBasic, '$Results']],
		 id = 14503907271725109646, scope = 0, src = <<"test.zap:Pipelines.getBasic$Results">>,
		 kind =
		     #struct{dsize = 0, psize = 1, esize = pointer, union_field = none,
			     fields =
				 [#field{id = 0, name = basic,
					 kind =
					     #ptr{type = {interface, 17521612982906909583}, idx = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'14869749728248688780'() ->
    #schema_node{module = test_zap, name = ['Pipelines', [getBasic, '$Params']],
		 id = 14869749728248688780, scope = 0, src = <<"test.zap:Pipelines.getBasic$Params">>,
		 kind = #struct{dsize = 0, psize = 0, esize = empty, union_field = none, fields = []}}.

'BasicCap'() -> '17521612982906909583'().

'BasicCap'([[sub, '$Results']]) -> '16325444167000491107'();
'BasicCap'([[sub, '$Params']]) -> '16351184016261359411'();
'BasicCap'([[add, '$Results']]) -> '13875996178202423621'();
'BasicCap'([[add, '$Params']]) -> '10419494484650272988'();
'BasicCap'([]) -> '17521612982906909583'().

'17521612982906909583'() ->
    #schema_node{module = test_zap, name = 'BasicCap', id = 17521612982906909583,
		 scope = 16752831063434032545, src = <<"test.zap:BasicCap">>,
		 kind =
		     #interface{extends = [],
				methods =
				    [#method{id = 0, name = add, paramType = 10419494484650272988, resultType = 13875996178202423621},
				     #method{id = 1, name = sub, paramType = 16351184016261359411, resultType = 16325444167000491107}]}}.

'16325444167000491107'() ->
    #schema_node{module = test_zap, name = ['BasicCap', [sub, '$Results']], id = 16325444167000491107,
		 scope = 0, src = <<"test.zap:BasicCap.sub$Results">>,
		 kind =
		     #struct{dsize = 1, psize = 0, esize = eightBytes, union_field = none,
			     fields =
				 [#field{id = 0, name = result,
					 kind = #data{type = int64, align = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'16351184016261359411'() ->
    #schema_node{module = test_zap, name = ['BasicCap', [sub, '$Params']], id = 16351184016261359411,
		 scope = 0, src = <<"test.zap:BasicCap.sub$Params">>,
		 kind =
		     #struct{dsize = 2, psize = 0, esize = inlineComposite, union_field = none,
			     fields =
				 [#field{id = 0, name = a,
					 kind = #data{type = int64, align = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}},
				  #field{id = 1, name = b,
					 kind = #data{type = int64, align = 64, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'13875996178202423621'() ->
    #schema_node{module = test_zap, name = ['BasicCap', [add, '$Results']], id = 13875996178202423621,
		 scope = 0, src = <<"test.zap:BasicCap.add$Results">>,
		 kind =
		     #struct{dsize = 1, psize = 0, esize = eightBytes, union_field = none,
			     fields =
				 [#field{id = 0, name = result,
					 kind = #data{type = int64, align = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'10419494484650272988'() ->
    #schema_node{module = test_zap, name = ['BasicCap', [add, '$Params']], id = 10419494484650272988,
		 scope = 0, src = <<"test.zap:BasicCap.add$Params">>,
		 kind =
		     #struct{dsize = 2, psize = 0, esize = inlineComposite, union_field = none,
			     fields =
				 [#field{id = 0, name = a,
					 kind = #data{type = int64, align = 0, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}},
				  #field{id = 1, name = b,
					 kind = #data{type = int64, align = 64, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'ListTest'() -> '17083831967670695846'().

'ListTest'([]) -> '17083831967670695846'().

'17083831967670695846'() ->
    #schema_node{module = test_zap, name = 'ListTest', id = 17083831967670695846,
		 scope = 16752831063434032545, src = <<"test.zap:ListTest">>,
		 kind =
		     #struct{dsize = 0, psize = 4, esize = inlineComposite, union_field = none,
			     fields =
				 [#field{id = 0, name = listInts,
					 kind =
					     #ptr{type = {list, int32}, idx = 0,
						  default = <<1, 0, 0, 0, 28, 0, 0, 0, 200, 1, 0, 0, 21, 3, 0, 0, 133, 255, 255, 255, 0, 0, 0, 0>>}},
				  #field{id = 1, name = listAny,
					 kind = #ptr{type = object, idx = 1, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}},
				  #field{id = 2, name = listSimples,
					 kind =
					     #ptr{type = {list, {struct, 15091335337902283752}}, idx = 2,
						  default =
						      <<1, 0, 0, 0, 55, 0, 0, 0, 8, 0, 0, 0, 1, 0, 2, 0, 223, 0, 0, 0, 0, 0, 0, 0, 17, 0, 0, 0, 50, 0, 0,
							0, 0, 0, 0, 0, 0, 0, 0, 0, 220, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 58, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							0, 102, 105, 114, 115, 116, 0, 0, 0, 115, 101, 99, 111, 110, 100, 0, 0>>}},
				  #field{id = 3, name = listText,
					 kind = #ptr{type = {list, text}, idx = 3, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'Simple'() -> '15091335337902283752'().

'Simple'([]) -> '15091335337902283752'().

'15091335337902283752'() ->
    #schema_node{module = test_zap, name = 'Simple', id = 15091335337902283752,
		 scope = 16752831063434032545, src = <<"test.zap:Simple">>,
		 kind =
		     #struct{dsize = 1, psize = 2, esize = inlineComposite, union_field = none,
			     fields =
				 [#field{id = 0, name = message, kind = #ptr{type = text, idx = 0, default = <<"default message">>}},
				  #field{id = 1, name = value, kind = #data{type = uint32, align = 0, default = <<222, 0, 0, 0>>}},
				  #field{id = 2, name = simpleMessage,
					 kind = #ptr{type = text, idx = 1, default = <<"simple message">>}},
				  #field{id = 3, name = defaultValue,
					 kind = #data{type = uint32, align = 32, default = <<77, 1, 0, 0>>}}]}}.

'Test'() -> '18038429679936549741'().

'Test'([meta]) -> '12292473172826227401'();
'Test'([opts]) -> '9356761420570873088'();
'Test'([groupField]) -> '12591081617868223671'();
'Test'([]) -> '18038429679936549741'().

'18038429679936549741'() ->
    #schema_node{module = test_zap, name = 'Test', id = 18038429679936549741,
		 scope = 16752831063434032545, src = <<"test.zap:Test">>,
		 annotations = [{17364400218949434058, <<"Test struct anno 2013 too">>}],
		 kind =
		     #struct{dsize = 2, psize = 6, esize = inlineComposite,
			     union_field =
				 #data{type =
					   {union,
					    [#field{id = 0, name = boolField, kind = #data{type = bool, align = 15, default = <<0:1>>}},
					     #field{id = 1, name = groupField, kind = #group{id = 12591081617868223671}}]},
				       align = 16, default = <<0, 0>>},
			     fields =
				 [#field{id = 0, name = intField, kind = #data{type = uint8, align = 0, default = <<33>>}},
				  #field{id = 1, name = textField, kind = #ptr{type = text, idx = 0, default = <<"test">>}},
				  #field{id = 2, name = opts, kind = #group{id = 9356761420570873088}},
				  #field{id = 3, name = meta, kind = #group{id = 12292473172826227401}},
				  #field{id = 4, name = structField,
					 kind =
					     #ptr{type = {struct, 15091335337902283752}, idx = 4, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'12292473172826227401'() ->
    #schema_node{module = test_zap, name = ['Test', meta], id = 12292473172826227401,
		 scope = 18038429679936549741, src = <<"test.zap:Test.meta">>,
		 kind =
		     #struct{dsize = 2, psize = 6, esize = inlineComposite, union_field = none,
			     fields =
				 [#field{id = 0, name = id, kind = #data{type = uint16, align = 80, default = <<0, 0>>}},
				  #field{id = 1, name = tag, kind = #ptr{type = text, idx = 2, default = <<"">>}},
				  #field{id = 2, name = data, kind = #ptr{type = data, idx = 3, default = <<49, 50, 51, 52>>}},
				  #field{id = 3, name = struct,
					 kind =
					     #ptr{type = {struct, 15091335337902283752}, idx = 5,
						  default =
						      <<0, 0, 0, 0, 1, 0, 2, 0, 0, 0, 0, 0, 12, 0, 0, 0, 5, 0, 0, 0, 210, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							111, 118, 101, 114, 114, 105, 100, 101, 110, 32, 100, 101, 102, 97, 117, 108, 116, 32, 109, 101,
							115, 115, 97, 103, 101, 0, 0, 0, 0, 0, 0, 0>>}}]}}.

'9356761420570873088'() ->
    #schema_node{module = test_zap, name = ['Test', opts], id = 9356761420570873088,
		 scope = 18038429679936549741, src = <<"test.zap:Test.opts">>,
		 kind =
		     #struct{dsize = 2, psize = 6, esize = inlineComposite,
			     union_field =
				 #data{type =
					   {union,
					    [#field{id = 0, name = bool, kind = #data{type = bool, align = 55, default = <<1:1>>}},
					     #field{id = 1, name = text, kind = #ptr{type = text, idx = 1, default = <<"">>}},
					     #field{id = 2, name = data, kind = #ptr{type = data, idx = 1, default = <<>>}},
					     #field{id = 3, name = object,
						    kind = #ptr{type = object, idx = 1, default = <<0, 0, 0, 0, 0, 0, 0, 0>>}}]},
				       align = 64, default = <<0, 0>>},
			     fields = []}}.

'12591081617868223671'() ->
    #schema_node{module = test_zap, name = ['Test', groupField], id = 12591081617868223671,
		 scope = 18038429679936549741, src = <<"test.zap:Test.groupField">>,
		 kind =
		     #struct{dsize = 2, psize = 6, esize = inlineComposite, union_field = none,
			     fields =
				 [#field{id = 0, name = a, kind = #data{type = int8, align = 8, default = <<212>>}},
				  #field{id = 1, name = b, kind = #data{type = int8, align = 32, default = <<55>>}},
				  #field{id = 2, name = c, kind = #data{type = int8, align = 40, default = <<0>>}}]}}.

testAnno() -> '17364400218949434058'().

testAnno([]) -> '17364400218949434058'().

'17364400218949434058'() ->
    #schema_node{module = test_zap, name = testAnno, id = 17364400218949434058,
		 scope = 16752831063434032545, src = <<"test.zap:testAnno">>,
		 kind =
		     #annotation{type = #ptr{type = text, idx = 0, default = <<>>},
				 targets =
				     [targetsFile, targetsConst, targetsEnum, targetsEnumerant, targetsStruct, targetsField,
				      targetsUnion, targetsGroup, targetsInterface, targetsMethod, targetsParam, targetsAnnotation]}}.