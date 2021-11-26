#' Contour plot from a data.frame with combinations of predictor values.
#'
#' This function takes a new data.frame which contains combinations of
#' predictor values of interest (i.e., newdata or ndat) and returns a contour
#' plot from the data.frame. "ndat" necessary for this function can be
#' generated with gamutil::mdl_to_ndat and gamutil::add_fit.
#'
#' @param ndat A data.frame with combinations of predictor values and predicted
#' values and confidence intervals.
#' @param x A character string with length 1 for the name of the variable used
#' for the x-axis.
#' @param y A character string with length 1 for the name of the variable used
#' for the y-axis.
#' @param z A character string with length 1 for the name of the variable used
#' for the z-axis (color).
#' @param z.lwr A character string with length 1 for the name of the column for
#' lower confidence interval boundary.
#' @param z.upr A character string with length 1 for the name of the column for
#' upper confidence interval boundary.
#' @param break.interval A numeric, indicating the interval from one to another
#' contour line. This argument is not used if "line.breaks" and
#' "color.breaks" are provided.
#' @param line.breaks A numeric vector for contour lines.
#' @param color.breaks A numeric vector for colors for the z-axis.
#' @param zlim A numeric vector with length 2, which indicates the range of the
#' z-axis.
#' @return A ggplot object of a contour plot with predicted values being colors
#' (z-axis).
#' @author Motoki Saito, \email{motoki.saito@uni-tuebingen.de}
#' @keywords utilities
#' @examples
#' library(mgcv)
#' set.seed(534)
#' dat <- gamSim(verbose=FALSE)
#' model <- gam(y ~ s(x0) + s(x1) + s(x2) + ti(x0,x1), data=dat)
#' to_vary <- c('x0','x1')
#' ndat <- mdl_to_ndat(mdl=model, target=to_vary, len=10, method=median)
#' ndat <- add_fit(ndat, model)
#' plt <- ndat_to_contour(ndat, x='x0', y='x1', z='fit',
#'                        z.lwr='lwr', z.upr='upr')
#' print(plt)
#' @importFrom ggplot2 ggplot aes aes_string stat_contour scale_fill_gradientn
#' guides guide_legend theme element_blank scale_colour_manual
#' scale_linetype_manual scale_size_manual layer_scales
#' @importFrom metR geom_contour_fill
#' @importFrom RColorBrewer brewer.pal
#' @importFrom grDevices colorRampPalette
#' @export
#'
ndat_to_contour  <- function (ndat, x, y, z, z.lwr='lwr', z.upr='upr',
			      break.interval=NULL, line.breaks=NULL,
			      color.breaks=NULL, zlim=NULL)
{
	if (is.null(break.interval)) {
		break.interval <- (max(ndat[[z]])-min(ndat[[z]]))/10
	}
	brk1by <- break.interval
	brk2by <- brk1by/10
	if (is.null(line.breaks)) {
		rng1 <- seq(min(ndat[[z]]),max(ndat[[z]]),by=brk1by)	
		line.breaks <- round(rng1, 2)
	}
	if (is.null(color.breaks)) {
		rng2 <- seq(min(ndat[[z]]),max(ndat[[z]]),by=brk2by)
		color.breaks <- round(rng2, 2)
	}
	cdat <- ndat[,c(x, y, z, z.lwr, z.upr)]
	stck <- cdat[,c(x, y)]
	stck <- rbind(stck,stck,stck)
	stck$fit  <- c(cdat[[z]], cdat[[z.upr]], cdat[[z.lwr]])
	stck$type <- rep(c(z, z.upr, z.lwr), each=nrow(cdat))
	lvls <- c(z.lwr, z, z.upr)
	lbls <- c('+1se','','-1se')
	stck$type <- factor(stck$type, levels=lvls, labels=lbls)
	plt <- ggplot(mapping=aes_string(x=x, y=y, z=z))
	plt <- plt + metR::geom_contour_fill(data=cdat, mapping=aes(),
					     breaks=color.breaks)
	plt <- plt + stat_contour(data=stck,
				  mapping=aes_string(linetype='type',
						     colour='type',
						     size='type'),
				  breaks=line.breaks)
	cls <- brewer.pal(3,'Dark2')[1:2]
	cls <- c(cls[2], '#000000',cls[1])
	plt <- plt + scale_colour_manual(values=cls)
	plt <- plt + scale_linetype_manual(values=c('dashed','solid','dotted'))
	plt <- plt + scale_size_manual(values=c(0.5,0.5,1.0))
	plt <- plt + metR::geom_text_contour(data=cdat,
					     aes(fontface='bold'),
					     stroke=0.1,
					     breaks=line.breaks,
					     skip=0)
	mycls <- brewer.pal(11, 'Spectral') 
	mycls <- rev(colorRampPalette(mycls)(length(color.breaks)))
	if (is.null(zlim)) {
		plt <- plt + scale_fill_gradientn(name=NULL, colours=mycls)
	} else {
		plt <- plt + scale_fill_gradientn(name=NULL,
						  limits=zlim, colours=mycls)
	}
	plt <- plt + guides(colour=guide_legend(order=1),
			    size=guide_legend(order=1),
			    linetype=guide_legend(order=1))
	plt <- plt + theme(legend.title=element_blank())
	return(plt)
}

