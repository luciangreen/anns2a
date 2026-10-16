:- use_module(library(random)).

train_mnn(Tag, Traces, Opts) :-
    training_option(rate, Opts, 0.1, Rate),
    training_option(epochs, Opts, 10, Epochs),
    training_option(hidden, Opts, 16, Hidden),
    training_option(activation, Opts, relu, Activation),
    training_option(seed, Opts, 1, Seed),
    ( memberchk(file(File), Opts) -> true
    ; Tag = g -> File = 'mnn_g_weights.pl'
    ; File = 'mnn_t_weights.pl'
    ),
    validate_training_options(Rate, Epochs, Hidden, Activation, Seed),
    retractall(mnn_weight(Tag, _, _, _)),
    retractall(mnn_bias(Tag, _, _)),
    retractall(mnn_hidden_weight(Tag, _, _, _)),
    retractall(mnn_output_weight(Tag, _, _, _)),
    retractall(mnn_hidden_bias(Tag, _, _)),
    retractall(mnn_network(Tag, _, _)),
    retractall(ann_training_trace(Tag, _, _)),
    set_random(seed(Seed)),
    findall(Feature,
        ( member(trace(Features, _, _), Traces),
          member(Feature, Features)
        ), FeatureInstances),
    sort(FeatureInstances, FeatureList),
    initialize_mnn(Tag, FeatureList, Hidden, Activation),
    forall(between(1, Epochs, _),
           maplist(train_example(Tag, Rate), Traces)),
    forall(member(trace(Features, _Legal, Action), Traces),
           assertz(ann_training_trace(Tag, Features, Action))),
    evaluate_mnn(Tag, Traces, report(Accuracy, _, _)),
    findall(Action, mnn_action(Tag, Action), Actions),
    save_mnn(Tag, File, Seed, Epochs, Rate, FeatureList, Actions, Accuracy).

training_option(Name, Opts, Default, Value) :-
    Term =.. [Name, Option],
    ( memberchk(Term, Opts) -> Value = Option ; Value = Default ).

validate_training_options(Rate, Epochs, Hidden, Activation, Seed) :-
    ( number(Rate), Rate > 0 -> true
    ; throw(error(domain_error(positive_learning_rate, Rate), _))
    ),
    ( integer(Epochs), Epochs > 0 -> true
    ; throw(error(domain_error(positive_epoch_count, Epochs), _))
    ),
    ( integer(Hidden), Hidden > 0 -> true
    ; throw(error(domain_error(positive_hidden_units, Hidden), _))
    ),
    ( memberchk(Activation, [relu, tanh]) -> true
    ; throw(error(domain_error(mnn_activation, Activation), _))
    ),
    ( integer(Seed) -> true
    ; throw(error(type_error(integer, Seed), _))
    ).

initialize_mnn(Tag, Features, Hidden, Activation) :-
    assertz(mnn_network(Tag, Hidden, Activation)),
    forall(between(1, Hidden, Unit),
        ( assertz(mnn_hidden_bias(Tag, Unit, 0.0)),
          forall(member(Feature, Features),
                 ( random_weight(Weight),
                   assertz(mnn_hidden_weight(Tag, Unit, Feature, Weight))
                 ))
        )),
    forall(mnn_action(Tag, Action),
        ( assertz(mnn_bias(Tag, Action, 0.0)),
          forall(between(1, Hidden, Unit),
                 ( random_weight(Weight),
                   assertz(mnn_output_weight(Tag, Action, Unit, Weight))
                 ))
        )).

random_weight(Weight) :-
    Random is random_float,
    Weight is (Random-0.5)*0.2.

train_example(Tag, Rate, trace(Features, Legal, Gold)) :-
    canonical_action(Gold, GoldClass),
    legal_action_classes(Legal, Classes),
    memberchk(GoldClass, Classes),
    hidden_activations(Tag, Features, HiddenValues),
    findall(Action-Score,
        ( member(Action, Classes),
          output_logit(Tag, Action, HiddenValues, Score)
        ), Logits),
    softmax(Logits, Probabilities),
    output_deltas(Probabilities, GoldClass, OutputDeltas),
    hidden_deltas(Tag, OutputDeltas, HiddenValues, HiddenDeltas),
    update_output_layer(Tag, Rate, OutputDeltas, HiddenValues),
    sort(Features, UniqueFeatures),
    update_hidden_layer(Tag, Rate, HiddenDeltas, UniqueFeatures).

legal_action_classes(Legal, Classes) :-
    findall(Class,
        ( member(Action, Legal),
          canonical_action(Action, Class)
        ), Classes0),
    sort(Classes0, Classes).

hidden_activations(Tag, Features, HiddenValues) :-
    mnn_network(Tag, _Hidden, Activation),
    hidden_activations(Tag, Activation, Features, HiddenValues).

output_deltas([], _Gold, []).
output_deltas([Action-Probability|Rest], Gold, [Action-Delta|Deltas]) :-
    ( Action == Gold -> Delta is Probability-1 ; Delta = Probability ),
    output_deltas(Rest, Gold, Deltas).

hidden_deltas(Tag, OutputDeltas, HiddenValues, HiddenDeltas) :-
    mnn_network(Tag, _Hidden, Activation),
    findall(Hidden-Delta,
        ( member(Hidden-Value, HiddenValues),
          activation_derivative(Activation, Value, Derivative),
          findall(Contribution,
              ( member(Action-OutputDelta, OutputDeltas),
                mnn_output_weight(Tag, Action, Hidden, Weight),
                Contribution is OutputDelta*Weight
              ), Contributions),
          sum_list(Contributions, Sum),
          Delta is Derivative*Sum
        ), HiddenDeltas).

update_output_layer(Tag, Rate, OutputDeltas, HiddenValues) :-
    forall(member(Action-Delta, OutputDeltas),
        ( forall(member(Hidden-Value, HiddenValues),
                 adjust_output_weight(Tag, Action, Hidden, Rate*Delta*Value)),
          adjust_bias(Tag, Action, Rate*Delta)
        )).

update_hidden_layer(Tag, Rate, HiddenDeltas, Features) :-
    forall(member(Hidden-Delta, HiddenDeltas),
        ( forall(member(Feature, Features),
                 adjust_hidden_weight(Tag, Hidden, Feature,
                                      Rate*Delta)),
          adjust_hidden_bias(Tag, Hidden, Rate*Delta)
        )).

adjust_output_weight(Tag, Action, Hidden, GradientExpression) :-
    ( retract(mnn_output_weight(Tag, Action, Hidden, Weight0)) -> true
    ; Weight0 = 0.0
    ),
    Delta is -GradientExpression,
    Weight is Weight0+Delta,
    assertz(mnn_output_weight(Tag, Action, Hidden, Weight)).

adjust_hidden_weight(Tag, Hidden, Feature, GradientExpression) :-
    ( retract(mnn_hidden_weight(Tag, Hidden, Feature, Weight0)) -> true
    ; Weight0 = 0.0
    ),
    Delta is -GradientExpression,
    Weight is Weight0+Delta,
    assertz(mnn_hidden_weight(Tag, Hidden, Feature, Weight)).

adjust_bias(Tag, Action, GradientExpression) :-
    ( retract(mnn_bias(Tag, Action, Bias0)) -> true ; Bias0 = 0.0 ),
    Delta is -GradientExpression,
    Bias is Bias0+Delta,
    assertz(mnn_bias(Tag, Action, Bias)).

adjust_hidden_bias(Tag, Hidden, GradientExpression) :-
    ( retract(mnn_hidden_bias(Tag, Hidden, Bias0)) -> true
    ; Bias0 = 0.0
    ),
    Delta is -GradientExpression,
    Bias is Bias0+Delta,
    assertz(mnn_hidden_bias(Tag, Hidden, Bias)).

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
