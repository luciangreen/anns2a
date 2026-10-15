train_mnn(Tag, Traces, Opts) :-
    ( memberchk(rate(Rate), Opts) -> true ; Rate = 0.1 ),
    ( memberchk(epochs(Epochs), Opts) -> true ; Epochs = 10 ),
    ( memberchk(seed(Seed), Opts) -> true ; Seed = 1 ),
    retractall(mnn_weight(Tag, _, _, _)),
    retractall(mnn_bias(Tag, _, _)),
    retractall(ann_training_trace(Tag, _, _)),
    forall(between(1, Epochs, _),
           maplist(train_example(Tag, Rate), Traces)),
    forall(member(trace(Features, _Legal, Action), Traces),
           assertz(ann_training_trace(Tag, Features, Action))),
    ( Tag = g -> File = 'mnn_g_weights.pl' ; File = 'mnn_t_weights.pl' ),
    evaluate_mnn(Tag, Traces, report(Accuracy, _, _)),
    findall(Feature,
        ( member(trace(Features, _, _), Traces),
          member(Feature, Features)
        ), FeatureInstances),
    sort(FeatureInstances, FeatureList),
    findall(Action, mnn_action(Tag, Action), Actions),
    save_mnn(Tag, File, Seed, Epochs, Rate, FeatureList, Actions, Accuracy).

train_example(Tag, Rate, trace(Features, Legal, Gold)) :-
    mnn_scores(Tag, Features, Scores),
    findall(Neg-Action,
        ( member(Action, Legal),
          action_score_for(Action, Scores, Score),
          Neg is -Score
        ), Ranked),
    keysort(Ranked, [_-Predicted|_]),
    ( Predicted == Gold -> true
    ; canonical_action(Gold, GoldClass),
      canonical_action(Predicted, PredictedClass),
      update_action(Tag, GoldClass, Features, Rate),
      update_action(Tag, PredictedClass, Features, -Rate)
    ).

update_action(Tag, Action, Features, Delta) :-
    maplist(update_feature(Tag, Action, Delta), Features),
    ( retract(mnn_bias(Tag, Action, Bias0)) -> true ; Bias0 = 0 ),
    Bias is Bias0+Delta,
    assertz(mnn_bias(Tag, Action, Bias)).

update_feature(Tag, Action, Delta, Feature) :-
    ( retract(mnn_weight(Tag, Action, Feature, Weight0)) -> true ; Weight0 = 0 ),
    Weight is Weight0+Delta,
    assertz(mnn_weight(Tag, Action, Feature, Weight)).

evaluate_mnn(Tag, Traces, report(Accuracy, Correct, Total)) :-
    length(Traces, Total),
    findall(1,
        ( member(trace(Features, Legal, Gold), Traces),
          mnn_scores(Tag, Features, Scores),
          findall(Neg-Action,
              ( member(Action, Legal),
                action_score_for(Action, Scores, Score),
                Neg is -Score
              ), Ranked),
          keysort(Ranked, [_-Gold|_])
        ), Matches),
    length(Matches, Correct),
    ( Total =:= 0 -> Accuracy = 0 ; Accuracy is Correct/Total ).

make_traces(t, Specs, Traces) :-
    findall(Trace,
        ( member(Pattern-Data, Specs),
          ann_t_initial(Pattern, Data, State0),
          ann_driver_loop(t, encode_state, legal_actions, execute_action,
                          State0, [order(reference), policy(oracle), trace(training)],
                          [], ReverseTrace, _Final),
          reverse(ReverseTrace, Trace)
        ), TraceLists),
    append(TraceLists, Traces).
make_traces(g, Specs, Traces) :-
    findall(Trace,
        ( member(Spec, Specs),
          ann_g_initial(Spec, State0),
          ann_driver_loop(g, encode_state_g, legal_actions_g, execute_action_g,
                          State0, [order(reference), policy(oracle), trace(training)],
                          [], ReverseTrace, _Final),
          reverse(ReverseTrace, Trace)
        ), TraceLists),
    append(TraceLists, Traces).
