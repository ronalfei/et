erlc +native +{hipe,[to_llvm]} worker.erl manager.erl stats.erl worker.erl config.erl collect.erl
erl -boot start_sasl -sname test@localhost +K true -P 134217727 -Q 134217727 -env  ERL_MAX_PORTS 409600  -setcookie edu_dp \
	-s manager \
    -eval "io:format(\"* test service already started~n~n\")."
