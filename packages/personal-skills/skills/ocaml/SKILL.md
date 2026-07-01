---
name: ocaml
description: Any OCaml development in this repo (implementation, refactors, dune, tests, logging). Prefer the Jane Street stack (Core/Async + ppx_jane) when available.
---

# OCaml Guide

This guide provides patterns and best practices for developing in OCaml.

We prefer Jane Street stack whenever the repo already depends on it (`Core`/`Async` + `ppx_jane` + `dune`).
If the repo is clearly `Stdlib`/`Lwt`/`Eio`, or the user explicitly requests non-Jane Street, follow the repo/user choice.

## Workflow

- Read existing dune files and nearby modules; copy the repo's conventions.
- Optimize for readability: scope code carefully. Do not split a function into multiple top-level helpers just to make it smaller; prefer local helper functions when they only serve the enclosing function.
- Before writing manual recursion over a type, check whether it already defines `map`, `fold`, or similar traversal primitives and use those instead.
- Avoid writing `.mli` unless absolutely necessary; prefer inlining the module signature in the `.ml` for consistency.

## Environment and Reproducibility

- Assume the user already entered an environment consistent with `flake.nix` (usually via `nix develop`).
- If anything about toolchain/deps is unclear, stop and ask; do not paper over missing deps with ad-hoc installs.
- Do not use opam or manually install packages.
- Use `dune` as the single entrypoint:

```bash
dune build
dune runtest
dune runtest --auto-promote   # only when updated expect output is intended; review diffs
dune fmt
```

## Types and Error Handling (Default: Result.t)

- Use types to encode invariants; avoid partial functions.
- Do not ship non-exhaustive matches.
- Prefer `('a, 'e) Result.t` for expected failure; avoid exceptions for control flow.
- For operations where failure is not expected, raise and fail fast (terminate) rather than threading an error that should be impossible.
- Prefer explicit error variants with `[@@deriving sexp_of]`.
- Avoid polymorphic compare/hashing (`Stdlib.compare`, `Hashtbl.hash`, `Pervasives.compare`) unless intentional. If you think it is intentional, stop and ask the user, and add an explicit comment explaining why it is safe here.

```ocaml
open Core

type error =
  | Invalid_input of string
  | Not_found of { id : string }
[@@deriving sexp_of]

let parse_id (s : string) : (int, error) Result.t =
  match Int.of_string_opt s with
  | None -> Error (Invalid_input "id is not an int")
  | Some id -> Ok id
```

When using Core, prefer `Result.Let_syntax` for sequencing:

```ocaml
open Core

let compute (a : int) (b : int) : (int, string) Result.t =
  let open Result.Let_syntax in
  let%bind () = if b = 0 then Error "division by zero" else Ok () in
  Ok (a / b)
```

The same pattern applies to any monad in Core (`Option`, `List`, `Deferred`, etc.) — prefer `*.Let_syntax` over nested matches.

## Testing (Prefer ppx_expect)

- One `let%expect_test` per scenario.
- Use `ppx_assert` (available via `ppx_jane`) for assertions.
- Keep output deterministic; stabilize container order explicitly before printing.
- Prefer sexp output for structured data (e.g. `print_s [%sexp_of: t] v`) over ad-hoc printing.

```ocaml
open Core

let reverse = String.rev

let%expect_test "reverse basics" =
  print_endline (reverse "abc");
  [%expect {| cba |}]
```

### Structuring Tests

Organize unit tests into subdirectories under `test/`, grouped by subsystem. Each subdirectory has its own `dune` stanza, so you can run tests for one subsystem at a time:

```
test/
  lang/   # parser, interp, symex, inference
  syn/    # synthesis (lifting, retraction)
  smt/    # SMT
  ver/    # verification
```

### Running Tests

Pass a directory to `dune runtest` to run all inline tests under it:

```bash
dune runtest test/lang   # Test language subsystem
dune runtest test/syn    # Test synthesis
dune runtest test/smt    # Test SMT
dune runtest lib         # Inline tests under lib
```

**Running a single test file.** `dune runtest` does **not** accept a file path. To run one file's inline tests, temporarily add an `-only-test` flag to the relevant `inline_tests` stanza, run `dune runtest <dir>`, then revert the dune edit. For example, to run only `test_consistent_inference.ml` under `test/syn/`:

```scheme
;; test/syn/dune (temporary)
(inline_tests (flags -only-test test_consistent_inference.ml))
```

```bash
dune runtest test/syn
```

Revert the dune change once you're done. `dune promote` works as usual for expect-test diffs.

For multi-file runs, always pass a directory (e.g. `dune runtest test/syn`), not individual files.

See https://dune.readthedocs.io/en/stable/tests.html for details; consult it if you hit dune test issues.

## Logging (Logs + ppx_log)

Use structured logs for complex flows (I/O, parsing, concurrency, retries, state machines).

- Create a module-specific `Logs.Src.t`:

```ocaml
open Core

let log_src = Logs.Src.create "my_module" ~doc:"Logging for My_module"
```

- Use `ppx_log` with typed fields; keep logs high-signal:

```ocaml
open Core

let process ~flag ~xs =
  [%log.info log_src "process" (flag : bool) ~n:(List.length xs)];
  Ok ()
```

In expect-tests, set reporter + levels explicitly when you need logs in the output. Once the debugging is done, remove this setup.

```ocaml
open Core

let init_logging_for_tests () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level ~all:true (Some Logs.Info)
;;
```

## Strings (Prefer %string)

- Avoid `sprintf`.
- Prefer `ppx_string` (usually via `ppx_jane`) for interpolation:

```ocaml
open Core

let ssh_cmd ~user ~host ~port ~script =
  [%string "ssh %{user}@%{host} -p %{port#Int} %{Sys.quote script}"]
;;
```

## Dune Defaults (Jane Street)

Prefer bundling PPXs via `ppx_jane` in library/test stanzas when using Jane Street:

```lisp
(library
 (name mylib)
 (libraries core async logs logs.fmt)
 (preprocess (pps ppx_jane)))

(test
 (name mylib_expect_tests)
 (libraries core logs logs.fmt)
 (preprocess (pps ppx_jane)))
```

## Never Do These

1. Do not install or mutate deps ad hoc (no `opam install`, no random pins). Ask if deps seem missing.
2. Do not modify `flake.nix` without explicit user approval.
3. Do not use `Obj.magic` or unsafe casts.
4. Do not leave non-exhaustive matches.
5. Do not introduce global mutable state for dependencies.
6. Do not block inside Async code (no `Unix.sleep`; use Async timers/primitives).
7. Do not create versioned names (`foo_v2`) or keep removed-code comments; replace cleanly.
8. Do not auto-promote blindly; review diffs from `dune runtest --auto-promote`.
9. Do not use `sprintf`; prefer `[%string ...]`.
10. Do not use polymorphic compare/hashing unless the user explicitly agrees and the code includes an explicit rationale comment.

## Collections (Comparator-Aware)

- Prefer comparator-aware collections from Core (e.g. `Map`, `Set`, `Hashtbl` keyed by comparator), and prefer `String.Map`/`Int.Set` helpers when they match.
- When printing maps/sets in expect tests, convert to a stable representation (e.g. `Map.to_alist` sorted by key) before sexp/printing.
