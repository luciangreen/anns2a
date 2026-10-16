:- dynamic mnn_weight/4.
:- dynamic mnn_bias/3.
:- dynamic mnn_hidden_weight/4.
:- dynamic mnn_output_weight/4.
:- dynamic mnn_hidden_bias/3.
:- dynamic mnn_network/3.
:- dynamic ann_rule/3.

mnn_scores(Tag, Features, Scores) :-
    findall(Action-Score,
        ( mnn_action(Tag, Action),
          action_score(Tag, Action, Features, Score)
        ), Scores).

mnn_rule_scores(Tag, Features, Scores) :-
    findall(Action-Score,
        ( mnn_action(Tag, Action),
          ( ann_rule(Tag, Features, RuleAction),
            rule_action_matches(Action, RuleAction)
          -> Score = 1 ; Score = 0 )
        ), Scores).

rule_action_matches(choose_nd, choose_nd(_)).
rule_action_matches(propose_unit, propose_unit(_)).
rule_action_matches(reuse_rjv, reuse_rjv(_)).
rule_action_matches(Action, Action).

canonical_action(choose_nd(_), choose_nd) :- !.
canonical_action(propose_unit(_), propose_unit) :- !.
canonical_action(reuse_rjv(_), reuse_rjv) :- !.
canonical_action(Action, Action).

mnn_action(t, bind).
mnn_action(t, bind_typed).
mnn_action(t, open_list).
mnn_action(t, close_frame).
mnn_action(t, enter_r).
mnn_action(t, repeat_r).
mnn_action(t, exit_r).
mnn_action(t, choose_nd).
mnn_action(t, emit_output).
mnn_action(t, skip_optional).
mnn_action(t, halt).
mnn_action(t, fail).
mnn_action(g, next_work).
mnn_action(g, shift).
mnn_action(g, open_bracket).
mnn_action(g, close_bracket).
mnn_action(g, propose_unit).
mnn_action(g, extend_repeat).
mnn_action(g, reject_unit).
mnn_action(g, close_repeat).
mnn_action(g, reuse_rjv).
mnn_action(g, collapse).
mnn_action(g, halt).
mnn_action(g, fail).

action_score(Tag, Action, Features, Score) :-
    mnn_network(Tag, _Hidden, Activation),
    !,
    hidden_activations(Tag, Activation, Features, HiddenValues),
    output_logit(Tag, Action, HiddenValues, Score).
action_score(Tag, Action, Features, Score) :-
    findall(Contribution,
        ( member(Feature, Features),
          action_weighted_feature(Tag, Action, Feature, Weight),
          Contribution is Weight
        ), Contributions),
    sum_list(Contributions, Sum),
    ( mnn_bias(Tag, Action, Bias) -> true ; Bias = 0 ),
    Score is Sum+Bias.

hidden_activations(Tag, Activation, Features, HiddenValues) :-
    findall(Hidden-Value,
        ( mnn_hidden_bias(Tag, Hidden, Bias),
          findall(Contribution,
              ( member(Feature, Features),
                mnn_hidden_weight(Tag, Hidden, Feature, Weight),
                Contribution is Weight
              ), Contributions),
          sum_list(Contributions, Sum),
          activate(Activation, Sum+Bias, Value)
        ), HiddenValues).

output_logit(Tag, Action, HiddenValues, Score) :-
    findall(Contribution,
        ( member(Hidden-Value, HiddenValues),
          mnn_output_weight(Tag, Action, Hidden, Weight),
          Contribution is Weight*Value
        ), Contributions),
    sum_list(Contributions, Sum),
    ( mnn_bias(Tag, Action, Bias) -> true ; Bias = 0 ),
    Score is Sum+Bias.

activate(relu, Value, Activated) :-
    Activated is max(0, Value).
activate(tanh, Value, Activated) :-
    Activated is tanh(Value).

activation_derivative(relu, Value, 1) :-
    Value > 0,
    !.
activation_derivative(relu, _Value, 0).
activation_derivative(tanh, Value, Derivative) :-
    Derivative is 1-Value*Value.

action_weighted_feature(Tag, Action, Feature, Weight) :-
    mnn_weight(Tag, Action, Feature, Weight).
action_weighted_feature(Tag, choose_nd, Feature, Weight) :-
    mnn_weight(Tag, choose_nd(_), Feature, Weight).
action_weighted_feature(Tag, propose_unit, Feature, Weight) :-
    mnn_weight(Tag, propose_unit(_), Feature, Weight).
action_weighted_feature(Tag, reuse_rjv, Feature, Weight) :-
    mnn_weight(Tag, reuse_rjv(_), Feature, Weight).

softmax(Scores, Probabilities) :-
    ( Scores = [] -> Probabilities = []
    ; findall(S, member(_-S, Scores), Values),
      max_list(Values, Maximum),
      findall(E,
          (member(_-S, Scores), E is exp(S-Maximum)),
          Exps),
      sum_list(Exps, Total),
      ( Total =:= 0 ->
          length(Scores, N),
          P is 1/N,
          maplist(score_probability(P), Scores, Probabilities)
      ;
          findall(Action-P,
              ( nth0(Index, Scores, Action-_),
                nth0(Index, Exps, E),
                P is E/Total
              ), Probabilities)
      )
    ).

score_probability(P, Action-_, Action-P).

save_mnn(Tag, File, Seed, Epochs, Rate, Features, Actions, Accuracy) :-
    setup_call_cleanup(
        open(File, write, Stream),
        ( format(Stream,
                 '%% ANN-S2A MNN ~w, seed ~w, epochs ~w, rate ~w, features ~q, actions ~q, training_accuracy ~6f~n',
                 [Tag, Seed, Epochs, Rate, Features, Actions, Accuracy]),
          forall(mnn_network(Tag, Hidden, Activation),
                 format(Stream,
                       'mnn_network(~q, ~q, ~q).~n',
                       [Tag, Hidden, Activation])),
          forall(mnn_weight(Tag, Action, Feature, Weight),
                 portray_clause(Stream,
                     mnn_weight(Tag, Action, Feature, Weight))),
          forall(mnn_hidden_weight(Tag, Hidden, Feature, Weight),
                 portray_clause(Stream,
                     mnn_hidden_weight(Tag, Hidden, Feature, Weight))),
          forall(mnn_output_weight(Tag, Action, Hidden, Weight),
                 portray_clause(Stream,
                     mnn_output_weight(Tag, Action, Hidden, Weight))),
          forall(mnn_hidden_bias(Tag, Hidden, Bias),
                 portray_clause(Stream,
                     mnn_hidden_bias(Tag, Hidden, Bias))),
          forall(mnn_bias(Tag, Action, Bias),
                 portray_clause(Stream, mnn_bias(Tag, Action, Bias)))
        ),
        close(Stream)).

load_mnn(File) :-
    consult(File).
