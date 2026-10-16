:- use_module(library(filesex)).
:- use_module(library(apply)).
:- use_module(library(readutil)).

:- prolog_load_context(directory, TestDir),
   directory_file_path(TestDir, '../ann_s2a.pl', Loader),
   load_files(Loader, [if(not_loaded)]).
:- prolog_load_context(directory, TestDir),
   directory_file_path(TestDir, 'gen_specs.pl', Generator),
   load_files(Generator, [if(not_loaded)]).

run_ann_s2a_tests :-
    findall(Result,
        ( ann_test(ID, Name, Goal),
          test_result(Goal, Result),
          format('[~w, ~w, ~w]~n', [Result, ID, Name])
        ), Results),
    count_results(Results, Successes, Failures, Skipped),
    format('ANN-S2A tests: ~w passed, ~w failed, ~w skipped.~n',
           [Successes, Failures, Skipped]),
    Failures =:= 0.

test_result(requires_philosophy(_Goal), skip) :-
    \+ current_predicate(test_s2a/0),
    !.
test_result(requires_philosophy(Goal), Result) :-
    !,
    ( catch(call(Goal), _, fail) -> Result = success ; Result = fail ).
test_result(Goal, Result) :-
    ( catch(call(Goal), _, fail) -> Result = success ; Result = fail ).

ann_test('T-1', 'phase-2 constant binding',
         ann_traverse([a], [a], [order(reference)], [a])).
ann_test('T-2', 'phase-2 variable binding',
         ann_traverse(['C1', 'C1'], [a, a], [order(reference)], [a, a])).
ann_test('T-3', 'phase-2 nested list',
         ann_traverse([['C1']], [[a]], [order(reference)], [[a]])).
ann_test('T-4', 'phase-2 repeated body',
         ann_traverse([['&r', ['C1']]], [a, a],
                       [order(reference)], [['&r', [[a], [a]]]])).
ann_test('T-5', 'phase-2 typed binding',
         ann_traverse([[string, 'C1']], [[string, "a"]],
                      [order(reference)], [[string, "a"]])).
ann_test('T-6', 'phase-2 alternatives',
         ann_traverse([[nd, [[a], [b]]]], [b],
                      [order(reference)], [b])).
ann_test('T-7', 'phase-2 constant mismatch fails',
         \+ ann_traverse([a], [b], [order(reference)], _)).
ann_test('G-1', 'phase-1 repeated unit',
         ann_find_lists([1, 2, 1, 2], [['&r', [1, 2]]])).
ann_test('G-2', 'phase-1 unchanged tokens',
         ann_find_lists([1, 2, 3], [1, 2, 3])).
ann_test('G-3', 'phase-1 repeated singleton',
         ann_find_lists([x, x, x], [['&r', [x]]])).
ann_test('G-4', 'phase-1 bracketed repetition',
         ann_find_lists(['[', 1, 2, 1, 2, ']'],
                        ['[', ['&r', [1, 2]], ']'])).
ann_test('M-1', 'masked actions are available',
         (ann_t_initial([a], [a], State), legal_actions(State, [bind]))).
ann_test('M-2', 'spec generator reproducibility',
         (gen_specs(37, 16, First), gen_specs(37, 16, Second), First == Second)).
ann_test('M-3', 'step budget stops traversal',
         \+ ann_traverse([a], [a], [max_steps(0)], _)).
ann_test('AC-1', 'recursive S2A regression suite',
         requires_philosophy(test_s2a)).
ann_test('AC-14', 'ANN S2A regression suite',
         requires_philosophy(
             (set_s2a_engine(both),
              test_s2a,
              set_s2a_engine(recursive)))).
ann_test('M-4', 'hidden-layer training is reproducible',
         ann_mnn_training_test).

ann_mnn_training_test :-
    tmp_file_stream(text, FirstFile, FirstStream),
    close(FirstStream),
    tmp_file_stream(text, SecondFile, SecondStream),
    close(SecondStream),
    setup_call_cleanup(
        true,
        ( Traces = [trace([pattern(variable)], [bind, fail], bind),
                   trace([pattern(end)], [bind, fail], fail)],
          train_mnn(t, Traces,
                   [epochs(2), rate(0.1), hidden(3), seed(7),
                    activation(relu), file(FirstFile)]),
          train_mnn(t, Traces,
                   [epochs(2), rate(0.1), hidden(3), seed(7),
                    activation(relu), file(SecondFile)]),
          read_file_to_codes(FirstFile, FirstCodes, []),
          read_file_to_codes(SecondFile, SecondCodes, []),
          FirstCodes == SecondCodes,
          mnn_network(t, 3, relu),
          findall(Hidden, mnn_hidden_bias(t, Hidden, _), HiddenUnits),
          sort(HiddenUnits, [1, 2, 3]),
          softmax([large-1000, smaller-999], Probabilities),
          findall(P, member(_-P, Probabilities), ProbabilityValues),
          sum_list(ProbabilityValues, Total),
          abs(Total-1.0) < 1.0e-9
        ),
        ( delete_file(FirstFile), delete_file(SecondFile) )).

count_results(Results, Successes, Failures, Skipped) :-
    include(=(success), Results, Passed),
    include(=(fail), Results, Failed),
    include(=(skip), Results, SkippedTests),
    length(Passed, Successes),
    length(Failed, Failures),
    length(SkippedTests, Skipped).
