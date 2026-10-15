ann_find_lists(Tokens, Result) :-
    ann_find_lists(Tokens, [order(reference)], Result).

ann_find_lists(Tokens, Opts, Result) :-
    ann_g_initial(Tokens, State0),
    ann_step_loop(g, encode_state_g, legal_actions_g, execute_action_g,
                  State0, Opts, State),
    State = gs(done, [], RawResult, _Memo, _Step),
    ann_fix_g(RawResult, Result).

ann_g_rewrite(['&r', ['&r', Inner]], ['&r', Inner]) :- !.
ann_g_rewrite(Term, Term).

ann_fix_g(Term0, Term) :-
    fixpoint(ann_g_rewrite, Term0, Term).
