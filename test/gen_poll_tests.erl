-module(gen_poll_tests).
-include_lib("eunit/include/eunit.hrl").

poll_test() ->
    {
        setup,
        fun setup/0,
        fun cleanup/1,
        [
            fun test_polling_behavior/1
        ]
    }.

setup() ->
    {ok, Pid} = gen_poll:start_link(0.25, test_module, [], []),
    Pid.

cleanup(Pid) ->
    gen_poll:stop(Pid).

test_polling_behavior(Pid) ->
    timer:sleep(2000),
    gen_server:call(Pid, {get_counter}),
    receive
        {counter, Count} ->
            ?_assert(Count > 0)
    after
        5000 ->
            ?_assert(false)
    end.
