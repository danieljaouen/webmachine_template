-module(app_core_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Server = ?CHILD(app_core_server, worker),
    Processes = [Server],
    {ok, { {one_for_one, 5, 10}, Processes} }.
