#' Example data frame (for internal use)
#'
#' This function returns a dataframe, which contains a variable intended to be
#' a dependent variable, i.e. "y", and three other variables, which are meant
#' to be predictors, i.e., "x0", "x1", and "x2". The dependent variable is
#' designed to have non-linear relationships with the predictors. This function
#' and the dataframe to be produced are intended for internal use to describe
#' examples in documentations.
#' @param n An integer for the number of observations (number of rows) for the
#' output data.frame.
#' @return A data frame with four columns. One of the four columns is named "y"
#' and intended to be a dependent variable. The other three of the four columns
#' are "x0", "x1", and "x2", and meant to be predictor variables. These
#' variables are all continuous variables.
#' @author Motoki Saito, \email{motoki.saito@uni-tuebingen.de}
#' @keywords utilities
#' @examples
#' library(mgcv)
#' dat = example_df(n=400)
#' mdl <- gam(y ~ s(x1) + s(x2) + ti(x1, x2), data=dat)
#' plot_contour(mdl, view=c('x1','x2'))
#' @importFrom stats runif rnorm
#' @export
#'
example_df <- function (n=1000) {
	set.seed(123)
	x0 <- runif(n, -1, 1)
	set.seed(1234)
	x1 <- runif(n, -1, 1)
	set.seed(12345)
	x2 <- runif(n, -1, 1)
	set.seed(123456)
	e <- rnorm(n, 0, 1)
	f <- function (x, a, b, d, g) a*x^3 + b*x^2 + d*x^1 + g
	f0 <-  0.1 * f(x0,  0.02,  0.01, -0.01,  0.00)
	f1 <-  0.1 * f(x1,  0.02,  0.00, -0.02,  0.02)
	f2 <-  0.1 * f(x2,  0.01, -0.01,  0.03, -0.03)
	f3 <-  0.5 * f(x0,  0.02,  0.00, -0.04,  0.04) *
		     f(x1,  0.20,  0.00,  0.50, -0.05)
	f4 <-  1.0 * f(x0,  0.02,  0.10,  0.01,  0.02) *
		     f(x2,  0.20,  0.10, -0.60,  0.06)
	f5 <-  5.0 * f(x1,  1.20, -0.25, -0.01,  0.20) *
		     f(x2,  0.60, -0.25, -0.10,  0.06)
	f6 <- 10.0 * f(x0,  0.10,  0.20,  0.25,  0.20) *
		     f(x1, -1.20,  0.03,  0.10,  1.20) *
		     f(x2,  0.50,  0.40, -0.20,  0.60)
	y <- f0 + f1 + f2 + f3 + f4 + f5 + f6 + e
	dat <- data.frame(y, x0, x1, x2)
	return(dat)
}
