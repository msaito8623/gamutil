#' Varying values for prediction
#'
#' For prediction with a regression model, you need to create a new data.frame
#' to specify which combinations of predictors you would like to use for
#' prediction. This function constitutes a part of the process and produces a
#' sequence of values based on the vector provided through the argument "vec".
#' If the vector is numeric, a vector of numeric values in the range between
#' min(vec) and max(vec) with the length of "len" is returned. If the vector is
#' character or factor, the sorted unique values of the elements in the vector
#' are returned.
#'
#' @param vec A vector of numeric, character, or factor, based on which values
#' are produced for prediction.
#' @param len A single numeric value, which indicates how many unique values
#' are required for each of the varied variables.
#' @return A vector of numeric or character (depending on the class of "vec"
#' provided).
#' @author Motoki Saito, \email{motoki.saito@uni-tuebingen.de}
#' @keywords utilities
#' @examples
#' # The sorted unique values are returned for character/factor.
#' vec <- c(rep('A',2), rep('B',3), rep('C',1))
#' print(constant(vec)) # 'A', 'B', 'C'
#' # A equally-spaced numeric sequence for the length of "len" is
#' # returned for numeric, with the min and max being the min and
#' # max of the input vector (i.e., "vec")
#' set.seed(716)
#' vec <- rnorm(10)
#' print(vary(vec))
#' print(vary(vec, 4))
#' @export
#'
vary <- function (vec, len=100) {
	if (is.numeric(vec)) {
		vec <- seq(min(vec), max(vec), length.out=len)
	} else if (is.character(vec)||is.factor(vec)) {
		vec <- sort(unique(vec))
	} else {
		stop('vec must be numeric, character, or factor.')
	}
	return(vec)
}
