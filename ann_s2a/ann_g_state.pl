ann_g_initial(Tokens, gs([scan(Tokens)], [], [], [], 0)).

encode_state_g(gs([scan(Tokens)|_], Stack, Out, Memo, _Step), Features) :-
    ( Tokens = [Token|_] -> token_kind(Token, Kind) ; Kind = end ),
    length(Tokens, Remaining),
    length(Stack, Depth),
    length(Out, Emitted),
    ( memberchk(hyp(_, Count), Stack) -> Open = 1 ; Open = 0, Count = 0 ),
    ( memberchk(memo(_, positive), Memo) -> MemoPositive = 1 ; MemoPositive = 0 ),
    Features = [token(Kind), remaining(Remaining), depth(Depth),
                emitted(Emitted), hypothesis(Open), repeat_count(Count),
                memo_positive(MemoPositive)].
encode_state_g(gs(done, _Stack, Out, Memo, _Step), [token(end), emitted(N), memo(M)]) :-
    length(Out, N),
    length(Memo, M).

token_kind(Token, open_bracket) :- bracket_open(Token, _), !.
token_kind(Token, close_bracket) :- bracket_close(Token, _), !.
token_kind(Token, string) :- string(Token), !.
token_kind(Token, number) :- number(Token), !.
token_kind(Token, atom) :- atom(Token), !.
token_kind(_, compound).

legal_actions_g(gs(done, _, _, _, _), []) :- !.
legal_actions_g(gs([], _, _, _, _), [halt]) :- !.
legal_actions_g(gs([scan([])|_], [hyp(_, Count)|_], _, _, _), [close_repeat]) :-
    Count >= 2,
    !.
legal_actions_g(gs([scan([])|_], [bracket(_, _, _, _)|_], _, _, _),
                [close_bracket]) :- !.
legal_actions_g(gs([scan([])|Rest], [], _, _, _), [next_work]) :-
    Rest \= [],
    !.
legal_actions_g(gs([scan([])|_], [], _, _, _), [halt]) :- !.
legal_actions_g(gs([scan(Tokens)|_], Stack, _, _, _), Actions) :-
    Tokens \= [],
    ( Stack = [hyp(Unit, Count)|_] ->
        ( repeated_prefix(Tokens, Unit) ->
            Actions = [extend_repeat, close_repeat]
        ; Actions = [close_repeat, shift]
        ),
        Count >= 2
    ;
        length(Tokens, Length),
        Max is Length//2,
        findall(propose_unit(N),
            ( between(1, Max, N),
              prefix_unit(Tokens, N, Unit),
              repeated_prefix_after(Tokens, N, Unit)
            ), Proposals),
        ( Tokens = [Open|Rest],
          bracket_content([Open|Rest], Open, _Close, _Inside, _After) ->
            append([open_bracket|Proposals], [shift], Actions)
        ;
            append(Proposals, [shift], Actions)
        )
    ).

bracket_open('[', ']').
bracket_open('(', ')').
bracket_open('{', '}').
bracket_open("[", "]").
bracket_open("(", ")").
bracket_open("{", "}").

bracket_close(']', ']').
bracket_close(')', ')').
bracket_close('}', '}').
bracket_close("]", "]").
bracket_close(")", ")").
bracket_close("}", "}").

bracket_content([Open|Tail], Open, Close, Inside, After) :-
    bracket_open(Open, Close),
    append(Inside, [Close|After], Tail),
    foldl(bracket_scan, Inside, [Close], [Close]).

bracket_scan(Token, Stack0, Stack) :-
    ( bracket_open(Token, Closer) ->
        Stack = [Closer|Stack0]
    ; bracket_close(Token, Closer) ->
        Stack0 = [Closer|Stack]
    ; Stack = Stack0
    ).

prefix_unit(Tokens, N, Unit) :-
    length(Unit, N),
    append(Unit, _, Tokens).

repeated_prefix(Tokens, Unit) :-
    length(Unit, N),
    append(Unit, _Rest, Tokens),
    N > 0.

repeated_prefix_after(Tokens, N, Unit) :-
    length(Unit, N),
    append(Unit, Rest, Tokens),
    append(Unit, _, Rest).
