ERL ?= erl
APP := app_web

.PHONY: deps

all: deps
	@./rebar compile

app:
	@./rebar compile skip_deps=true

deps:
	@./rebar get-deps

clean:
	@./rebar clean

distclean: clean
	@./rebar delete-deps

docs:
	@erl -noshell -run edoc_run application '$(APP)' '"."' '[]'

webstart: app
	exec erl -pa $(PWD)/apps/*/ebin -pa $(PWD)/deps/*/ebin -boot start_sasl -config $(PWD)/apps/csd_web/priv/app.config -config $(PWD)/apps/csd_core/priv/app.config -s reloader -s app_core -s app_web

proxystart:
	@haproxy -f $(PWD)/priv/conf/dev.haproxy.conf
