# gamutil 0.3.0

- Added a new argument "cond" to gamutil::mdl_to_ndat. Through this argument, user-specified values can be given to variables.
- Removed the column for a dependent variable in the produced dataframe by gamutil::mdl_to_ndat. This function is intended to be used to produce a new dataframe for predictions by gam/bam, and therefore the column is not required.

---

# gamutil 0.2.1 - 0.2.3

- Updated README.Rmd.
- Incremented version in DESCRIPTION.

---

# gamutil 0.2.0

- All passed: devtools::test, devtools::check, goodpractice::gp, rhub::check_for_cran().

---

# gamutil 0.1.1

- Only incremented version in DESCRIPTION.

---

# gamutil 0.1.0

- Passed: devtools::test(), devtools::check().

---

# gamutil 0.0.0

- Initial version. Main functions are defined and ready.
