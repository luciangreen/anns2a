:- dynamic ann_max_steps/1.

ann_max_steps(100000).

ann_step_loop(Tag, Encode, Legal, Execute, State0, Opts, State) :-
    ann_driver_loop(Tag, Encode, Legal, Execute, State0, Opts, [], Trace0, State),
    ( memberchk(trace(on), Opts) -> reverse(Trace0, _Trace) ; true ).

ann_driver_loop(_Tag, _Encode, _Legal, _Execute, State, Opts, Trace0, Trace, State) :-
    State =.. [_|Args],
    last(Args, Step),
    step_budget(Opts, Budget),
    Step >= Budget,
    !,
    print_message(warning, ann_step_budget_exhausted(Step)),
    Trace = Trace0,
    fail.
ann_driver_loop(Tag, Encode, Legal, Execute, State0, Opts, Trace0, Trace, State) :-
    call(Encode, State0, Features),
    call(Legal, State0, Actions),
    ( Actions = [] ->
        State = State0,
        Trace = Trace0
    ;
        ranked_actions(Tag, Features, Actions, Opts, Ranked),
        member(Action, Ranked),
        call(Execute, Action, State0, State1),
        ( memberchk(trace(on), Opts) ->
            mnn_scores(Tag, Features, Scores),
            Trace1 = [step(Features, Action, Scores)|Trace0]
        ;
            Trace1 = Trace0
        ),
        ann_driver_loop(Tag, Encode, Legal, Execute, State1, Opts,
                        Trace1, Trace, State)
    ).

step_budget(Opts, Budget) :-
    ( memberchk(max_steps(Budget0), Opts) -> Budget = Budget0
    ; ann_max_steps(Budget)
    ).

ranked_actions(_Tag, _Features, Actions, Opts, Actions) :-
    memberchk(order(reference), Opts),
    !.
ranked_actions(Tag, Features, Actions, Opts, Ranked) :-
    ( memberchk(policy(rules), Opts) -> Policy = rules ; Policy = net ),
    ( memberchk(policy(oracle), Opts) -> Policy1 = oracle ; Policy1 = Policy ),
    ( Policy1 = oracle ->
        Ranked = Actions
    ;
        mnn_scores(Tag, Features, Scores),
        findall(NegScore-Action,
            ( nth0(Index, Actions, Action),
              ( memberchk(Action-Score, Scores) -> true ; Score = 0 ),
              NegScore is -Score-Index*1.0e-12
            ), Pairs),
        keysort(Pairs, Sorted),
        pairs_actions(Sorted, Ranked)
    ).

pairs_actions([], []).
pairs_actions(Pairs, Actions) :-
    findall(Action, member(_-Action, Pairs), Actions).

fixpoint(Rewrite, Term0, Term) :-
    ann_max_steps(Max),
    fixpoint_loop(Rewrite, Term0, 0, Max, Term).

fixpoint_loop(_Rewrite, Term, N, Max, Term) :-
    N >= Max,
    !,
    print_message(warning, ann_fixpoint_budget_exhausted(N)).
fixpoint_loop(Rewrite, Term0, N, Max, Term) :-
    ( call(Rewrite, Term0, Term1), Term1 \== Term0 ->
        N1 is N+1,
        fixpoint_loop(Rewrite, Term1, N1, Max, Term)
    ;
        Term = Term0
    ).

user:message(ann_step_budget_exhausted(Step)) -->
    [ 'ANN-S2A step budget exhausted after ~w steps'-[Step] ].
user:message(ann_fixpoint_budget_exhausted(Step)) -->
    [ 'ANN-S2A fixpoint budget exhausted after ~w rewrites'-[Step] ].
