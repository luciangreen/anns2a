:- dynamic ann_find_lists_engine/1.

ann_find_lists_engine(recursive).

set_s2a_find_lists(Engine) :-
    memberchk(Engine, [recursive, ann, both]),
    retractall(ann_find_lists_engine(_)),
    assertz(ann_find_lists_engine(Engine)).

ann_spec_to_algorithm(Name, Specs, CBM, Alg) :-
    current_predicate(spec_to_algorithm/4),
    with_s2a_find_lists(ann, spec_to_algorithm(Name, Specs, CBM, Alg)).

with_s2a_find_lists(Engine, Goal) :-
    setup_call_cleanup(
        set_s2a_find_lists(Engine),
        call(Goal),
        set_s2a_find_lists(recursive)).

ann_find_lists_dispatch(Tokens, Result) :-
    ann_find_lists_engine(Engine),
    ( Engine = recursive ->
        s2a_orig_find_lists3b(Tokens, Result)
    ; Engine = ann ->
        ann_find_lists(Tokens, Result)
    ; Engine = both ->
        s2a_orig_find_lists3b(Tokens, Original),
        ann_find_lists(Tokens, Candidate),
        ( Original == Candidate -> Result = Original
        ; throw(error(ann_s2a_mismatch(find_lists3b, Original, Candidate), _))
        )
    ).

install_find_lists_dispatcher :-
    current_predicate(find_lists3b/2),
    \+ current_predicate(s2a_orig_find_lists3b/2),
    findall((Head :- Body),
        ( clause(find_lists3b(A, B), Body),
          Head = s2a_orig_find_lists3b(A, B)
        ), Clauses),
    Clauses \= [],
    abolish(find_lists3b/2),
    dynamic(find_lists3b/2),
    maplist(assertz, Clauses),
    assertz((find_lists3b(A, B) :- ann_find_lists_dispatch(A, B))).
