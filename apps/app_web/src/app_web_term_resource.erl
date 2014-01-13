-module(app_web_term_resource).
-export([init/1, to_html/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

to_html(ReqData, State) ->
    PathInfo = wrq:path_info(ReqData),
    Key = proplists:get_value(key, PathInfo),
    {ok, Content} = case app_core_server:retrieve_term(Key) of
        {ok, RetrievedTerm} ->
            sample_dtl:render([{param, RetrievedTerm}]);
        {error, notfound} ->
            sample_dtl:render([{param, "not found"}])
    end,
    {Content, ReqData, State}.
