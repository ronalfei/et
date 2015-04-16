-module(worker1).

-export([start/1]).

start(Times) ->
	File = "/home/users/wangfei19/workbench/tcpclient/testdata",
	Payload = get_data(File),
	St = os:timestamp(),
	%%loop(Times, Payload),
	{Timetc, _Value} =timer:tc(fun() -> loop(Times, Payload) end ),
	Se = os:timestamp(),
	Tdiff = timer:now_diff(Se, St),
	%Qps = Times div Tdiff/1000000,
	Qps = Times / (Timetc/1000000),
	io:format("timetc:~p, timediff:~p , worker jobs: ~p, start:~p, end:~p, Qps:~p~n", [Timetc, Tdiff, Times, St, Se, Qps]).


loop(0, _Payload) ->
	ok;
loop(Times, Payload) ->
	{ok, Socket} = gen_tcp:connect({10,95,31,38}, 9507, [ {active, false}, binary, {packet, 0} ]),
	send(Socket, Payload),
	close(Socket),
	loop(Times-1, Payload).


close(Socket) ->
	gen_tcp:close(Socket).


send(Socket, Payload) ->
	gen_tcp:send(Socket, Payload).


get_data(File) ->
	{ok, Bin} = file:read_file(File),
	Bin.
