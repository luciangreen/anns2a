execute_action(bind, ts([frame(list, [Pattern|Rest], _FD, Acc, Meta)|Frames],
                         [Value|Data], Out, Vars0, Step),
               ts([frame(list, Rest, Data, Acc1, Meta)|Frames],
                  Data, Out, Vars, Step1)) :-
    bind_value(Pattern, Value, Vars0, Vars),
    append(Acc, [Value], Acc1),
    Step1 is Step+1.
execute_action(bind_typed,
               ts([frame(list, [[Type, Variable]|Rest], _FD, Acc, Meta)|Frames],
                  [[Type, Value]|Data], Out, Vars0, Step),
               ts([frame(list, Rest, Data, Acc1, Meta)|Frames],
                  Data, Out, Vars, Step1)) :-
    bind_value(Variable, Value, Vars0, Vars),
    append(Acc, [[Type, Value]], Acc1),
    Step1 is Step+1.
execute_action(open_list,
               ts([frame(list, [Pattern|Rest], _FD, Acc, Meta)|Frames],
                  [Value|Data], Out, Vars, Step),
               ts([frame(list, Pattern, Value, [], nested),
                   frame(list, Rest, Data, Acc, Meta)|Frames],
                  Value, Out, Vars, Step1)) :-
    is_list(Pattern),
    is_list(Value),
    Step1 is Step+1.
execute_action(close_frame,
               ts([frame(list, [], _, Acc, root)|_], Data, _Out, Vars, Step),
               ts([frame(done, [], [], [], root)], Data, Acc, Vars, Step1)) :-
    Step1 is Step+1.
execute_action(close_frame,
               ts([frame(list, [], _, Acc, nested),
                   frame(list, ParentPattern, ParentData, ParentAcc, ParentMeta)|Frames],
                  [], Out, Vars, Step),
               ts([frame(list, ParentPattern, ParentData, Acc1, ParentMeta)|Frames],
                  ParentData, Out, Vars, Step1)) :-
    append(ParentAcc, [Acc], Acc1),
    Step1 is Step+1.
execute_action(close_frame,
               ts([frame(list, [], _, Iteration, iteration(Before)),
                   frame(r, Body, _, Repeats, rmeta(Count, ParentMeta))|Frames],
                  Data, Out, Vars, Step),
               ts([frame(r, Body, _, Repeats1,
                        rmeta(Count1, ParentMeta))|Frames],
                  Data, Out, Vars, Step1)) :-
    Data \== Before,
    append(Repeats, [Iteration], Repeats1),
    Count1 is Count+1,
    Step1 is Step+1.
execute_action(enter_r,
               ts([frame(list, [['&r', Body]|Rest], _FD, Acc, Meta)|Frames],
                  Data, Out, Vars, Step),
               ts([frame(r, Body, Data, [], rmeta(0, continuation(Rest, Acc, Meta))),
                   frame(list, Rest, Data, Acc, Meta)|Frames],
                  Data, Out, Vars, Step1)) :-
    Step1 is Step+1.
execute_action(repeat_r,
               ts([frame(r, Body, _, Repeats, rmeta(Count, Continuation))|Frames],
                  Data, Out, Vars, Step),
               ts([frame(list, Body, Data, [], iteration(Data)),
                   frame(r, Body, Data, Repeats, rmeta(Count, Continuation))|Frames],
                  Data, Out, Vars, Step1)) :-
    Step1 is Step+1.
execute_action(exit_r,
               ts([frame(r, _Body, _, Repeats,
                         rmeta(_Count, continuation(Rest, Acc, Meta))),
                   frame(list, _, ParentData, _, _)|Frames],
                  Data, Out, Vars, Step),
               ts([frame(list, Rest, ParentData, Acc1, Meta)|Frames],
                  Data, Out, Vars, Step1)) :-
    append(Acc, [['&r', Repeats]], Acc1),
    Step1 is Step+1.
execute_action(emit_output,
               ts([frame(list, [[output, Value]|Rest], FD, Acc, Meta)|Frames],
                  Data, Out, Vars, Step),
               ts([frame(list, Rest, FD, Acc1, Meta)|Frames],
                  Data, Out1, Vars, Step1)) :-
    append(Acc, [[output, Value]], Acc1),
    append(Out, [[output, Value]], Out1),
    Step1 is Step+1.
execute_action(skip_optional,
               ts([frame(list, [['&o', _]|Rest], FD, Acc, Meta)|Frames],
                  Data, Out, Vars, Step),
               ts([frame(list, Rest, FD, Acc, Meta)|Frames],
                  Data, Out, Vars, Step1)) :-
    Step1 is Step+1.
execute_action(choose_nd(N),
               ts([frame(list, [[nd, Alternatives]|Rest], FD, Acc, Meta)|Frames],
                  Data, Out, Vars, Step),
               ts([frame(list, Pattern, FD, Acc, Meta)|Frames],
                  Data, Out, Vars, Step1)) :-
    nth1(N, Alternatives, Alternative),
    ( is_list(Alternative) ->
        append(Alternative, Rest, Pattern)
    ; Pattern = [Alternative|Rest]
    ),
    Step1 is Step+1.
execute_action(halt, State, State).

bind_value(Variable, Value, Vars, Vars) :-
    ann_s2a_variable(Variable),
    memberchk(Variable-Existing, Vars),
    !,
    Existing == Value.
bind_value(Variable, Value, Vars, Vars1) :-
    ann_s2a_variable(Variable),
    !,
    append(Vars, [Variable-Value], Vars1).
bind_value(Constant, Value, Vars, Vars) :-
    Constant == Value.
