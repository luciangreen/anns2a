explain_step(Tag, Features, Action, Why) :-
    ann_state_features(Tag, Features, Encoded),
    ( nonvar(Action) -> Actions = [Action]
    ; findall(A, mnn_action(Tag, A), Actions)
    ),
    findall(Contribution,
        ( member(A, Actions),
          member(Feature, Encoded),
          canonical_action(A, WeightAction),
          action_weighted_feature(Tag, WeightAction, Feature, Weight),
          Contribution = contribution(A, Feature, Weight)
        ), Contributions),
    sort(3, @>=, Contributions, Why).

ann_state_features(_Tag, Features, Features) :-
    is_list(Features),
    !.
ann_state_features(g, State, Features) :-
    encode_state_g(State, Features).
ann_state_features(t, State, Features) :-
    encode_state(State, Features).

ann_g_trace(Specs, Steps) :-
    make_traces(g, Specs, Traces),
    findall(step(Features, Action, Scores),
        ( member(trace(Features, _Legal, Action), Traces),
          mnn_scores(g, Features, Scores)
        ), Steps).

ann_trace(In_vars, Steps) :-
    ( In_vars = Pattern-Data ->
        ann_t_initial(Pattern, Data, State0),
        ann_driver_loop(t, encode_state, legal_actions, execute_action,
                        State0, [trace(on)], [], ReverseSteps, _Final),
        reverse(ReverseSteps, Steps),
        !
    ; Steps = []
    ).

ann_trace(Pattern, Steps) :-
    ann_t_initial(Pattern, [], State0),
    ann_driver_loop(t, encode_state, legal_actions, execute_action,
                    State0, [trace(on)], [], ReverseSteps, _Final),
    reverse(ReverseSteps, Steps).
