-module(app_web_term_resource).
-export([init/1, to_html/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

to_html(ReqData, State) ->
    PathInfo = wrq:path_info(ReqData),
    Key = proplists:get_value(key, PathInfo),
    {ok, RetrievedTerm} = app_core_server:retrieve_term(Key),
    {ok, Content} = sample_dtl:render([{param, RetrievedTerm}]),
    {Content, ReqData, State}.
