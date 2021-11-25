#' Keep a variable constant
#'
#' For prediction of a regression model, you need to create a data.frame for
#' the combinations of predictor values you would like to get the model's
#' predictions for. Sometimes you would like to keep some of the predictors
#' constant, e.g., their median values. It can be done with this function. This
#' function returns a single value from the vector provided through "vec" with
#' the function provided through "func" (median as default), if the provided
#' vector is numeric. If the vector is character or factor, then the value in
#' the vector with the most occurrences is taken as a representative value and
#' returned.
#'
#' @param vec A vector of numeric, character, or factor.
#' @param func A function, which should take a numeric vector and returns a
#' single numeric value.
#' @return A new format-like string, from which the terms you specified have
#' been removed.
#' @author Motoki Saito, \email{motoki.saito@uni-tuebingen.de}
#' @keywords utilities
#' @examples
#' # The most frequent occurrence is returned for character/factor.
#' vec <- c(rep('A',2), rep('B',3), rep('C',1))
#' print(constant(vec))
#' # The representative value by "func" is returned for numeric.
#' # (default=median)
#' set.seed(716)
#' vec <- rnorm(10)
#' print(constant(vec))
#' # Another function can be used, too (e.g., max).
#' print(constant(vec, max))
#' @importFrom stats median
#' @export
#'
constant <- function (vec, func=median) {
	if (is.numeric(vec)) {
		vec <- func(vec)
	} else if (is.character(vec)||is.factor(vec)) {
		vec <- names(rev(sort(table(vec))))[1]
	} else {
		stop('vec must be numeric, character, or factor.')
	}
	return(vec)
}

