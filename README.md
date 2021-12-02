
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gamutil

<!-- badges: start -->

[![R-CMD-check](https://github.com/msaito8623/gamutil/workflows/R-CMD-check/badge.svg)](https://github.com/msaito8623/gamutil/actions)
<!-- badges: end -->

The goal of gamutil is to provide some short-cut functions to facilitate
to work with mgcv::gam and mgcv::bam.

## Installation

gamutil is still under development and therefore not available on
[CRAN](https://CRAN.R-project.org).

The development version is available from [GitHub](https://github.com/)
with:

``` r
# install.packages("devtools")
devtools::install_github("msaito8623/gamutil")
```

## Examples

This is a basic example which shows you how to visualize prediction by a
GA(M)M model with a contour plot:

``` r
library(gamutil)
library(mgcv)
#> Loading required package: nlme
#> This is mgcv 1.8-34. For overview type 'help("mgcv-package")'.
set.seed(8361)
dat = gamSim(verbose=FALSE)
mdl = gam(y ~ s(x0) + s(x1) + ti(x0,x1), data=dat)
plt = plot_contour(mdl, view=c('x0','x1'))
print(plt)
```

<img src="man/figures/README-ex1-1.png" width="600px" height="500px" />

-----

The argument “axis.len” controls resolution of the contour plot to be
produced (default=10). Bigger numbers for the argument would draw
smoother contour lines.

``` r
plt = plot_contour(mdl, view=c('x0','x1'), axis.len=100)
print(plt)
```

<img src="man/figures/README-ex2-1.png" width="600px" height="500px" />

-----

The interval between contour lines can be adjusted by the
“break.interval”
argument.

``` r
plt = plot_contour(mdl, view=c('x0','x1'), axis.len=100, break.interval=1.5)
print(plt)
```

<img src="man/figures/README-ex3-1.png" width="600px" height="500px" />

-----

## Acknowledgments

Some functions in this package, especially gamutil::plot\_contour, are
inspired by [mgcv::plot.gam](https://CRAN.R-project.org/package=mgcv),
[itsadug::fvisgam](https://CRAN.R-project.org/package=itsadug), and
[itsadug::pvisgam](https://CRAN.R-project.org/package=itsadug).
