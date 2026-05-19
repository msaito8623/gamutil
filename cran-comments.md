# gamutil 0.8.1 (resubmission of a new submission)

This is a new submission of the package; an earlier attempt at v0.6.0
in October 2023 did not complete the review, and gamutil has never
been published on CRAN (no entry in `web/packages/gamutil/`, no entry
in `src/contrib/Archive/gamutil/`). The version submitted to the
current review round was v0.7.0; this resubmission, v0.8.1, addresses
the two points raised by the reviewer on that submission:

1. **Reference in DESCRIPTION.** The Description field now references
   the underlying GAM methodology: Wood (2017, ISBN:9781498728331).
   gamutil itself does not implement a novel published method; it is a
   visualization/utility wrapper around the `mgcv` package, so the
   reference points to the standard textbook for the modelling
   methodology that gamutil's outputs help interpret.

2. **`\dontrun{}` -> `\donttest{}`.** All five example blocks have been
   converted to `\donttest{}`. The examples are real, runnable code;
   they were wrapped originally only because some fit non-trivial GAMs
   that may exceed the 5-second example budget on slower platforms,
   not because they cannot be executed. Local
   `R CMD check --as-cran --run-donttest` confirms they all run cleanly
   (see "R CMD check results" below). The `plot_partial()` example was
   also rewritten to be self-contained (the previous example referenced
   model objects that were never defined inside the example block).

Note that the version has been bumped from 0.7.0 to 0.8.1 because
v0.7.1 (a follow-up bug fix) and v0.8.0 (two new exported functions)
had already been folded in locally before the CRAN feedback arrived.
NEWS.md documents 0.7.0, 0.7.1, 0.8.0 and 0.8.1 separately so the
reviewer can see the full set of changes since the unpublished v0.6.0.
A "New submission" NOTE on win-builder / CRAN incoming is therefore
expected and correct.

# gamutil 0.7.0

This is a new submission. (An earlier v0.6.0 was submitted to CRAN
in October 2023 but never completed review; the package is not on
CRAN — neither in `web/packages/gamutil/` nor in
`src/contrib/Archive/gamutil/`.)

## Summary of changes

* Bug fix: `add_fit()` now correctly handles parametric `:`-interactions
  (e.g., `y ~ fac + x + fac:x`). The internal helper `find.pos()` previously
  did not split `fac:x` into its component variables, so the interaction was
  silently excluded from partial-effect computation under all `terms.size`
  values. Numerical output for affected models will change.
* New argument `include.parametric` (default `TRUE`) in `add_fit()` and
  `plot_contour()`. With `FALSE`, only smooth terms (`s`, `te`, `ti`, `t2`)
  are eligible for the partial-effect computation; useful for visualizing
  the smooth-only contribution in models that mix parametric and smooth
  predictors.
* Minimum R version bumped to 3.5 (required by the binary serialization
  version of the bundled internal data).

## Test environments

* Ubuntu 24.04, R 4.6.0 (local machine)
* R-hub linux (Ubuntu, R-devel) via GitHub Actions
* R-hub macos-arm64 (R-devel) via GitHub Actions
* R-hub windows (R-devel) via GitHub Actions
* R-hub atlas (Fedora R-devel container) via GitHub Actions
* win-builder R-devel
* win-builder R-release

## R CMD check results

Local `R CMD check --as-cran`: 0 errors, 0 warnings, 0 notes.

R-hub on all four platforms above: 0 errors, 0 warnings, 2 NOTEs.
The two NOTEs are:

1. `checking for hidden files and directories ... NOTE` — flags the
   `.github` directory (GitHub Actions workflows for R-hub and CI).
2. `checking top-level files ... NOTE` — flags `cran-comments.md`,
   `CRAN-SUBMISSION`, `codecov.yml`, `data-raw/`, `README.html`,
   and `README.Rmd`.

All of these files are listed in `.Rbuildignore` and are correctly
excluded by `R CMD build` (verified by inspecting the locally built
`gamutil_0.7.0.tar.gz`). The R-hub build pipeline does not appear
to honor `.Rbuildignore` in the same way; consequently these NOTEs
are R-hub artifacts and do not reflect issues in the source tarball
that is being submitted to CRAN.

win-builder R-devel and R-release: 0 errors, 0 warnings, 1 NOTE.
The NOTE is:

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Motoki Saito <motokisaito.8623@gmail.com>'
New submission
```

This is the standard "New submission" tag from CRAN's incoming
feasibility check, and is correct: gamutil has never been published
on CRAN, so this is genuinely a new submission.
