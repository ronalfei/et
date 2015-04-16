-module(manager1).

-export([start/1, start/0]).

start() ->
	spawn(manager1, start, [10]). %并发多少进程

start(0) ->
	io:format("~ntest client already started!~~n==========~n");
start(Number) ->
	spawn(worker1, start, [500]),%一个进程请求多少次后退出
	receive
	after 20 ->
		start(Number-1)
	end.
			

