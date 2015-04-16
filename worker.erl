-module(worker).

-export([start/1]).

start(Times) ->
%10.95.31.38:9507
	St = os:timestamp(),
	File1 = "/home/users/wangfei19/workbench/tcpclient/request.dat",
	File2 = "/home/users/wangfei19/workbench/tcpclient/request.dat",
	File3 = "/home/users/wangfei19/workbench/tcpclient/request.dat",
	File = [File1, File2, File3],
	Payload = [get_data(F) || F<- File ],
%10.58.176.19
	{ok, Socket} = gen_tcp:connect({10,58,176,19}, 8081, [ {active, false}, binary, {packet, 0} ]),
	Failed = loop({Times, 0}, Socket, Payload),
	close(Socket, Times, Failed),
	Se = os:timestamp(),
	Diff = timer:now_diff(Se, St),
	Qps = Times / (Diff/1000000),
	Tpr = Diff / Times,
	io:format("worker jobs: ~p, failed: ~p, start:~p, end:~p, Qps:\e[1;33m~p\e[0m, avg time per req(ms):\e[1;33m~p\e[0m~n", [Times, Failed, St, Se, Qps, Tpr/1000]),
	collect ! over.

loop({0, Failed}, _Socket, _Payload) ->
	Failed;

loop({Times, Failed}, Socket, [P1, P2, P3]=Payload) ->
	send(Socket, Payload),
	case gen_tcp:recv(Socket, 2) of  %% 2 second timeout
		{ok, _Body} -> loop({Times-1, Failed}, Socket, [P2, P3, P1]);
		_ -> 
			io:format("=================timout~n"),
			loop({Times-1, Failed+1}, Socket, [P2, P3, P1])
	end.
	

close(Socket, Times, Failed) ->
	gen_tcp:close(Socket),
	EndTime = os:timestamp(),
	ets:insert(stats, {self(), EndTime, Times, Failed}).


send(Socket, [Payload|_PayTail]) ->
%io:format("tcp_send:~p", [Payload]),
	gen_tcp:send(Socket, Payload).


get_data(File) ->
	{ok, Bin} = file:read_file(File),
	Bin.
