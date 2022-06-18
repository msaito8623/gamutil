# gamutil 0.5.5

1. Added two new arguments to ndat_to_contour. One of them is contour.labels. The argument takes a logical value. With TRUE, numeric values of contour labels are drawn. The other new argument is contour.line.size. The argument controls thickness of contour lines.

# gamutil 0.5.4

In this version, you can...
1. give a data.table to the argument "ndat" of ndat_to_contour.
2. use the column name "type" for the argument "facet.col" of ndat_to_contour.

# gamutil 0.5.3

1. Minor update: verbose in add_fit() lists selected terms with new lines.

# gamutil 0.5.2

1. Updated ndat_to_contour:
    - The previous version had a problem in facet_grid. Specifically, because of the problem, geom_hline could not be added.
2. Updated ndat_to_contour:
    - A new argument "facet.labeller" is implemented, with which you can adjust labels of facets when you have a variable for facet.col.
3. Updated plot_contour:
    - A new argument "facet.labeller" is implemented, according to the change to ndat_to_contour.

# gamutil 0.5.1

1. Updated add_fit:
    - The previous version had a problem to find pertinent terms automatically according to the vector of character strings given by the argument "terms" when the pertinent terms have multiple "k" values, e.g. ti(x,y,k=c(3,3)). This issue is resolved.

# gamutil 0.5.0

1. Updated mdl_to_ndat:
    - It now works properly when the fitted model has only one predictor.

# gamutil 0.4.0

1. Three new arguments for gamutil::add_fit:
    - cond: With this argument, other variables than in "terms" can be specified with their own values.
    - terms.size: This argument controls how many terms to be included to obtain prediction.
    - verbose: With this argument TRUE, it will be printed which terms being selected and it will provide some explanation if no term is matched.
2. Two new arguments for gamutil::ndat_to_contour:
    - facet.col: Separate plots will be drawn for the factor variable specified through this argument.
    - se: This argument controls whether 1 standard error contour lines should be drawn.
3. Five new arguments for gamutil::plot_contour:
    - cond: With this argument, you can control the values to other variables than in "view".
    - summed: With summed=TRUE, summed effects will be drawn. With summed=FALSE, partial effects will be drawn. Which terms to be included for calculation is controlled by "terms.size".
    - terms.size: This argument can takes "min", "medium", or "max". "min" searches for the exact term that contains no more or less variables than specified by "view" and "cond". "medium" selects the terms that contain at least one of the target variables but no other variable. "max" includes all the terms that have at least one of the target variables, ignoring if these terms have the variables that are not specified either by "view" or "cond".
    - se: se=TRUE draws 1 x standard error contour lines.
    - verbose: verbose=TRUE prints out which terms being selected and some explanation in case that there is no term matched with the specification by "view" and "cond".

---

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
