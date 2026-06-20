# Options for erlang.mk
PROJECT = ezap

#test%: TEST_ERLC_OPTS += -DEUNIT_NOAUTO

CT_SUITES = proper #eunit
PLT_APPS = crypto
EDOC_OPTS = preprocess, {dir, "doc/html"}

EUNIT_OPTS = no_tty, {report, {eunit_progress, [colored]}}
EUNIT_DIR = test

# call `make tests TEST_DEPS=` after the first run in order to skip
# the `make all` for all test deps.. (which for meck using rebar is
# sloooow... :/ )
TEST_DEPS ?= meck proper eunit_formatters

dep_meck = https://github.com/eproxus/meck.git master
dep_proper = pkg://proper master
dep_eunit_formatters = git https://github.com/seancribbs/eunit_formatters master

include erlang.mk

# erlang.mk bootstrapping
# erlang.mk: erlang_mk_url ?= \
# 	http://raw.github.com/extend/erlang.mk/master/erlang.mk

# erlang.mk:
# 	@echo " GET   " $@; wget -O $@ $(erlang_mk_url)

# build rules for .zap files
%.zap.hrl: %.zap
	$(gen_verbose) zapc -oerl $<

%_zap.erl: %.zap | ebin
	$(gen_verbose) EZAP_TO_ERL=../$(dir $@) zapc\
		-oerl:ebin --src-prefix=$(dir $<) $<

ebin:
	@mkdir -p ebin

# make sure we rebuild on any header file change
%.erl: include/*.hrl include/*/*.hrl ; @touch $@

# zap_test integration
dep_zap_test = https://github.com/zap-proto/zap_test.git
$(eval $(call dep_target,zap_test))

bin/test.zap.hrl: $(DEPS_DIR)/zap_test/test.zap
	zapc -oerl:$(dir $@) --src-prefix=$(dir $<) $<

.PHONY: check
check:: export ZAP_TEST_APP = $(CURDIR)/bin/ezap_test
check:: $(DEPS_DIR)/zap_test bin/test.zap.hrl
	$(MAKE) -C $<


# DEV/TEST-only target..
# call it as `make dbg PROP=text_data LINE=117`
# will dump you attached to a process running the text_data prop test,
# on line 117
# Currently we need ezap on the erlang lib path.. will fix that eventually..
.PHONY: bld dbg tst e p
bld: TEST_DEPS=
bld: TEST_ERLC_OPTS += -DEUNIT_NOAUTO
bld: app build-tests

dbg: bld
	erl -pa ebin test -eval \
		"begin\
			[i:ii(M) || M <- [ezap, ezap_obj, ezap_get, ezap_set,\
				ezap_props, ezap_ref, ezap_data]],\
			i:ib(ezap_props, $(LINE)),\
			i:iaa([break]),\
			proper:quickcheck(ezap_props:prop_$(PROP)())\
		end"

tst: e p

erl: bld
	erl -pa ebin test priv/samples -eval \
		"[i:ii(M) || M <- [ezap, ezap_obj, ezap_get, ezap_set,\
			ezap_ref, ezap_data, ezap_schema, ezap_get_tests,\
			ezap_set_tests, ezap_rpc, ezap_rpc_tests, ezap_vat,\
			ezap_vat_tests, ezap_capability, ezap_capability_sup,\
			ezap_ref_tests, 'calculator-server']]"

e: bld
	erl -pa ebin test -pa deps/meck/ebin -noinput \
		-eval "case eunit:test(\"test\", [no_tty, {report, {eunit_progress,\
				[colored]}}]) of ok -> halt(0); _ -> halt(1) end"

p: bld
	erl -pa ebin test -noinput \
		-eval "proper:module(ezap_props), init:stop()"

.PHONY: samples
samples: app
	cd priv/samples && ./run_samples.sh
