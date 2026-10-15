ann_t_initial(Pattern, Data, ts([frame(list, Pattern, Data, [], root)], Data, [], [], 0)).

encode_state(ts(Frames, Data, _Out, Vars, _Step), Features) :-
    ( Frames = [frame(Kind, [Pattern|_], _FrameData, Acc, Meta)|_] ->
        pattern_kind(Pattern, PatternKind)
    ; Frames = [frame(Kind, [], _FrameData, Acc, Meta)|_] ->
        PatternKind = end
    ; Kind = done, PatternKind = end, Acc = [], Meta = none
    ),
    ( Data = [Item|_] -> data_kind(Item, DataKind) ; DataKind = none ),
    length(Frames, Depth),
    length(Data, DataLength),
    length(Acc, AccLength),
    length(Vars, VarCount),
    Features = [pattern(PatternKind), data(DataKind),
                frame(Kind), depth(Depth), data_remaining(DataLength),
                pattern_accumulated(AccLength), variables_bound(VarCount)].

pattern_kind(P, output) :- P = [output, _], !.
pattern_kind(P, repeat) :- P = ['&r', _], !.
pattern_kind(P, optional) :- P = ['&o', _], !.
pattern_kind(P, alternative) :- P = [nd, _], !.
pattern_kind(P, typed) :- P = [Type, _], type_s2a1(Type), !.
pattern_kind(P, list) :- is_list(P), !.
pattern_kind(P, variable) :- ann_s2a_variable(P), !.
pattern_kind(_, constant).

data_kind([], list) :- !.
data_kind([Type, _], typed) :- type_s2a1(Type), !.
data_kind(Item, list) :- is_list(Item), !.
data_kind(Item, string) :- string(Item), !.
data_kind(Item, number) :- number(Item), !.
data_kind(_, atom).

legal_actions(ts([frame(done, _, _, _, _)|_], _, _, _, _), []) :- !.
legal_actions(ts([frame(list, [], _, _, root)|_], [], _, _, _), [close_frame]) :- !.
legal_actions(ts([frame(list, [], _, _, _)|_], [], _, _, _), [close_frame]) :- !.
legal_actions(ts([frame(r, _, _, _, rmeta(Count, _))|_], Data, _, _, _), Actions) :-
    !,
    ( Count =:= 0 -> Actions = [repeat_r, exit_r]
    ; Data \= [] -> Actions = [repeat_r, exit_r]
    ; Actions = [exit_r]
    ).
legal_actions(ts([frame(list, [Pattern|_], _, _, _)|_], _Data, _, _, _), [emit_output]) :-
    Pattern = [output, _],
    !.
legal_actions(ts([frame(list, [Pattern|_], _, _, _)|_], Data, _, _, _), Actions) :-
    Pattern = [nd, Alternatives],
    !,
    ( is_list(Alternatives), Alternatives \= [] ->
        findall(choose_nd(N), (nth1(N, Alternatives, _)), Actions)
    ; Actions = [fail]
    ),
    Data = Data.
legal_actions(ts([frame(list, [Pattern|_], _, _, _)|_], Data, _, _, _), [enter_r]) :-
    Pattern = ['&r', _],
    !,
    Data = Data.
legal_actions(ts([frame(list, [Pattern|_], _, _, _)|_], Data, _, _, _), [skip_optional]) :-
    Pattern = ['&o', _],
    !,
    Data = Data.
legal_actions(ts([frame(list, [Pattern|_], _, _, _)|_], [Data|_], _, _, _), [open_list]) :-
    is_list(Pattern),
    is_list(Data),
    !.
legal_actions(ts([frame(list, [Pattern|_], _, _, _)|_], [[Type, Value]|_], _, Vars, _), [bind_typed]) :-
    Pattern = [Type, Variable],
    type_s2a1(Type),
    typed_value_legal(Variable, Value, Vars),
    !.
legal_actions(ts([frame(list, [Pattern|_], _, _, _)|_], [Data|_], _, Vars, _), [bind]) :-
    \+ is_list(Pattern),
    \+ special_pattern(Pattern),
    value_legal(Pattern, Data, Vars),
    !.
legal_actions(ts([frame(list, [Pattern|_], _, _, _)|_], [], _, _, _), [fail]) :-
    \+ special_pattern(Pattern),
    !.
legal_actions(ts(_, _, _, _, _), [fail]).

special_pattern([output, _]).
special_pattern(['&r', _]).
special_pattern(['&o', _]).
special_pattern([nd, _]).

value_legal(Variable, Value, Vars) :-
    ( ann_s2a_variable(Variable) ->
        ( memberchk(Variable-Existing, Vars) -> Existing == Value ; true )
    ; Variable == Value
    ).

typed_value_legal(Variable, Value, Vars) :-
    ( ann_s2a_variable(Variable) ->
        ( memberchk(Variable-Existing, Vars) -> Existing == Value ; true )
    ; Variable == Value
    ).

ann_s2a_variable(Item) :-
    atom(Item),
    atom_chars(Item, [Initial|Digits]),
    char_type(Initial, upper),
    Digits \= [],
    maplist(char_type_digit, Digits).

char_type_digit(Char) :- char_type(Char, digit).

type_s2a1(Type) :-
    ( current_predicate(user:type_s2a1/1) -> user:type_s2a1(Type)
    ; memberchk(Type, [atom, string, number, integer, float, list])
    ).
