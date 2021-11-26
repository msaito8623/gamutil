#' Contour plot from a GAM model object.
#'
#' This function takes a gam/bam object and names of predictors of interest and
#' draw a contour plot. Its usage is similar to itsadug::fvisgam and
#' itsadug::pvisgam. The current version of this function produces "partially
#' summed" effects of pertinent terms specified by the "view" argument (see
#' examples).
#'
#' @param mdl An object of mgcv::gam or mgcv::bam.
#' @param view A character vector with length of 2, which will be the x- and
#' y-axes of the generated plot.
#' @param axis.len A single numeric value, which will be length of each of the
#' x- and y-axes. Since this function builds a contour plot, length of x-axis
#' times length of y-axis is the total size of the contour plot to be produced.
#' Reducing the size of the contour plot to be produced would help computation.
#' @param break.interval A single numeric value, indicating the interval from
#' one to another contour line. This argument is not used if
#' "contour.line.breaks" and "contour.color.breaks" are provided.
#' @param contour.line.breaks A numeric vector for contour lines.
#' @param contour.color.breaks A numeric vector for colors for the z-axis.
#' @param zlim A numeric vector with length of 2, which indicates the range of
#' the z-axis.
#' @return A ggplot object, which is a contour line plot with predicted values
#' as colors (z-axis).
#' @author Motoki Saito, \email{motoki.saito@uni-tuebingen.de}
#' @keywords utilities
#' @examples
#' library(mgcv)
#' set.seed(534)
#' dat <- gamSim(verbose=FALSE)
#' model <- gam(y ~ s(x0) + s(x1) + s(x2) + ti(x0,x1), data=dat)
#' # The following line produces the effects summed over s(x0), s(x1), and
#' # ti(x0,x1).
#' plt <- plot_contour(model, view=c('x0','x1'))
#' print(plt)
#' @importFrom stats median
#' @export
#'
plot_contour <- function (mdl, view, axis.len=10, break.interval=NULL,
			  contour.line.breaks=NULL, contour.color.breaks=NULL,
			  zlim=NULL)
{
	x <- view[1]
	y <- view[2]
	constant.method <- median
	ci.mult <- 1
	ndat <- mdl_to_ndat(mdl, target=view,
			    len=axis.len, method=constant.method)
	ndat <- add_fit(ndat, mdl, terms=view, ci.mult)
	plt  <- ndat_to_contour(ndat, x, y, 'fit', 'lwr', 'upr',
				break.interval, contour.line.breaks,
				contour.color.breaks, zlim)
	return(plt)
}
