#!/usr/bin/env escript 
%% -*- erlang -*-
%%! -boot start_sasl -sname test@localhost +K true -P 134217727 -Q 134217727 -env  ERL_MAX_PORTS 409600  -setcookie edu_dp 
main([]) ->
    try
		spawn(manager, start,[]),
		io:format("use ctrl+c to end scripte\n"),
		receive
			_ -> ok
		after 1000  ->  io:format("doing"), loop()
		end
    catch
        _:_ ->
            usage()
    end;
main(_) ->
    usage().

loop() ->
	receive
		_ -> ok
	after 1000 -> io:format("."), loop()
	end.

usage() ->
    io:format("usage: factorial integer\n"),
    halt(1).
