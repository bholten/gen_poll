-module(test_module).
-compile(export_all).
-behavior(gen_poll).

init(_Args) ->
    {ok, 0}.

handle_poll(Count) ->
    {noreply, Count + 1}.

handle_call(_Request, _From, State) ->
    {reply, {ok, State}, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

handle_continue(_Continue, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.
