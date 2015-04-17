-module(manager).

-export([start/2, start/0, start_worker/1, start_worker/2]).

start(Workers, Reqs) ->
	stats:init(),
    Cid = spawn(collect, start, [Workers]), %启动一个收集器
    register(collect, Cid),
    spawn(manager, start_worker, [Workers, Reqs]), %并发多少进程
    io:format("~ntest client already started! Workers: ~p ~~n==========~n", [Workers]).


start_worker(0, _Requests) ->
	ok;
start_worker(Number, Requests) ->
	spawn(worker, start, [Requests]),%一个进程请求多少次后退出
	receive
	after 20 ->
		start_worker(Number-1, Requests)
	end.




start() ->
    config:init(),
	stats:init(),
	Workers = config:get(workers),
	Cid = spawn(collect, start, [Workers]), %启动一个收集器
	register(collect, Cid),
	spawn(manager, start_worker, [Workers]), %并发多少进程
	io:format("~ntest client already started! Workers: ~p ~~n==========~n", [Workers]).

start_worker(0) ->
	ok;
start_worker(Number) ->
	Requests = config:get(requests),
	spawn(worker, start, [Requests]),%一个进程请求多少次后退出
	receive
	after 20 ->
		start_worker(Number-1)
	end.



