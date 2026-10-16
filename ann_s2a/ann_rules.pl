:- dynamic ann_training_trace/3.

export_rules(Tag, File) :-
    retractall(ann_rule(Tag, _, _)),
    forall(ann_training_trace(Tag, Features, Action),
           assert_rule_once(Tag, Features, Action)),
    setup_call_cleanup(
        open(File, write, Stream),
        forall(ann_rule(Tag, Features, Action),
               portray_clause(Stream, ann_rule(Tag, Features, Action))),
        close(Stream)).

assert_rule_once(Tag, Features, Action) :-
    ( ann_rule(Tag, Features, Action) -> true
    ; assertz(ann_rule(Tag, Features, Action))
    ).
