#' Plot a partial effect, dispatching by view-variable types.
#'
#' Convenience wrapper that picks between \code{\link{plot_contour}} and
#' \code{\link{plot_curve}} based on the types of the variables named in
#' \code{view}:
#' \itemize{
#'   \item two numeric -> \code{plot_contour} (2D contour plot);
#'   \item one numeric, or one numeric + one factor -> \code{plot_curve}
#'         (line plot, optionally split by factor).
#' }
#' Additional arguments are forwarded to whichever underlying function is
#' selected. Arguments that the dispatched target does not accept (e.g.
#' contour-specific arguments like \code{too.far} or \code{zlim} when
#' dispatching to \code{plot_curve}) are silently dropped, so the same
#' call site can be reused across model shapes.
#'
#' @param mdl An object of \code{mgcv::gam} or \code{mgcv::bam}.
#' @param view A character vector of length 1 or 2.
#' @param ... Further arguments forwarded to \code{plot_contour} or
#' \code{plot_curve}, depending on the dispatch.
#' @return A ggplot object.
#' @author Motoki Saito, \email{motoki.saito@uni-oldenburg.de}
#' @keywords utilities
#' @examples
#' \donttest{
#' library(mgcv)
#' set.seed(1)
#'
#' # Two numeric view variables -> contour plot.
#' dat2 <- gamSim(eg=2, verbose=FALSE)$data
#' mdl_2num <- gam(y ~ s(x, z), data=dat2)
#' plot_partial(mdl_2num, view = c("x", "z"), summed = FALSE,
#'              terms.size = "medium", joint.se = TRUE, too.far = 0.10)
#'
#' # One numeric + one factor -> curve plot, one line per factor level.
#' n <- 400
#' d  <- data.frame(x = rnorm(n),
#'                  f = factor(sample(c("A","B","C"), n, TRUE)))
#' d$y <- d$x + ifelse(d$f == "A", 0.5*d$x, 0) + rnorm(n, 0, 0.5)
#' mdl_num_fac <- bam(y ~ f + s(x, by = f, k = 3), data = d, method = "ML")
#' plot_partial(mdl_num_fac, view = c("x", "f"), summed = FALSE,
#'              terms.size = "medium", joint.se = TRUE)
#' }
#' @export
plot_partial <- function (mdl, view, ...)
{
	if (length(view) < 1L || length(view) > 2L) {
		stop('"view" must be of length 1 or 2.')
	}
	mf <- mdl$model
	missing <- setdiff(view, names(mf))
	if (length(missing) > 0) {
		stop('"view" not in mdl$model: ',
		     paste(missing, collapse = ', '))
	}
	is_num <- vapply(view,
			 function (v) is.numeric(mf[[v]]),
			 logical(1))
	if (length(view) == 2L && all(is_num)) {
		target <- plot_contour
	} else {
		target <- plot_curve
	}
	# Filter ... to arguments the dispatch target accepts, so callers can
	# pass plot_contour-only or plot_curve-only arguments without errors.
	valid <- names(formals(target))
	args  <- list(...)
	args  <- args[names(args) %in% valid]
	do.call(target, c(list(mdl = mdl, view = view), args))
}
