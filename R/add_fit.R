#' Add predicted values with standard errors to a data.frame
#'
#' In order to obtain predictions from a regression model, you need to first
#' create a data.frame with combinations of values of the variables in the
#' model, feed it to some function for prediction (e.g., predict.gam), and add
#' upper and lower boundaries for confidence intervals yourself. This function
#' takes such a data.frame (i.e., "ndat") and add predicted values and standard
#' errors based on the model provided through "mdl". "ndat" can be created by
#' gamutil::to_ndat.
#'
#' @param ndat A data.frame, which should already contain combinations of
#' values of the predictors in the model.
#' @param mdl A GAM object, from which predicted values are taken.
#' @param terms A character string, which specifies which terms in the model
#' you would like to use to obtain predicted values.
#' @param cond A list, whose names are variable names and whose values are
#' their corresponding values.
#' @param terms.size A character of length 1, which is "min" (default),
#' "medium", or "max". "min" selects only one term that exactly contains the
#' variables specified by "terms" and "cond" (i.e. the target variables) with
#' no other variable. Therefore, it corresponds to a partial effect by the
#' term, as produced by mgcv::plot.gam or itsadug::pvisgam. "medium" selects
#' the terms that contain at least one of the target variables but no other.
#' This option is useful to see the sum of partial effects, e.g. s(x0) + s(x1)
#' + ti(x0,x1). "max" selects all the terms that contain at least one of the
#' target variables even if the term has other variables than given by "terms"
#' and "cond". For example, terms=c(x0,x1) and cond=list(fac='a') with
#' terms.size='max' also selects ti(x0,x2,by=fac), which contains "x2" that are
#' not specified by either "terms" or "cond", in addition to s(x0,by=fac),
#' s(x1,by=fac), ti(x0,x1,by=fac), and so on.
#' @param ci.mult A numeric to multiply standard errors.
#' @param verbose Logical. With this argument TRUE, it is printed out which
#' terms are selected to calculate predicted values and some explanations will
#' be printed when an error occurs.
#' @return The data.frame provided through "ndat" with additional columns for
#' predicted values (i.e., fit) and upper and lower confidence interval
#' boundaries (i.e., upr and lwr).
#' @author Motoki Saito, \email{motoki.saito@uni-tuebingen.de}
#' @keywords utilities
#' @examples
#' \dontrun{
#' library(mgcv)
#' set.seed(534)
#' dat <- gamSim(eg=6, verbose=FALSE)
#' model <- gam(y ~ s(x0) + s(x1) + s(x2) + s(x3)
#'                + ti(x0,x1) + ti(x0,x2) + ti(x0,x3)
#'                + ti(x1,x2) + ti(x1,x3) + ti(x2,x3), data=dat)
#' target_to_vary <- c('x0','x1')
#' ndat <- mdl_to_ndat(mdl=model, target=target_to_vary, len=4, method=median)
#' terms_to_predict <- target_to_vary
#' # Prediction of the summed effect by all the terms:
#' ndat1 <- add_fit(ndat, model, verbose=TRUE)
#' # Partial effect of ti(x0, x1):
#' ndat2 <- add_fit(ndat, model, terms=terms_to_predict, terms.size="min",
#'                  verbose=TRUE)
#' # Sum of subordinate partial effects (i.e., s(x0), s(x1), ti(x0,x1)):
#' ndat3 <- add_fit(ndat, model, terms=terms_to_predict, terms.size="medium",
#'                  verbose=TRUE)
#' # Sum of all the pertinent partial effects (i.e., s(x0), s(x1), ti(x0,x1),
#' # ti(x0,x2), ti(x0,x3), ti(x1,x2), ti(x1,x3)):
#' ndat4 <- add_fit(ndat, model, terms=terms_to_predict, terms.size="max",
#'                  verbose=TRUE)
#' }
#' @importFrom mgcv predict.gam
#' @importFrom stats qnorm 
#' @export
add_fit <- function (ndat, mdl, terms=NULL, cond=list(), terms.size='min',
		     ci.mult=qnorm(0.975), verbose=FALSE) {
	if (is.null(terms)) {
		if (verbose) {
			cat('Selected: All (summed effect).\n')
		}
		pred <- predict.gam(mdl, newdata=ndat, se.fit=TRUE)
		ndat$fit <- pred$fit
		ndat$se  <- pred$se.fit
	} else {
		cols <- as.character(mdl$formula)[3]
		cols <- strsplit(cols, split=' \\+ ')[[1]]
		pos <- find.pos(cols, terms, cond, terms.size)
		if (!any(pos)) {
			if (verbose) {
				print.verbose(terms, terms.size, cols)
			}
			stop('No term matched.')
		}
		cols <- cols[pos]
		byvar <- find.by(cols)
		if ( (nchar(byvar)>0) & !(byvar%in%names(cond)) ) {
			stop('"by" must be included in "cond".')
		}
		cols <- gsub(' ','', cols)
		if (byvar!='') {
			cols <- gsub('^(.+),by=(.+?)([,\\)].*)$', '\\1\\3:\\2',
				     cols)
			cols.noby <- grep(byvar, cols, value=TRUE, invert=TRUE)
			cols <- grep(byvar, cols, value=TRUE, invert=FALSE)
			cols <- expand.grid(cols, cond[[byvar]])
			cols <- apply(cols, 1, paste, collapse='')
			cols <- c(cols, cols.noby)
		}
		cols <- remove.k(cols)
		sw   <- suppressWarnings
		pg   <- predict.gam
		pred <- sw(pg(mdl, ndat, se.fit=TRUE,
			      terms=cols, type='terms'))
		ndat$fit <- rowSums(pred$fit)
		ndat$se  <- sqrt(rowSums(pred$se.fit^2))

		if (verbose) {
			txt <- paste(cols, collapse='\n')
			cat(sprintf('Selected:\n%s\n', txt))
		}
	}
	ndat$upr <- ndat$fit + ci.mult * ndat$se
	ndat$lwr <- ndat$fit - ci.mult * ndat$se
	return(ndat)
}
find.pos <- function (cols, terms, cond, terms.size) {
	pos <- cols
	pos <- remove.k(pos)
	pos <- gsub(', *bs *= *"re"', '',pos)
	pos <- gsub('by *= *', '',pos)
	pos <- gsub('^[a-z]+\\((.+)\\)$', '\\1', pos)
	pos <- strsplit(pos, split=', ')
	tms <- c(terms, names(cond))
	if (terms.size=='max') {
		pos <- vapply(pos, pos.max, tms, FUN.VALUE=logical(1),
			      USE.NAMES=FALSE)
	} else if (terms.size=='medium') {
		pos <- vapply(pos, pos.medium, tms, FUN.VALUE=logical(1),
			      USE.NAMES=FALSE)
	} else if (terms.size=='min') {
		pos <- vapply(pos, pos.min, tms, FUN.VALUE=logical(1),
			      USE.NAMES=FALSE)
	} else {
		stop('"terms.size" must be "max", "medium", or "min".')
	}
	return(pos)
}
remove.k <- function (pos) {
	pos <- gsub(', *k *= *[0-9]+', '',pos)
	pos <- gsub(', *k *= *c\\([0-9, ]+\\)', '',pos)
	return(pos)
}
pos.max <- function (x, terms) {
	return(any(x%in%terms))
}
pos.medium <- function (x, terms) {
	return(all(x%in%terms))
}
pos.min <- function (x, terms) {
	if (length(x)!=length(terms)) {
		return(FALSE)
	} else {
		return(all(sort(x)==sort(terms)))
	}
}
find.by <- function (xxx) {
	xxx <- grep('by *= *', xxx, value=TRUE)
	xxx <- gsub('^.+by *= *(.+?)[,\\)].*$', '\\1', xxx)
	xxx <- unique(xxx)
	if (length(xxx)==0) {
		xxx <- ''
	} else if (length(xxx)>1) {
		stop('Multiple "by" found.')
	}
	return(xxx)
}
print.verbose <- function (terms, terms.size, cols) {
	cat('\n###### VERBOSE ######\n')
	cat('ERROR: No term is matched.\n\n')
	cat(sprintf('terms = c(%s)\n', paste(terms, collapse=', ')))
	cat(sprintf('terms.size = %s\n', terms.size))
	cat(sprintf('Available terms:\n--> %s\n', paste(cols, collapse=', ')))
	if (terms.size=='min') { verb.min(terms, terms.size) }
	else if (terms.size=='medium') { verb.medium(terms, terms.size) }
	else if (terms.size=='max') { verb.max(terms, terms.size) }
	cat('\nDid you maybe forget to specify ')
	cat('a level of the "by" variable?\n')
	cat('"by" variables need to be included in "cond".\n')
	cat('e.g., ti(x0,x1,by=fac)\n')
	cat('--> view/terms=c("x0","x1"), cond=list(fac="1").\n')
	cat('\nOr maybe did you include unnecessary variables in "cond"?\n')
	cat('e.g., view/terms=c("x0","x1"), cond=list(fac="1", x2=0.5)\n')
	cat('--> The terms that also contain "x2" are searched ')
	cat('such as ti(x0,x1,x2,by=fac)\n')
	cat('--> Then ti(x0,x1,by=fac) would be excluded for example ')
	cat('when terms.size="min".\n\n')
	cat('I hope this explanation helps!.\n')
	cat('###### VERBOSE ######\n\n')
}
verb.min <- function (terms, terms.size) {
	cat(sprintf('\nSince terms.size=%s, ', terms.size))
	cat('the only one term that matches exactly ')
	cat(sprintf('c(%s) ', paste(terms,collapse=', ')))
	cat('was searched.\n')
}
verb.medium <- function (terms, terms.size) {
	cat(sprintf('\nSince terms.size=%s, ', terms.size))
	cat('the terms were searched that contain ')
	cat('only the elements in ')
	cat(sprintf('c(%s).\n',paste(terms,collapse=', ')))
}
verb.max <- function (terms, terms.size) {
	cat(sprintf('\nSince terms.size=%s, ', terms.size))
	cat('the terms were searched that contain ')
	cat('at least one of the elements in ')
	cat(sprintf('c(%s).\n', paste(terms,collapse=', ')))
}
