-module(gen_poll).
-behavior(gen_server).

-export([start_link/4, start_link/5]).
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_continue/2,
    handle_info/2,
    terminate/2,
    stop/1
]).

-callback init(Args :: term()) -> {ok, State :: term()}.
-callback handle_poll(State :: term()) -> {noreply, NewState :: term()}.

start_link(PollInterval, UserModule, Args, Options) ->
    gen_server:start_link(?MODULE, {PollInterval, UserModule, Args}, Options).

start_link(PollInterval, ServerName, UserModule, Args, Options) ->
    gen_server:start_link(ServerName, ?MODULE, {PollInterval, UserModule, Args}, Options).

init({PollInterval, UserModule, Args}) ->
    {ok, UserState} = UserModule:init(Args),
    erlang:send_after(PollInterval, self(), poll),
    {ok, {UserModule, PollInterval, UserState}}.

handle_call(Request, From, {UserModule, _PollInterval, UserState}) ->
    UserModule:handle_call(Request, From, UserState).

handle_cast(Request, {UserModule, _PollInterval, UserState}) ->
    UserModule:handle_cast(Request, UserState).

handle_continue(Continue, {UserModule, _PollInterval, UserState}) ->
    UserModule:handle_continue(Continue, UserState).

handle_info(poll, {UserModule, PollInterval, UserState}) ->
    {noreply, NewUserState} = UserModule:handle_poll(UserState),
    erlang:send_after(PollInterval, self(), poll),
    {noreply, {UserModule, PollInterval, NewUserState}};

handle_info(Msg, {UserModule, _PollInterval, UserState}) ->
    UserModule:handle_info(Msg, UserState).

terminate(Reason, {UserModule, _PollInterval, UserState}) ->
    UserModule:terminate(Reason, UserState).

stop(Pid) ->
    gen_server:stop(Pid).
