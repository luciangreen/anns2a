:- use_module(library(random)).

gen_specs(Seed, Count, Specs) :-
    set_random(seed(Seed)),
    findall(Pattern-Data,
        ( between(1, Count, Index),
          generated_spec(Index, Pattern, Data)
        ), Specs).

generated_spec(Index, [Variable, Variable], [Value, Value]) :-
    0 is Index mod 4,
    !,
    Variable = 'C1',
    Value is Index mod 7.
generated_spec(Index, ['&r', [Variable]], [Value, Value, Value]) :-
    1 is Index mod 4,
    !,
    Variable = 'C1',
    Value is Index mod 7.
generated_spec(Index, [[Variable, 1]], [[Value, 1]]) :-
    2 is Index mod 4,
    !,
    Variable = 'C1',
    Value is Index mod 7.
generated_spec(Index, [nd, [[1], [2]]], [Value]) :-
    3 is Index mod 4,
    !,
    Value is Index mod 2+1.
generated_spec(Index, [Index], [Index]).
