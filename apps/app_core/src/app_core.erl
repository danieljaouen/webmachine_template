-module(app_core).
-export([start/0, start_link/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.

start_link() ->
    ensure_started(crypto),
    ensure_started(pooler),
    app_core_sup:start_link().

start() ->
    ensure_started(crypto),
    ensure_started(pooler),
    application:start(app_core).

stop() ->
    Res = application:stop(app_core),
    application:stop(crypto),
    application:stop(pooler),
    Res.
