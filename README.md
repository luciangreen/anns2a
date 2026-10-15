# ANN-S2A

ANN-S2A is a SWI-Prolog step-machine experiment for the two S2A traversals:
repeat finding (MNN-G) and generated-pattern matching (MNN-T). The implementation
is in [`ann_s2a/`](ann_s2a/README.md) and keeps the Philosophy source unchanged.

## Dependencies

Use SWI-Prolog 9.x and check out `luciangreen/Philosophy` beside this repository:

```text
workspace/
  anns2a/
  Philosophy/
```

The loader includes `Philosophy/s2a/spec_to_algorithm.pl` when it is present.
The standalone state-machine tests can load without Philosophy. The runner
reports S2A-dependent regression checks as skipped until the sibling checkout
is available.

## Tests

```sh
cd ann_s2a
swipl -g "['tests/ann_s2a_tests.pl'], run_ann_s2a_tests, halt."
```

## Run

Load the package using:

```prolog
['ann_s2a.pl'].
ann_traverse(['C1', 'C1'], [a, a], [order(reference)], Matched).
ann_find_lists([1, 2, 1, 2], Pattern).
```

`set_s2a_engine(recursive|ann|both)` selects the matcher when S2A is loaded.
`set_s2a_find_lists(recursive|ann|both)` selects the generator repeat finder.
The `both` modes compare the two results and throw on a mismatch. Use
`ann_spec_to_algorithm/4` to run S2A generation with the ANN repeat finder.

## Training and inspection

Training records use `trace(Features, LegalActions, ChosenAction)`:

```prolog
make_traces(t, ['C1'-[a]], Traces).
train_mnn(t, Traces, [epochs(10), rate(0.1), seed(1)]).
evaluate_mnn(t, Traces, Report).
export_rules(t, 'ann_t_rules_out.pl').
explain_step(t, [pattern(variable), data(atom)], bind, Why).
```

`ann_trace(Pattern-Data, Steps)` and `ann_g_trace(Specs, Steps)` expose
step-level decisions. Training and exported rules are deterministic for the
same input traces. The BSD-3-Clause license is retained; S2A, S2G and MNNs are
authored by Lucian Green.
