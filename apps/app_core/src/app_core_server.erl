-module(app_core_server).
-behaviour(gen_server).
-define(SERVER, ?MODULE).
-define(BUCKET, <<"test_bucket">>).

-export(
    [
        start_link/0,
        save_term/1,
        retrieve_term/1
    ]
).

-export(
    [
        init/1,
        handle_call/3,
        handle_cast/2,
        handle_info/2,
        terminate/2,
        code_change/3
    ]
).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

save_term(Term) ->
    gen_server:call(?SERVER, {save_term, Term}, infinity).

retrieve_term(Term) ->
    gen_server:call(?SERVER, {retrieve_term, Term}, infinity).

init(Args) ->
    {ok, Args}.

handle_call({save_term, Term}, _From, State) ->
    Key = proplists:get_value(key, Term),
    {ok, SavedTerm} = pooler:use_member(fun(RiakPid) -> app_riak:put_term(RiakPid, ?BUCKET, Key, Term) end),
    {reply, SavedTerm, State};
handle_call({retrieve_term, Term}, _From, State) ->
    Key = proplists:get_value(key, Term),
    {ok, RetrievedTerm} = pooler:use_member(fun(RiakPid) -> app_riak:get_term(RiakPid, ?BUCKET, Key, Term) end),
    {reply, RetrievedTerm, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
