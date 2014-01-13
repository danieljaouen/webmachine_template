-module(app_riak).
-export([
    put_object/2,
    get_object/3,
    put_json/4,
    get_json/3,
    put_term/4,
    get_term/3
]).

prep_term(Term, Key) ->
    case proplists:get_value(Term, key) of
        undefined ->
            [{key, Key} | Term];
        _ ->
            Term
    end.

term_to_json(Term) ->
    jsx:encode(Term).

json_to_term(Json) ->
    jsx:decode(Json, [{labels, attempt_atom}]).

put_object(RiakPid, Object) ->
    riakc_pb_socket:put(RiakPid, Object),
    {ok, Object}.

get_object(RiakPid, Bucket, Key) ->
    case riakc_pb_socket:get(RiakPid, Bucket, Key) of
        {ok, FetchedObject} ->
            {ok, FetchedObject};
        {error, notfound} ->
            {error, notfound}
    end.

put_json(RiakPid, Bucket, Key, Json) ->
    case get_object(RiakPid, Bucket, Key) of
        {ok, FetchedObject} ->
            NewObject = riakc_obj:update_value(FetchedObject, Json, "application/json"),
            ok = riakc_pb_socket:put(RiakPid, NewObject),
            {ok, Json};
        {error, notfound} ->
            Object = riakc_obj:new(Bucket, Key, Json, "application/json"),
            ok = riakc_pb_socket:put(RiakPid, Object),
            {ok, Json}
    end.

get_json(RiakPid, Bucket, Key) ->
    case get_object(RiakPid, Bucket, Key) of
        {ok, Object} ->
            Json = riakc_obj:get_value(Object),
            {ok, Json};
        {error, notfound} ->
            {error, notfound}
    end.

put_term(RiakPid, Bucket, Key, Term) ->
    case get_object(RiakPid, Bucket, Key) of
        {ok, FetchedObject} ->
            TermWithKey = prep_term(Term, Key),
            Json = term_to_json(TermWithKey),
            NewObject = riakc_obj:update_value(FetchedObject, Json, "application/json"),
            ok = riakc_pb_socket:put(RiakPid, NewObject),
            {ok, TermWithKey};
        {error, notfound} ->
            TermWithKey = prep_term(Term, Key),
            Json = term_to_json(TermWithKey),
            Object = riakc_obj:new(Bucket, Key, Json, "application/json"),
            ok = riakc_pb_socket:put(RiakPid, Object),
            {ok, TermWithKey}
    end.

get_term(RiakPid, Bucket, Key) ->
    case get_json(RiakPid, Bucket, Key) of
        {ok, Json} ->
            Term = json_to_term(Json),
            {ok, Term};
        {error, notfound} ->
            {error, notfound}
    end.
