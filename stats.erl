-module(stats).

-export([init/0, result/0]).


init() ->
	try
		ets:new(stats, [named_table, public]),
		ParentId = erlang:group_leader(),
		ets:give_away(stats, ParentId, [])
	catch A:B ->
		io:format("init ets table warning:~p   + ~p~n", [A, B]),
		ets:delete_all_objects(stats)
	end,
	St = os:timestamp(),
	io:format("start time: ~p~n", [St] ),
	ets:insert(stats, {start_time, St, 0, 0}).

result() ->
	TimeFun = fun(Obj, {Min, Max, TotalFailed}) ->
		{_Pid, CompleteTime, _Times, Failed}  = Obj,
		MaxDiff = timer:now_diff(Max, CompleteTime),
		Max1 = case (MaxDiff > 0)  of
			true -> Max;
			_ -> CompleteTime
		end,
		MinDiff = timer:now_diff(Min, CompleteTime),
		Min1 = case (MinDiff < 0 ) of 
			true -> Min;
			_ -> CompleteTime
		end,
		{Min1, Max1, TotalFailed+Failed}
	end,
	[{start_time, InitTime, 0, 0}] = ets:lookup(stats, start_time),
	{MinTime, MaxTime, FailedCount} = ets:foldl(TimeFun, {InitTime, InitTime, 0}, stats),
	TotalTime = timer:now_diff(MaxTime, MinTime) / 1000,		%millisecond
	%io:format("~n Min:~p, Max:~p ~n", [MinTime, MaxTime]),
	Workers = config:get(workers),
    Requests = config:get(requests),
	Qps = (Workers * Requests) / ( TotalTime / 1000),	%second
	io:format("~n\e[1;41m Total Time: ~pms, Test Result Qps(econd): ~p,total failed counts:~p, failed rate: ~p% \e[0m\r\n", [TotalTime, Qps, FailedCount, (FailedCount*100)/(Workers * Requests)]).
