ann_traverse(Pattern, Data, Opts, Term) :-
    ann_traverse_state(Pattern, Data, Opts, Term, _Remaining, _Vars).

ann_traverse_state(Pattern, Data, Opts, Term, Remaining, Vars) :-
    ann_t_initial(Pattern, Data, State0),
    ( memberchk(max_steps(Max), Opts) -> Opts1 = Opts ; Opts1 = [max_steps(100000)|Opts] ),
    ann_step_loop(t, encode_state, legal_actions, execute_action,
                  State0, Opts1, State),
    State = ts([frame(done, [], [], [], root)], Remaining, Term, Vars, _Step).
