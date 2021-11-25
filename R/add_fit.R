#' Add predicted values with standard errors to a data.frame
#'
#' In order to obtain predictions from a regression model, you need to first create a data.frame with combinations of values of the variables in the model, feed it to some function for prediction (e.g., predict.gam), and add upper and lower boundaries for confidence intervals yourself. This function takes such a data.frame (i.e., "ndat") and add predicted values and standard errors based on the model provided through "mdl". "ndat" can be created by gamutil::to_ndat.
#'
#' @param ndat A data.frame, which should already contain combinations of values of the predictors in the model.
#' @param mdl A GAM object, from which predicted values are taken.
#' @param terms A character string, which specifies which terms in the model you would like to use to obtain predicted values.
#' @param ci.mult A numeric to multiply standard errors.
#' @return The data.frame provided through "ndat" with additional columns for predicted values (i.e., fit) and upper and lower confidence interval boundaries (i.e., upr and lwr).
#' @author Motoki Saito, \email{motoki.saito@uni-tuebingen.de}
#' @keywords utilities
#' @examples
#' library(mgcv)
#' set.seed(534)
#' dat = gamSim(verbose=FALSE)
#' model = gam(y ~ s(x0) + s(x1) + s(x2) + ti(x0,x1), data=dat)
#' target_to_vary = c('x0','x1')
#' ndat = mdl_to_ndat(mdl=model, target=target_to_vary, len=4, method=median)
#' terms_to_predict = target_to_vary
#' # Prediction of the summed effect by all the terms.
#' ndat1 = add_fit(ndat, model)
#' # Prediction of partially summed effects by the terms with "x0" and "x1"
#' # (i.e., s(x0), s(x1), ti(x0,x1)).
#' ndat2 = add_fit(ndat, model, terms=terms_to_predict)
#' @import stats mgcv
#' @export
add_fit = function (ndat, mdl, terms=NULL, ci.mult=qnorm(0.975)) {
	if (is.null(terms)) {
		pred = predict.gam(mdl, newdata=ndat, se.fit=TRUE)
		ndat$fit = pred$fit
		ndat$se  = pred$se.fit
	} else {
		cols = strsplit(as.character(mdl$formula)[3], split=' \\+ ')[[1]]
		cols = cols[Reduce(union, lapply(terms, function(x) grep(x, cols)))]
		cols = gsub(' ','', cols)
		pred = suppressWarnings(predict.gam(mdl, newdata=ndat, se.fit=TRUE, terms=cols, type='terms'))
		ndat$fit = rowSums(pred$fit)
		ndat$se  = sqrt(rowSums(pred$se.fit^2))
	}
	ndat$upr = ndat$fit + ci.mult * ndat$se
	ndat$lwr = ndat$fit - ci.mult * ndat$se
	return(ndat)
}

