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
#' @param facet.col A character of length 1. Split plots will be drawn for the
#' column with the name specified by this argument.
#' @param facet.labeller A named vector, whose names are old labels and whose
#' labels are corresponding new labels. This named vector is used to rename
#' names of facets.
#' @param se Logical to indicate whether contour lines should be drawn for 1 x
#' standard error.
#' @param break.interval A numeric, indicating the interval from one to another
#' contour line. This argument is not used if "line.breaks" and
#' "color.breaks" are provided.
#' @param line.breaks A numeric vector for contour lines.
#' @param color.breaks A numeric vector for colors for the z-axis.
#' @param zlim A numeric vector with length 2, which indicates the range of the
#' z-axis.
#' @param contour.labels Logical. With TRUE (default), contour labels will be
#' drawn.
#' @param contour.line.size A numeric with its length 1. It controls thickness
#' of contour lines. The default is 0.5.
#' @return A ggplot object of a contour plot with predicted values being colors
#' (z-axis).
#' @author Motoki Saito, \email{motoki.saito@uni-tuebingen.de}
#' @keywords utilities
#' @examples
#' \dontrun{
#' library(mgcv)
#' set.seed(534)
#' dat <- gamSim(eg=6,verbose=FALSE)
#' model <- gam(y ~ s(x0,by=fac) + s(x1,by=fac) + s(x2) + ti(x0,x1,by=fac),
#'              data=dat)
#' view <- c('x0','x1')
#' cnd  <- list(fac=c('1','4'))
#' ndat <- mdl_to_ndat(mdl=model, target=view, cond=cnd, len=10, method=median)
#' ndat <- add_fit(ndat, model, terms=view, cond=cnd, terms.size="min",
#'                 ci.mult=1)
#' plt <- ndat_to_contour(ndat, x='x0', y='x1', z='fit', z.lwr='lwr',
#'                        z.upr='upr', facet.col='fac', se=TRUE)
#' print(plt)
#' }
#' @importFrom ggplot2 ggplot aes stat_contour scale_fill_gradientn
#' guides guide_legend theme element_blank scale_colour_manual
#' scale_linetype_manual scale_size_manual scale_linewidth_manual layer_scales
#' facet_wrap .data
#' @importFrom metR geom_contour_fill
#' @importFrom RColorBrewer brewer.pal
#' @importFrom grDevices colorRampPalette
#' @export
ndat_to_contour  <- function (ndat, x, y, z, z.lwr='lwr', z.upr='upr',
			      facet.col=NULL, facet.labeller=NULL, se=TRUE,
			      break.interval=NULL, line.breaks=NULL,
			      color.breaks=NULL, zlim=NULL,
			      contour.labels=TRUE, contour.line.size=0.5)
{
	ndat <- data.frame(ndat)
	if (is.null(zlim)) {
		zmin <- min(ndat[[z]], na.rm=TRUE)
		zmax <- max(ndat[[z]], na.rm=TRUE)
	} else {
		zmin <- min(zlim, na.rm=TRUE)
		zmax <- max(zlim, na.rm=TRUE)
	}
	if (is.null(break.interval)) {
		break.interval <- (zmax-zmin)/10
	}
	brk1by <- break.interval
	brk2by <- brk1by/10
	if (is.null(line.breaks)) {
		rng1 <- seq(zmin,zmax,by=brk1by)	
		line.breaks <- round(rng1, 2)
	}
	if (is.null(color.breaks)) {
		rng2 <- seq(zmin,zmax,by=brk2by)
		color.breaks <- round(rng2, 2)
	}
	line.breaks <- unique(line.breaks)
	color.breaks <- unique(color.breaks)
	if (se) {
		cdat <- ndat[,c(x, y, z, z.lwr, z.upr, facet.col)]
	} else {
		cdat <- ndat[,c(x, y, z, facet.col)]
	}

	stck <- cdat[,c(x, y, facet.col)]
	colname.type <- 'type'
	if (colname.type %in% colnames(stck)) {
		colname.type <- '.type'
	}
	if (se) {
		stck <- rbind(stck,stck,stck)
		stck[[z]]  <- c(cdat[[z]], cdat[[z.upr]], cdat[[z.lwr]])
		stck[[colname.type]] <- rep(c(z, z.upr, z.lwr),
					    each=nrow(cdat))
		lvls <- c(z.lwr, z, z.upr)
		lbls <- c('+1se','','-1se')
		stck[[colname.type]] <- factor(stck[[colname.type]],
					       levels=lvls, labels=lbls)
	} else {
		stck[[z]]  <- c(cdat[[z]])
		stck[[colname.type]] <- rep(c(z), each=nrow(cdat))
		stck[[colname.type]] <- factor(stck[[colname.type]])
	}

	plt <- ggplot(mapping=aes(x=.data[[x]], y=.data[[y]], z=.data[[z]]))
	plt <- plt + metR::geom_contour_fill(data=cdat, mapping=aes(),
					     breaks=color.breaks)
	plt <- plt + stat_contour(data=stck,
				  mapping=aes(linetype=.data[[colname.type]],
					      colour=.data[[colname.type]],
					      linewidth=.data[[colname.type]]),
				  breaks=line.breaks)
	plt <- plt + scale_linewidth_manual(values=c(0.5,0.5,1.0))
	if (se) {
		cls <- brewer.pal(3,'Dark2')[1:2]
		cls <- c(cls[2], '#000000',cls[1])
		plt <- plt + scale_colour_manual(values=cls)
		plt <- plt + scale_linetype_manual(
					values=c('dashed','solid','dotted'))
		lsz <- c(rep(contour.line.size,2), contour.line.size*2)
		plt <- plt + scale_size_manual(values=lsz)
	} else {
		plt <- plt + scale_colour_manual(values=c('#000000'),
						 guide='none')
		plt <- plt + scale_linetype_manual(values=c('solid'),
						   guide='none')
		plt <- plt + scale_size_manual(values=contour.line.size,
					       guide='none')
	}
	if (contour.labels) {
		plt <- plt + metR::geom_text_contour(data=cdat,
						     aes(fontface='bold'),
						     stroke=0.1,
						     breaks=line.breaks,
						     skip=0)
	}
	mycls <- brewer.pal(11, 'Spectral') 
	mycls <- rev(colorRampPalette(mycls)(length(color.breaks)))
	if (is.null(zlim)) {
		plt <- plt + scale_fill_gradientn(name=NULL, colours=mycls)
	} else {
		plt <- plt + scale_fill_gradientn(name=NULL,
						  limits=zlim, colours=mycls)
	}
	if (se) {
		plt <- plt + guides(colour=guide_legend(order=1),
				    linewidth=guide_legend(order=1),
				    linetype=guide_legend(order=1))
	}
	plt <- plt + theme(legend.title=element_blank())
	if (!is.null(facet.col)) {
		if (!is.factor(ndat[[facet.col]])) {
			ndat[[facet.col]] <- factor(ndat[[facet.col]])
		}
		if (is.null(facet.labeller)) {
			plt <- plt + facet_wrap(~get(facet.col))
		} else {
			plt <- plt + facet_wrap(~get(facet.col),
				labeller=ggplot2::as_labeller(facet.labeller))
		}
	}
	return(plt)
}

