-module(worker).

-export([start/1]).

start(Times) ->
%10.95.31.38:9507
	St = os:timestamp(),
    File = config:get('files'),
	Payload = [get_data(F) || F<- File ],
%10.58.176.19
    Host = config:get('host'),
    Port = config:get('port'),
	{ok, Socket} = gen_tcp:connect(Host, Port, [ {active, false}, binary, {packet, 0} ]),
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
loop({Times, Failed}, Socket, [H|T]) ->
	send(Socket, [H]),
	case gen_tcp:recv(Socket, 200) of
		{ok, _Body} -> loop({Times-1, Failed}, Socket, T++[H]);
		_Any -> 
			io:format("=================timout=(~p)~n", [_Any]),
			loop({Times-1, Failed+1}, Socket, T++[H])
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
