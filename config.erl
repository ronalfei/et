-module(config).

-export([get/1, get/2, init/0, init_ets/1]).

init() ->
    Result = file:consult("config"),
    case Result of
        {ok, Term} ->
            init_ets(Term);
        {error, _} ->
            io:format("[ETS Init fail] Read File Error~n~n"),
            error;
        _ ->
            error
    end.

init_ets(Term) ->
    try
        ets:new(config, [named_table, public]),
        ParentPID = erlang:group_leader(),
        ets:give_away(config, ParentPID, []),
        ets:insert(config, Term)
    catch A:B ->
		io:format("init ets table warning:~p   + ~p~n", [A, B]),
		ets:delete_all_objects(config)
    end.

get(Key) ->
    Value = ets:lookup(config, Key),
    get(Key, Value).

get(Key, []) ->
    none;
get(Key, [H|T]) ->
    case H of
        {Key, Value} -> Value;
        Other ->
            get(Key, T)
    end.
