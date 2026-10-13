# PR #30 Showcase interruption diagnosis

2026-10-13, Windows / TeX Live 2025; baseline branch commit `8cdefed`.

The reported third-pass stall was **not reproduced**. Do not attribute it to
MLModern (already fixed), XSR redispatch, font count, or the last logged file
lookup without additional evidence.

## Evidence

- The supplied second pass completes with 18 XDV pages. The interrupted third
  pass ends with `! Interruption` in `\__file_size:n {lmroman10-regular.otf}`
  and only two XDV pages. LaTeX3 defines this as the engine file-size primitive;
  the interruption identifies where TeX was sampled, not why it was slow.
- Egyptian digest `1057cd22b974` occurs eight times in each supplied pass,
  consistent with the eight matrix styles. Both supplied logs contain three
  fallback-family redefinition messages. Neither is evidence of infinite dispatch
  or chain growth.
- The original staging directory and logs were preserved under ignored
  `tests/build/pr30-stall/` before any clean build. The interrupted pass had
  already rewritten auxiliary files, so its remaining stage is not an exact
  snapshot of the successful second pass.
- A replay of that saved stage completed within a 120-second deadline in
  78.28 seconds, using repository sources and local fonts.
- An unmodified clean build completed: XeLaTeX passes 44.66 / 45.27 / 44.50 s,
  Biber 2.03 s, xdvipdfmx 3.12 s, PDF validation 0.78 s. The complete PDF has
  18 pages and passes rendering, WenJin P2/P3, RTL and rotated-text checks.
- A later 120-second run expired in pass 1 near a WenJin font load. Retrying
  with the script's existing 180-second default completed after the cancellation
  fix: XeLaTeX 124.40 / 128.69 / 85.56 s, Biber 2.05 s, conversion 2.82 s,
  validation 0.49 s. All 18 pages passed. During the slower run, XeTeX's thread
  was running and its CPU time reached 110 seconds; this was not solely an
  idle converter wait. Timing variability remains unexplained, and these
  numbers must not be presented as a performance improvement from the fix.

## Confirmed subprocess defect and limited fix

`run_bounded_command.py` cleaned up on `TimeoutExpired` but not on
`KeyboardInterrupt`. Injecting an interruption at the supervisor's wait while
running a real parent/child fixture left **both processes alive**. This is a
confirmed cancellation bug, not proof of what caused the original slow third
pass. Such survivors can consume resources after an operator cancels a build.

The supervisor now runs the same process-tree cleanup for interruption, returns
130 for cancellation (124 remains the deadline exit), and retains the command
log. An integration regression uses real subprocess trees on both paths and
checks that the parent and child are no longer running. Only the interruption
is injected; launch and cleanup are real. The normal command API is unchanged.

No TeX macro, fallback priority, font sample, Showcase source, tracked PDF or
version was changed. This is deliberately a cancellation-handling fix, not a
claimed solution for an unverified engine or filesystem stall. If the original
stall recurs, preserve the live process state and exact pass-2 auxiliary files
before interrupting, together with the supervisor command/log and elapsed time.
