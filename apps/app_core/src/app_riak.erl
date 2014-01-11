-module(app_riak).

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
    {ok, FetchedObject} = riakc_pb_socket:get(RiakPid, Bucket, Key),
    FetchedObject.

put_json(RiakPid, Bucket, Key, Json) ->
    case get_object(RiakPid, Bucket, Key) of
        {ok, FetchedObject} ->
            NewObject = riakc_obj:update_value(FetchedObject, Json, "application/json"),
            ok = riakc_pb_socket:put(RiakPid, NewObject),
            {ok, Json};
        {error, not_found} ->
            Object = riakc_obj:new(Bucket, Key, Json, "application/json"),
            ok = riakc_pb_socket:put(RiakPid, Object),
            {ok, Json}
    end.

get_json(RiakPid, Bucket, Key) ->
    {ok, Object} = get_object(RiakPid, Bucket, Key),
    Json = riakc_obj:get_value(Object),
    {ok, Json}.

put_term(RiakPid, Bucket, Key, Term) ->
    case get_object(RiakPid, Bucket, Key) of
        {ok, FetchedObject} ->
            TermWithKey = prep_term(Term),
            Json = term_to_json(TermWithKey),
            NewObject = riakc_obj:update_value(FetchedObject, Json, "application/json"),
            ok = riakc_pb_socket:put(RiakPid, NewObject),
            {ok, TermWithKey};
        {error, not_found} ->
            TermWithKey = prep_term(Term),
            Json = term_to_json(TermWithKey),
            Object = riakc_obj:new(Bucket, Key, Json, "application/json"),
            ok = riakc_pb_socket:put(RiakPid, Object),
            {ok, TermWithKey}
    end.
