% Scaling experiment harness: measures cost (inferences) against input size n
% for the ANN step machines and, when Philosophy is loaded, the recursive
% engines, then fits exponential (log-linear) and polynomial (log-log) models.
% A claim of asymptotic improvement needs the recursive column to fit
% exponentially while the ANN column fits a polynomial with high R^2.
%
%   swipl -g "['tests/ann_scaling_bench.pl'], run_scaling_bench, halt."

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(filesex)).

:- prolog_load_context(directory, TestDir),
   directory_file_path(TestDir, '../ann_s2a.pl', Loader),
   load_files(Loader, [if(not_loaded)]).

bench_sizes([4, 8, 16, 32, 64]).

% family(Name, Kind, N, Input)
family(t_vars_success, t, N, Pattern-Data) :-
    length(Pattern, N), maplist(=('C1'), Pattern),
    length(Data, N), maplist(=(a), Data).
family(t_vars_fail, t, N, Pattern-Data) :-
    length(Pattern, N), maplist(=('C1'), Pattern),
    N1 is N-1, length(Head, N1), maplist(=(a), Head),
    append(Head, [b], Data).
family(t_nested, t, N, Pattern-Data) :-
    nest(N, 'C1', Pattern0), Pattern = [Pattern0],
    nest(N, a, Data0), Data = [Data0].
family(g_repeats, g, N, Tokens) :-
    N2 is N//2, length(Pair, N2), maplist(=([1,2]), Pair),
    append(Pair, Tokens0), Tokens = Tokens0.
family(g_no_repeats, g, N, Tokens) :-
    numlist(1, N, Tokens).
family(g_adversarial, g, N, Tokens) :-
    length(Tokens, N), maplist(=(1), Tokens).

nest(0, X, X) :- !.
nest(N, X, [Y]) :- N1 is N-1, nest(N1, X, Y).

% run(Engine, Kind, Input, Outcome, Inferences)
run(ann, t, Pattern-Data, Out, Inf) :-
    measure(ann_traverse(Pattern, Data, [order(reference)], R), R, Out, Inf).
run(ann, g, Tokens, Out, Inf) :-
    measure(ann_find_lists(Tokens, R), R, Out, Inf).
run(recursive, t, Pattern-Data, Out, Inf) :-
    current_predicate(rs_and_data_to_term/7),
    measure(catch(call_recursive_t(Pattern, Data, R), _, fail), R, Out, Inf).
run(recursive, g, Tokens, Out, Inf) :-
    current_predicate(s2a_orig_find_lists3b/2),
    measure(s2a_orig_find_lists3b(Tokens, R), R, Out, Inf).

call_recursive_t(Pattern, Data, Term) :-
    rs_and_data_to_term(Pattern, Data, [], _, Term, _, _).

measure(Goal, Result, Out, Inf) :-
    statistics(inferences, I0),
    ( catch(call_with_time_limit(20, once(Goal)), _, fail)
    -> Out = ok(Result) ; Out = failed ),
    statistics(inferences, I1),
    Inf is I1-I0.

:- use_module(library(time)).

run_scaling_bench :-
    bench_sizes(Sizes),
    forall(( member(Name, [t_vars_success, t_vars_fail, t_nested,
                           g_repeats, g_no_repeats, g_adversarial]),
             family(Name, Kind, 1, _) ),
        ( format('~n== ~w ==~n', [Name]),
          forall(member(Engine, [recursive, ann]),
                 report_engine(Name, Kind, Engine, Sizes)) )),
    check_agreement(Sizes).

report_engine(Name, Kind, Engine, Sizes) :-
    findall(N-Inf,
        ( member(N, Sizes), family(Name, Kind, N, In),
          run(Engine, Kind, In, _, Inf) ), Points),
    ( Points == [] ->
        format('~w: skipped (engine unavailable)~n', [Engine])
    ;
        format('~w: ~w~n', [Engine, Points]),
        fit_report(Points)
    ).

fit_report(Points) :-
    findall(N-Y, ( member(N-I, Points), I > 0, Y is log(I) ), LogY),
    findall(X-Y, ( member(N-I, Points), I > 0, N > 0,
                   X is log(N), Y is log(I) ), LogLog),
    ( length(LogY, L), L >= 3 ->
        linfit(LogY, _, SE, R2E),
        linfit(LogLog, _, SP, R2P),
        format('  exponential fit: rate=~4f per unit n, R2=~4f~n', [SE, R2E]),
        format('  polynomial fit:  exponent=~4f, R2=~4f~n', [SP, R2P])
    ; format('  too few points to fit~n') ).

linfit(Pts, Intercept, Slope, R2) :-
    length(Pts, N),
    findall(X, member(X-_, Pts), Xs), findall(Y, member(_-Y, Pts), Ys),
    sum_list(Xs, SX), sum_list(Ys, SY),
    MX is SX/N, MY is SY/N,
    sums(Pts, MX, MY, 0, Sxy, 0, Sxx, 0, Syy),
    ( Sxx =:= 0 -> Slope = 0 ; Slope is Sxy/Sxx ),
    Intercept is MY-Slope*MX,
    ( Syy =:= 0 -> R2 = 1.0 ; R2 is (Sxy*Sxy)/(Sxx*Syy) ).

sums([], _, _, Sxy, Sxy, Sxx, Sxx, Syy, Syy).
sums([X-Y|T], MX, MY, Sxy0, Sxy, Sxx0, Sxx, Syy0, Syy) :-
    Sxy1 is Sxy0+(X-MX)*(Y-MY),
    Sxx1 is Sxx0+(X-MX)**2,
    Syy1 is Syy0+(Y-MY)**2,
    sums(T, MX, MY, Sxy1, Sxy, Sxx1, Sxx, Syy1, Syy).

% Completeness: both engines must agree on every instance, failures included.
check_agreement(Sizes) :-
    format('~n== agreement ==~n'),
    forall(( member(Name, [t_vars_success, t_vars_fail, t_nested,
                           g_repeats, g_no_repeats, g_adversarial]),
             family(Name, Kind, 1, _), member(N, Sizes),
             family(Name, Kind, N, In),
             run(recursive, Kind, In, RO, _), run(ann, Kind, In, AO, _) ),
        ( RO == AO -> true
        ; format('MISMATCH ~w n=~w: recursive=~w ann=~w~n', [Name, N, RO, AO]) )),
    format('agreement check done~n').
