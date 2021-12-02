#' Create a data.frame from a GAM object for prediction
#'
#' In order to obtain predicted values from a GAM object, you need to provide a
#' data.frame with combinations of values for the predictors in the model to
#' mgcv::predict.gam. This function does this job only by giving it a GAM
#' object (i.e., mdl) and telling it which variables you would like to vary
#' (i.e, target).
#'
#' @param mdl A GAM object (gam or bam), from which you would like to obtain
#' predictions.
#' @param target A character vector, which indicates variables to vary.
#' @param cond A list of variables (as names) and their values. "cond"
#' overrides "target".
#' @param len A numeric, which specifies length of each varied variable, when
#' the variable is numeric.
#' @param method A function that takes a vector of numerics and returns a
#' single value (e.g., median as default). The function given through this
#' argument is used to produce a constant value for each of the numeric
#' variables you would like to keep constant.
#' @return A data.frame with the variables specified by "target" being varied
#' and the other variables being kept constant. The returned data.frame should
#' be ready to be used for, e.g., predict.gam.
#' @author Motoki Saito, \email{motoki.saito@uni-tuebingen.de}
#' @keywords utilities
#' @examples
#' library(mgcv)
#' set.seed(534)
#' dat <- gamSim(verbose=FALSE)
#' model <- gam(y ~ s(x0) + s(x1) + s(x2) + s(x3), data=dat)
#' target_to_vary <- c('x0','x1')
#' condlist <- list('x2'=quantile(dat$x2, probs=c(0.25,0.75)))
#' ndat <- mdl_to_ndat(mdl=model, target=target_to_vary,
#'                     cond=condlist, len=4, method=median)
#' print(length(unique(ndat$x0))==4) # x0 is varied with length=4.
#' print(length(unique(ndat$x1))==4) # x1 is varied with length=4.
#' print(length(unique(ndat$x2))==2) # x2 is 25% or 75% quantiles.
#' print(length(unique(ndat$x3))==1) # x3 is fixed the median.
#' @importFrom stats median
#' @export
#'
mdl_to_ndat <- function (mdl, target=c(), cond=list(), len=100, method=median) {
	.dat <- mdl$model
	depv <- as.character(as.list(mdl$formula)[[2]])
	.dat <- .dat[,!(colnames(.dat)%in%c(depv,'(AR.start)'))]
	.inner <- function (i) {
		if (i%in%names(cond)) {
			aaa <- cond[[i]]
		} else if (i%in%target) {
			aaa <- vary(.dat[[i]], len)
		} else {
			aaa <- constant(.dat[[i]], method)
		}
		return(aaa)
	}
	ndat <- lapply(colnames(.dat), .inner)
	names(ndat) <- colnames(.dat)
	ndat <- expand.grid(ndat)
	return(ndat)
}
