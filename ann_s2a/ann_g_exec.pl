execute_action_g(shift,
                 gs([scan([Token|Rest])|Work], Stack, Out, Memo, Step),
                 gs([scan(Rest)|Work], Stack, Out1, Memo, Step1)) :-
    append(Out, [Token], Out1),
    Step1 is Step+1.
execute_action_g(propose_unit(N),
                 gs([scan(Tokens)|Work], Stack, Out, Memo, Step),
                 gs([scan(Rest)|Work], [hyp(Unit, 2)|Stack], Out, Memo, Step1)) :-
    length(Unit, N),
    append(Unit, Tail, Tokens),
    append(Unit, Rest, Tail),
    Step1 is Step+1.
execute_action_g(extend_repeat,
                 gs([scan(Tokens)|Work], [hyp(Unit, Count)|Stack], Out, Memo, Step),
                 gs([scan(Rest)|Work], [hyp(Unit, Count1)|Stack], Out, Memo, Step1)) :-
    append(Unit, Rest, Tokens),
    Count1 is Count+1,
    Step1 is Step+1.
execute_action_g(close_repeat,
                 gs([scan(Tokens)|Work], [hyp(Unit, _Count)|Stack], Out, Memo, Step),
                 gs([scan(Tokens)|Work], Stack, Out1, Memo, Step1)) :-
    append(Out, [['&r', Unit]], Out1),
    Step1 is Step+1.
execute_action_g(open_bracket,
                 gs([scan([Open|Tokens])|Work], Stack, Out, Memo, Step),
                 gs([scan(Inside), scan(After)|Work],
                    [bracket(Open, Close, Out, Memo)|Stack], [], [], Step1)) :-
    bracket_content([Open|Tokens], Open, Close, Inside, After),
    Step1 is Step+1.
execute_action_g(close_bracket,
                 gs([scan([]), scan(After)|Work],
                    [bracket(Open, Close, OuterOut, OuterMemo)|Stack],
                    InnerOut, Memo, Step),
                 gs([scan(After)|Work], Stack, Out, MemoOut, Step1)) :-
    append(OuterOut, [Open|InnerOut], Partial),
    append(Partial, [Close], Out),
    append(OuterMemo, Memo, MemoOut),
    Step1 is Step+1.
execute_action_g(close_bracket,
                 gs([scan([])], [bracket(Open, Close, OuterOut, OuterMemo)|Stack],
                    InnerOut, Memo, Step),
                 gs([scan([])], Stack, Out, MemoOut, Step1)) :-
    append(OuterOut, [Open|InnerOut], Partial),
    append(Partial, [Close], Out),
    append(OuterMemo, Memo, MemoOut),
    Step1 is Step+1.
execute_action_g(next_work,
                 gs([scan([])|Work], Stack, Out, Memo, Step),
                 gs(Work, Stack, Out, Memo, Step1)) :-
    Step1 is Step+1.
execute_action_g(halt, gs([], Stack, Out, Memo, Step),
                 gs(done, Stack, Out, Memo, Step1)) :-
    Step1 is Step+1.
execute_action_g(halt, gs([scan([])], Stack, Out, Memo, Step),
                 gs(done, Stack, Out, Memo, Step1)) :-
    Step1 is Step+1.
