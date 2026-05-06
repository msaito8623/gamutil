#' Curve plot of a partial effect from a GAM model.
#'
#' Smooth/line counterpart to \code{\link{plot_contour}}. Builds a ggplot
#' showing a fitted curve (with optional standard-error ribbon) for the
#' partial effect of one continuous predictor, optionally split by a factor.
#' Mirrors the argument conventions of \code{plot_contour} (\code{summed},
#' \code{cond}, \code{terms.size}, \code{joint.se}, ...) for symmetry.
#'
#' Two view configurations are supported in this version:
#' \itemize{
#'   \item one continuous predictor \code{view = c("x")} -- a single line
#'         with an SE ribbon;
#'   \item one continuous + one categorical \code{view = c("x", "f")} (in
#'         either order) -- one line per level of \code{f}, coloured by
#'         level.
#' }
#'
#' When \code{view} contains a factor, the factor is automatically added to
#' \code{cond} (with all levels) if it is not already present, so that
#' \code{add_fit}'s by-variable expansion has the levels it needs.
#'
#' @param mdl An object of \code{mgcv::gam} or \code{mgcv::bam}.
#' @param view A character vector of length 1 or 2 naming the predictor(s)
#' to vary. At least one must be numeric.
#' @param cond A list of variable names and their values to hold constant
#' for prediction. See \code{plot_contour}.
#' @param summed Logical. With \code{TRUE} (default), the full summed effect
#' (including the intercept) is drawn. With \code{FALSE}, only the terms
#' selected by \code{terms.size} on the variables in \code{view} are
#' included. See \code{plot_contour}.
#' @param axis.len Number of points along the continuous axis (default 100).
#' @param terms.size Passed through to \code{add_fit}.
#' @param se Logical. With \code{TRUE} (default), draw a +/- SE ribbon.
#' @param verbose Logical, passed through to \code{add_fit}.
#' @param include.parametric Logical, passed through to \code{add_fit}.
#' @param joint.se Logical, passed through to \code{add_fit}.
#' @return A ggplot object.
#' @author Motoki Saito, \email{motoki.saito@uni-oldenburg.de}
#' @keywords utilities
#' @examples
#' \donttest{
#' library(mgcv)
#' set.seed(1)
#' n <- 400
#' d <- data.frame(x = rnorm(n),
#'                 f = factor(sample(c("A","B","C"), n, TRUE)))
#' d$y <- d$x + ifelse(d$f == "A", 0.5*d$x, 0) + rnorm(n, 0, 0.5)
#' m <- bam(y ~ f + s(x, by = f, k = 3), data = d, method = "ML")
#' plot_curve(m, view = c("x", "f"), summed = FALSE,
#'            terms.size = "medium", joint.se = TRUE)
#' }
#' @importFrom ggplot2 ggplot aes geom_line geom_ribbon theme_bw .data
#' @importFrom stats median
#' @export
plot_curve <- function (mdl, view, cond=list(), summed=TRUE, axis.len=100,
			terms.size='min', se=TRUE, verbose=FALSE,
			include.parametric=TRUE, joint.se=FALSE)
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
	is_fac <- vapply(view,
			 function (v) is.factor(mf[[v]]) ||
				      is.character(mf[[v]]),
			 logical(1))

	if (sum(is_num) == 0L) {
		stop('"view" must contain at least one numeric variable.')
	}
	if (sum(is_num) + sum(is_fac) != length(view)) {
		stop('"view" variables must be numeric or factor/character.')
	}
	if (length(view) == 2L && sum(is_num) == 2L) {
		stop(paste0('Both view variables are numeric. ',
			    'Use plot_contour for a 2D plot.'))
	}

	x_var <- view[is_num][1L]
	f_var <- if (any(is_fac)) view[is_fac][1L] else NULL

	# Auto-add the factor view variable to cond (with all levels) so that
	# add_fit's by-variable expansion knows which levels to enumerate.
	if (!is.null(f_var) && !(f_var %in% names(cond))) {
		lev <- levels(mf[[f_var]])
		if (is.null(lev)) lev <- sort(unique(mf[[f_var]]))
		cond[[f_var]] <- lev
	}

	constant.method <- median
	ci.mult <- 1
	ndat <- mdl_to_ndat(mdl, view, cond, len = axis.len,
			    method = constant.method)
	if (summed) tms <- NULL else tms <- view
	ndat <- add_fit(ndat, mdl, tms, cond, terms.size, ci.mult, verbose,
			include.parametric, joint.se)

	if (!is.null(f_var)) {
		plt <- ggplot(ndat, aes(x = .data[[x_var]], y = .data$fit,
					 colour = .data[[f_var]],
					 fill   = .data[[f_var]]))
		if (se) {
			plt <- plt + geom_ribbon(aes(ymin = .data$lwr,
						     ymax = .data$upr),
						 colour = NA, alpha = 0.2)
		}
		plt <- plt + geom_line(linewidth = 1)
	} else {
		plt <- ggplot(ndat, aes(x = .data[[x_var]], y = .data$fit))
		if (se) {
			plt <- plt + geom_ribbon(aes(ymin = .data$lwr,
						     ymax = .data$upr),
						 alpha = 0.2)
		}
		plt <- plt + geom_line(linewidth = 1)
	}
	plt <- plt + theme_bw()
	return(plt)
}
