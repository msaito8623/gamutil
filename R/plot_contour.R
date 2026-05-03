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
#' @param cond A list of variables names and their corresponding values, e.g.
#' list(fac='A'), which are not included in "view".
#' @param summed Logical. With summed=TRUE (default), the sum of all the terms
#' in a model will be drawn as a contour plot. With summed=FALSE, only the
#' terms specified by "view" and "cond" are included to obtain predicted
#' values. See also the argument "terms.size".
#' @param axis.len A single numeric value, which will be length of each of the
#' x- and y-axes. Since this function builds a contour plot, length of x-axis
#' times length of y-axis is the total size of the contour plot to be produced.
#' Reducing the size of the contour plot to be produced would help computation.
#' @param terms.size A character of length 1, which is "min", "medium", or
#' "max". This argument controls which terms to include to make prediction.
#' "min" produces a partial effect of a single term that contains no more or
#' less than the variables specified by "view" and "cond" (i.e., target
#' variables). "medium" includes all the terms that have at least one of the
#' target variables but exclude any term that has an extra variable. "max"
#' includes all the terms that have at least one of the target variables,
#' including also the terms with extra variables that are not specified by
#' either "view" or "cond" as long as they have at least one of the target
#' variables.
#' @param se Logical, which indicates whether standard error contour lines
#' should be drawn (default=TRUE).
#' @param break.interval A single numeric value, indicating the interval from
#' one to another contour line. This argument is not used if
#' "contour.line.breaks" and "contour.color.breaks" are provided.
#' @param contour.line.breaks A numeric vector for contour lines.
#' @param contour.color.breaks A numeric vector for colors for the z-axis.
#' @param zlim A numeric vector with length of 2, which indicates the range of
#' the z-axis.
#' @param facet.labeller A named vector, whose names are old labels and whose
#' values are new values. Facet labels are renamed according to this named
#' vector.
#' @param verbose Logical. With verbose=TRUE, terms selected for prediction
#' were printed out and also some explanation will be provided when no term is
#' matched.
#' @param contour.labels Logical. With TRUE (default), contour labels will be
#' drawn.
#' @param contour.line.size A numeric with its length 1. It controls thickness
#' of contour lines. The default is 0.5.
#' @param include.parametric Logical, passed through to \code{add_fit}. With
#' TRUE (default), parametric terms (main effects and \code{:}-interactions)
#' are eligible for the partial-effect computation. With FALSE, only smooth
#' terms (\code{s}, \code{te}, \code{ti}, \code{t2}) are kept.
#' @param joint.se Logical, passed through to \code{add_fit}. With FALSE
#' (default), the SE of the summed partial effect is computed by summing
#' per-term variances; with TRUE, the joint SE is computed via the lpmatrix
#' and full \code{vcov(mdl)}, accounting for cross-term covariances.
#' @param too.far A single numeric or NULL. If non-NULL, grid cells whose
#' nearest data point is farther than \code{too.far} (Euclidean distance
#' after each axis is rescaled to \code{[0, 1]} via the data's min/max)
#' are masked out by setting \code{fit}, \code{se}, \code{lwr}, \code{upr}
#' to \code{NA}. This prevents the plot from showing extrapolated regions
#' the model has no support for. Typical values: 0.05 (strict), 0.10
#' (moderate), 0.20 (permissive). NULL (default) disables masking.
#' Mirrors the \code{too.far} argument of \code{mgcv::vis.gam} and
#' \code{itsadug::fvisgam}.
#' @return A ggplot object, which is a contour line plot with predicted values
#' as colors (z-axis).
#' @author Motoki Saito, \email{motoki.saito@uni-oldenburg.de}
#' @keywords utilities
#' @examples
#' \dontrun{
#' library(mgcv)
#' set.seed(534)
#' dat <- gamSim(eg=6, verbose=FALSE)
#' 
#' # Without "by"
#' mdl1 <- gam(y ~ s(x0) + s(x1) + s(x2) + ti(x0,x1), data=dat)
#' 
#' # With "by"
#' mdl2 <- gam(y ~ s(x0,by=fac) + s(x1,by=fac) + s(x2) + ti(x0,x1,by=fac),
#'             data=dat)
#' 
#' # Summed effects (i.e., s(x0) + s(x1) + s(x2) + ti(x0,x1)
#' plt <- plot_contour(mdl1, view=c('x0','x1'), summed=TRUE)
#' 
#' # Partial effect (i.e., ti(x0,x1))
#' plt <- plot_contour(mdl1, view=c('x0','x1'), summed=FALSE, terms.size='min')
#' 
#' # The sum of pertinent partial effects (i.e., s((x0) + s(x1) + ti(x0,x1))
#' # with confidence interval contour lines.
#' plt <- plot_contour(mdl1, view=c('x0','x1'), summed=FALSE,
#'                     terms.size='medium')
#' 
#' # The sum of pertinent partial effects (i.e., s((x0) + s(x1) + ti(x0,x1))
#' # without confidence interval contour lines.
#' plt <- plot_contour(mdl1, view=c('x0','x1'), summed=FALSE,
#'                     terms.size='medium', se=FALSE)
#' 
#' # Summed effects for fac='1'
#' plt <- plot_contour(mdl2, view=c('x0','x1'), cond=list(fac='1'),
#'                     summed=TRUE)
#' 
#' # Partial effect (i.e., ti(x0,x1)) for fac='1'
#' plt <- plot_contour(mdl2, view=c('x0','x1'), cond=list(fac='1'),
#'                     summed=FALSE, terms.size='min')
#' 
#' # Summed effects for fac='1' and '2' in separate panels
#' plt <- plot_contour(mdl2, view=c('x0','x1'), cond=list(fac=c('1','2')),
#'                     summed=TRUE)
#' 
#' # Partial effects (i.e., ti(x0,x1)) for fac='1' and '2' in separate panels
#' plt <- plot_contour(mdl2, view=c('x0','x1'), cond=list(fac=c('1','2')),
#'                     summed=FALSE, terms.size='min')
#' }
#' @importFrom stats median
#' @export
plot_contour <- function (mdl, view, cond=list(), summed=TRUE, axis.len=50,
			  terms.size='min', se=TRUE, break.interval=NULL,
			  contour.line.breaks=NULL, contour.color.breaks=NULL,
			  zlim=NULL, facet.labeller=NULL, verbose=FALSE,
			  contour.labels=TRUE, contour.line.size=0.5,
			  include.parametric=TRUE, joint.se=FALSE,
			  too.far=NULL)
{
	if (length(view)!=2) {
		stop('"view" must be length 2.')
	}
	x <- view[1]
	y <- view[2]
	constant.method <- median
	ci.mult <- 1
	ndat <- mdl_to_ndat(mdl, view, cond, len=axis.len,
			    method=constant.method)
	if (summed) tms<-NULL else tms<-view
	ndat <- add_fit(ndat, mdl, tms, cond, terms.size, ci.mult, verbose,
			include.parametric, joint.se)
	if (!is.null(too.far)) {
		# Pull the data points the model was actually fit on for the
		# two view variables, then NA-out grid cells too far from any.
		mf <- mdl$model
		if (!all(view %in% names(mf))) {
			stop('"view" variables must be in mdl$model for too.far.')
		}
		excl <- exclude_too_far(ndat[[x]], ndat[[y]],
					mf[[x]],   mf[[y]], too.far)
		if (any(excl)) {
			for (col in c('fit','se','lwr','upr')) {
				if (col %in% names(ndat)) ndat[[col]][excl] <- NA
			}
		}
	}
	if (length(cond)>0) {
		facet.cn <- names(cond)[vapply(names(cond), find.facet, ndat,
					       FUN.VALUE=logical(1),
					       USE.NAMES=FALSE)]
		if (length(facet.cn)==0) facet.cn<-NULL
	} else {
		facet.cn <- NULL
	}
	plt  <- ndat_to_contour(ndat=ndat, x=x, y=y, z='fit', z.lwr='lwr',
				z.upr='upr', facet.col=facet.cn,
				facet.labeller=facet.labeller, se=se,
				break.interval=break.interval,
				line.breaks=contour.line.breaks,
				color.breaks=contour.color.breaks,
				zlim=zlim,
				contour.labels=contour.labels,
				contour.line.size=contour.line.size)
	return(plt)
}
find.facet <- function (x, ndat) {
	isfac <- is.factor(ndat[[x]]) || is.character(ndat[[x]])
	len1  <- length(unique(ndat[[x]]))>1
	return(isfac&&len1)
}
# For each grid cell (gx[i], gy[i]), compute the Euclidean distance to its
# nearest data point (dx[j], dy[j]) after rescaling each axis to [0, 1] using
# the data's min/max (so x and y contribute equally regardless of unit).
# Returns a logical vector of length(gx): TRUE where the cell should be
# excluded because its nearest data point is farther than `too.far`.
exclude_too_far <- function (gx, gy, dx, dy, too.far) {
	if (is.null(too.far) || too.far <= 0) {
		return(rep(FALSE, length(gx)))
	}
	keep <- is.finite(dx) & is.finite(dy)
	dx <- dx[keep]; dy <- dy[keep]
	rx <- range(dx); ry <- range(dy)
	span_x <- rx[2] - rx[1]; span_y <- ry[2] - ry[1]
	if (span_x <= 0 || span_y <= 0) {
		return(rep(FALSE, length(gx)))
	}
	gx_n <- (gx - rx[1]) / span_x
	gy_n <- (gy - ry[1]) / span_y
	dx_n <- (dx - rx[1]) / span_x
	dy_n <- (dy - ry[1]) / span_y
	# G x N matrix of squared distances; min over rows gives nearest data
	# point per grid cell.
	D2 <- outer(gx_n, dx_n, function (a, b) (a - b)^2) +
	      outer(gy_n, dy_n, function (a, b) (a - b)^2)
	d_min <- sqrt(apply(D2, 1, min))
	d_min > too.far
}
