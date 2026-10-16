:- dynamic s2a_engine/1.

s2a_engine(recursive).

set_s2a_engine(Engine) :-
    memberchk(Engine, [recursive, ann, both]),
    retractall(s2a_engine(_)),
    assertz(s2a_engine(Engine)).

ann_algorithm(In_vars, Out_var) :-
    s2a_engine(Engine),
    ann_algorithm_engine(Engine, In_vars, Out_var).

ann_algorithm_engine(recursive, In_vars, Out_var) :-
    with_s2a_matcher(recursive, algorithm(In_vars, Out_var)).
ann_algorithm_engine(ann, In_vars, Out_var) :-
    with_s2a_matcher(ann, algorithm(In_vars, Out_var)).
ann_algorithm_engine(both, In_vars, Out_var) :-
    findall(Out,
        with_s2a_matcher(recursive, algorithm(In_vars, Out)),
        Recursive),
    findall(Out,
        with_s2a_matcher(ann, algorithm(In_vars, Out)),
        ANN),
    ( Recursive == ANN ->
        member(Out_var, ANN)
    ; throw(error(ann_s2a_mismatch(algorithm, Recursive, ANN), _))
    ).

with_s2a_matcher(Engine, Goal) :-
    s2a_engine(Previous),
    setup_call_cleanup(
        ( retractall(s2a_engine(_)), assertz(s2a_engine(Engine)) ),
        call(Goal),
        ( retractall(s2a_engine(_)), assertz(s2a_engine(Previous)) )).

ann_match_dispatch(RS0, D0, D2, T1, T22, T2_old, First) :-
    s2a_engine(Engine),
    ( Engine = recursive ->
        s2a_orig_rs_and_data_to_term(RS0, D0, D2, T1, T22, T2_old, First)
    ; Engine = both ->
        match_both(RS0, D0, D2, T1, T22, T2_old, First)
    ;
        ann_match_step(RS0, D0, D2, T1, T22, T2_old, First)
    ).

match_both(RS0, D0, D2, T1, T22, T2_old, First) :-
    findall(D-Output,
        with_s2a_matcher(recursive,
            s2a_orig_rs_and_data_to_term(RS0, D0, D, T1, Output, T2_old, First)),
        Recursive),
    findall(D-Output,
        with_s2a_matcher(ann,
            ann_match_step(RS0, D0, D, T1, Output, T2_old, First)),
        ANN),
    ( Recursive == ANN ->
        member(D2-T22, ANN)
    ; throw(error(ann_s2a_mismatch(rs_and_data_to_term, Recursive, ANN), _))
    ).

ann_match_step(RS0, D0, D2, T1, T22, _T2_old, First) :-
    ( current_predicate(trim_brackets/3) ->
        trim_brackets(RS0, RS, BracketDepth),
        trim_brackets(D0, Data, _)
    ;
        RS = RS0, Data = D0, BracketDepth = 0
    ),
    ann_traverse_state(RS, Data, [order(reference)], Matched, D2, _Vars),
    ( First == true, current_predicate(wrap_brackets/3) ->
        wrap_brackets(Matched, Wrapped, BracketDepth)
    ; Wrapped = Matched
    ),
    append(T1, Wrapped, T22).

install_rs_dispatcher :-
    current_predicate(rs_and_data_to_term/7),
    \+ current_predicate(s2a_orig_rs_and_data_to_term/7),
    findall((s2a_orig_rs_and_data_to_term(A,B,C,D,E,F,G) :- Body),
        clause(rs_and_data_to_term(A,B,C,D,E,F,G), Body), Clauses),
    Clauses \= [],
    abolish(rs_and_data_to_term/7),
    dynamic(rs_and_data_to_term/7),
    maplist(assertz, Clauses),
    assertz((rs_and_data_to_term(A,B,C,D,E,F,G) :-
                ann_match_dispatch(A,B,C,D,E,F,G))).
