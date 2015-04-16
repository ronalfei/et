-module(config).

-export([get/1]).


get(workers) ->
	{ok,[[{workers, Workers}, {requests, _Requests}]]} = file:consult("config"),
	io:format("workers is :~p~n", [Workers]),
	Workers;
get(requests) ->
	{ok,[[{workers, _Workers}, {requests, Requests}]]} = file:consult("config"),
	io:format("request is :~p~n", [Requests]),
	Requests;
get(_) ->
	{ok,[[{workers, Workers}, {requests, Requests}]]} = file:consult("config"),
	{Workers, Requests}.
