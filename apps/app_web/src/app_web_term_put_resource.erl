-module(app_web_term_put_resource).
-export(
    [
        init/1,
        allowed_methods/2,
        to_html/2
    ]
).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

allowed_methods(_ReqData, _State) ->
    ['PUT'].

to_html(ReqData, State) ->
    PathInfo = wrq:path_info(ReqData),
    Key = proplists:get_value(key, PathInfo),
    String = proplists:get_value(string, PathInfo),
    Term = [{key, Key}, {value, String}],
    Content = case app_core_server:save_term(Term) of
        {ok, FetchedTerm} ->
            sample_dtl:render([{param, FetchedTerm}]);
        {error, notfound} ->
            sample_dtl:render([{param, "not found"}])
    end,
    {Content, ReqData, State}.
