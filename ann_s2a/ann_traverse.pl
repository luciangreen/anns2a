ann_traverse(Pattern, Data, Opts, Term) :-
    ann_traverse_state(Pattern, Data, Opts, Term, _Remaining, _Vars).

ann_traverse_state(Pattern, Data, Opts, Term, Remaining, Vars) :-
    ann_t_initial(Pattern, Data, State0),
    ( memberchk(max_steps(_), Opts) ->
        Opts1 = Opts
    ;
        length(Pattern, PatternLength),
        length(Data, DataLength),
        Budget is max(32, (PatternLength+1)*(DataLength+1)*4),
        Opts1 = [max_steps(Budget)|Opts]
    ),
    ann_step_loop(t, encode_state, legal_actions, execute_action,
                  State0, Opts1, State),
    State = ts([frame(done, [], [], [], root)], Remaining, Term, Vars, _Step).
