-module(collect).

-export([start/1]).


start(0) ->
	stats:result();

start(Workers) ->
	receive
		over ->	start(Workers-1)
	end.
