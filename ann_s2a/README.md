# ANN-S2A Prolog program

This folder contains the ANN-S2A step driver, phase-specific state machines,
MNN scoring and transparency helpers, integration adapters, and regression
runner. It expects SWI-Prolog 9.x. When available, the loader includes the
untouched Philosophy `s2a/spec_to_algorithm.pl` from a sibling checkout.

From this directory, run:

```sh
swipl -g "['tests/ann_s2a_tests.pl'], run_ann_s2a_tests, halt."
```

Public predicates include `ann_find_lists/2`, `ann_spec_to_algorithm/4`,
`ann_traverse/4`, `ann_algorithm/2`, both `set_s2a_*` engine switches,
phase-specific state encoders, legal-action masks and executors,
`make_traces/3`, `train_mnn/3`, `evaluate_mnn/3`, `export_rules/2`,
`explain_step/4`, `ann_g_trace/2`, and `ann_trace/2`.

`ann_traverse/4` accepts `order(ann|reference)`, `policy(net|rules|oracle)`,
and `max_steps(N)`. Phase state is passed explicitly as `gs/5` or `ts/5`.
The Prolog weight and rule files are readable and replaceable. Training uses a
fixed input order and seed, with no external ML library. `train_mnn/3` accepts
`epochs(N)`, `rate(R)`, `hidden(N)`, `activation(relu|tanh)`, and `seed(N)`;
the default network has 16 hidden units and uses ReLU. Training uses
legal-action softmax cross-entropy and writes the layer weights to the
phase-specific weight file. Pass `file(Path)` to write to a different path.

The full program specification is in the repository's
`ANN-S2A Prolog Program Requirements.docx`. BSD-3-Clause; Lucian Green is
credited as author of S2A, S2G, and MNNs.
