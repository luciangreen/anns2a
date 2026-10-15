:- dynamic mnn_weight/4.
:- dynamic mnn_bias/3.
:- dynamic ann_rule/3.

mnn_scores(Tag, Features, Scores) :-
    ( ann_rule(Tag, Features, Action) ->
        findall(A-0, (mnn_action(Tag, A), A \= Action), Other),
        Scores = [Action-1|Other]
    ;
        findall(Action-Score,
            ( mnn_action(Tag, Action),
              action_score(Tag, Action, Features, Score)
            ), Scores)
    ).

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
    findall(Contribution,
        ( member(Feature, Features),
          mnn_weight(Tag, Action, Feature, Weight),
          Contribution is Weight
        ), Contributions),
    sum_list(Contributions, Sum),
    ( mnn_bias(Tag, Action, Bias) -> true ; Bias = 0 ),
    Score is Sum+Bias.

softmax(Scores, Probabilities) :-
    ( Scores = [] -> Probabilities = []
    ; findall(E, (member(_-S, Scores), E is exp(S)), Exps),
      sum_list(Exps, Total),
      ( Total =:= 0 ->
          length(Scores, N),
          P is 1/N,
          maplist(score_probability(P), Scores, Probabilities)
      ;
          probabilities_from_exps(Scores, Exps, Total, Probabilities)
      )
    ).

score_probability(P, Action-_, Action-P).

probabilities_from_exps([], [], _Total, []).
probabilities_from_exps([Action-_|Scores], [E|Exps], Total, [Action-P|Ps]) :-
    P is E/Total,
    probabilities_from_exps(Scores, Exps, Total, Ps).

save_mnn(Tag, File, Seed, Epochs, Rate) :-
    setup_call_cleanup(
        open(File, write, Stream),
        ( format(Stream, '%% ANN-S2A MNN ~w, seed ~w, epochs ~w, rate ~w~n',
                 [Tag, Seed, Epochs, Rate]),
          forall(mnn_weight(Tag, Action, Feature, Weight),
                 portray_clause(Stream,
                     mnn_weight(Tag, Action, Feature, Weight))),
          forall(mnn_bias(Tag, Action, Bias),
                 portray_clause(Stream, mnn_bias(Tag, Action, Bias)))
        ),
        close(Stream)).

load_mnn(File) :-
    consult(File).
