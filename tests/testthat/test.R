library(testthat)
library(mgcv)
library(ggplot2)

set.seed(534)
invisible(capture.output(tdat <- gamSim(eg=6,verbose=FALSE)))
tmdl  <- gam(y ~ s(x0, by=fac) + s(x1, by=fac, k=5) + s(x2)
	      + ti(x0,x1,by=fac) + ti(x0,x2,by=fac), data=tdat)
x2max <- max(tmdl$model$x2)
# load(system.file('testdata', 'ndat.rda', package='gamutil')) # loads "ndat"

test_that('mdl_to_ndat works properly without "cond".', {
	tgt <- c('x0','x1')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, len=10, method=median)
	expect_s3_class(ndat, 'data.frame')
	expect_equal(colnames(ndat), c('x0','fac','x1','x2'))
	expect_equal(nrow(ndat), 100)
	expect_length(unique(ndat$x0), 10)
	expect_length(unique(ndat$x1), 10)
	expect_length(unique(ndat$x2),  1)
	expect_length(unique(ndat$fac),  1)
	expect_equal(round(mean(ndat$x0),5), 0.50298)
	expect_equal(round(mean(ndat$x1),5), 0.49812)
	expect_equal(round(mean(ndat$x2),5), 0.50012)
})
test_that('mdl_to_ndat works properly with "cond".', {
	tgt <- c('x0','x1')
	clist <- list('x0'=10,'x1'=c(20,30),'x2'=c(40,50))
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=clist,
			    len=10, method=median)
	expect_s3_class(ndat, 'data.frame')
	expect_equal(colnames(ndat), c('x0','fac','x1','x2'))
	expect_equal(ndat$x0, rep(10,4))
	expect_equal(ndat$x1, rep(c(20,30),2))
	expect_equal(ndat$x2, rep(c(40,50),each=2))
})
test_that('mdl_to_ndat works with "cond" for only a subset of variables.', {
	tgt <- c('x0','x1')
	clist <- list('x1'=c(20,30))
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=clist,
			    len=10, method=median)
	expect_s3_class(ndat, 'data.frame')
	expect_equal(colnames(ndat), c('x0','fac','x1','x2'))
	expect_equal(nrow(ndat), 20)
	expect_length(unique(ndat$x0), 10)
	expect_length(unique(ndat$x1),  2)
	expect_length(unique(ndat$x2),  1)
	expect_equal(round(mean(ndat$x0),5), 0.50298)
	expect_equal(round(mean(ndat$x1),5),      25)
	expect_equal(round(mean(ndat$x2),5), 0.50012)
})
test_that('mdl_to_ndat works when the model has only one predictor', {
	tmdl  <- gam(y ~ s(x0), data=tdat)
	tgt <- c('x0')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, len=10, method=median)
	expect_s3_class(ndat, 'data.frame')
	expect_equal(colnames(ndat), c('x0'))
	expect_equal(nrow(ndat), 10)
	expect_length(unique(ndat$x0), 10)
	expect_equal(round(mean(ndat$x0),5), 0.50298)
})
test_that('add_fit works properly with "terms".', {
	tgt <- c('x0','x1')
	cnd <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=10,
			    method=median)
	ndat <- add_fit(ndat, tmdl, terms=tgt, cond=cnd)
	expect_s3_class(ndat, 'data.frame')
	expect_equal(nrow(ndat), 100)
	expect_equal(ncol(ndat), 8)
	expect_equal(round(mean(ndat$x0), 5),  0.50298)
	expect_equal(round(mean(ndat$x1), 5),  0.49812)
	expect_equal(round(mean(ndat$x2), 5),  0.50012)
	expect_equal(round(mean(ndat$fit),5), -0.15557)
	expect_equal(round(mean(ndat$se), 5),  2.32756)
	expect_equal(round(mean(ndat$upr),5),  4.40636)
	expect_equal(round(mean(ndat$lwr),5), -4.71749)
})
test_that('add_fit adds predicted summed effects with terms=NULL (default).', {
	tgt <- c('x0','x1')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt,
			    len=10, method=median)
	ndat <- add_fit(ndat, tmdl)
	expect_s3_class(ndat, 'data.frame')
	expect_equal(nrow(ndat), 100)
	expect_equal(ncol(ndat), 8)
	expect_equal(round(mean(ndat$x0), 5),  0.50298)
	expect_equal(round(mean(ndat$x1), 5),  0.49812)
	expect_equal(round(mean(ndat$x2), 5),  0.50012)
	expect_equal(round(mean(ndat$fit),5), 15.32548)
	expect_equal(round(mean(ndat$se), 5),  1.79049)
	expect_equal(round(mean(ndat$upr),5), 18.83477)
	expect_equal(round(mean(ndat$lwr),5), 11.81619)
})
test_that('plot_contour produces the same plot as plt1,plt2,plt3.', {
	tgt <- c('x0','x1')
	plt <- plot_contour(tmdl, view=tgt)
	gtypes <- vapply(plt$layers,
			 function(x) class(x$geom)[1],
			 character(1))
	expect_s3_class(plt, 'ggplot')
	expect_match(gtypes[1], 'GeomPolygon', fixed=TRUE)
	expect_match(gtypes[2], 'GeomContour', fixed=TRUE)
	expect_match(gtypes[3], 'GeomTextContour', fixed=TRUE)
	scl <- layer_scales(plt)
	expect_equal(round(scl$x$range$range[1],7), 0.0066501)
	expect_equal(round(scl$x$range$range[2],7), 0.9993194)
	expect_equal(round(scl$y$range$range[1],7), 0.0013797)
	expect_equal(round(scl$y$range$range[2],7), 0.9948520)
})
test_that('mdl_to_ndat, add_fit, and ndat_to_contour
	  produces the same as plot_contour.', {
	tgt <- c('x0','x1')
	cnd <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd,
			    len=50, method=median)
	ndat <- add_fit(ndat, tmdl, terms=tgt, cond=cnd, ci.mult=1,
			verbose=FALSE)
	plt0 <- ndat_to_contour(ndat, x=tgt[1], y=tgt[2],
				z='fit', zlim=NULL)
	plt1 <- plot_contour(tmdl, view=tgt, cond=cnd, summed=FALSE, zlim=NULL)
	gtypes0 <- vapply(plt0$layers,
			  function(x) class(x$geom)[1],
			  character(1))
	gtypes1 <- vapply(plt1$layers,
			  function(x) class(x$geom)[1],
			  character(1))
	expect_s3_class(plt0, 'ggplot')
	expect_s3_class(plt1, 'ggplot')
	expect_match(gtypes0[1], 'GeomPolygon', fixed=TRUE)
	expect_match(gtypes0[2], 'GeomContour', fixed=TRUE)
	expect_match(gtypes0[3], 'GeomTextContour', fixed=TRUE)
	expect_match(gtypes1[1], 'GeomPolygon', fixed=TRUE)
	expect_match(gtypes1[2], 'GeomContour', fixed=TRUE)
	expect_match(gtypes1[3], 'GeomTextContour', fixed=TRUE)
	scl0 <- layer_scales(plt0)
	scl1 <- layer_scales(plt1)
	expect_equal(round(scl0$x$range$range[1],7), 0.0066501)
	expect_equal(round(scl0$x$range$range[2],7), 0.9993194)
	expect_equal(round(scl0$y$range$range[1],7), 0.0013797)
	expect_equal(round(scl0$y$range$range[2],7), 0.9948520)
	expect_equal(round(scl1$x$range$range[1],7), 0.0066501)
	expect_equal(round(scl1$x$range$range[2],7), 0.9993194)
	expect_equal(round(scl1$y$range$range[1],7), 0.0013797)
	expect_equal(round(scl1$y$range$range[2],7), 0.9948520)
})
test_that('constant() returns the most frequent value for character/factor.', {
	vec <- c(rep('A',2), rep('B',3), rep('C',1))
	expect_match(constant(vec), 'B', fixed=TRUE)
	vec <- factor(vec)
	expect_match(constant(vec), 'B', fixed=TRUE)
})
test_that('constant() returns an error if not numeric/character/factor.', {
	lst <- list(rep('A',2), rep('B',3), rep('C',1))
	expect_error(constant(lst))
})
test_that('vary() returns a sorted unique vector for character/factor.', {
	vec <- c(rep('A',2), rep('B',3), rep('C',1))
	vry <- vary(vec)
	tst <- LETTERS[1:3]
	expect_true(all(vapply(1:3,
			       function(x) vry[x]==tst[x],
			       FUN.VALUE=logical(1),
			       USE.NAMES=FALSE)))
	vec <- factor(vec)
	vry <- vary(vec)
	tst <- LETTERS[1:3]
	expect_true(all(vapply(1:3,
			       function(x) vry[x]==tst[x],
			       FUN.VALUE=logical(1),
			       USE.NAMES=FALSE)))
})
test_that('vary() returns an error if not numeric/character/factor.', {
	lst <- list(rep('A',2), rep('B',3), rep('C',1))
	expect_error(vary(lst))
})
test_that('plot_contour, summed=TRUE, cond=list(), terms.size="min".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(), TRUE, terms.size='min')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#3288BD']),  70)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FFFDBC']), 334)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(5.91, 6.09]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(), terms.size="medium".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(), TRUE,
			    terms.size='medium')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#3288BD']),  70)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FFFDBC']), 334)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(5.91, 6.09]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(), terms.size="max".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(), TRUE, terms.size='max')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#3288BD']),  70)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FFFDBC']), 334)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(5.91, 6.09]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1"), terms.size="min".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1'), TRUE,
			    terms.size='min')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1"),
	   terms.size="medium".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1'), TRUE,
			    terms.size='medium')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1"), terms.size="max".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1'), TRUE,
			    terms.size='max')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4")),
	   terms.size="min".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4')), TRUE,
			    terms.size='min')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4")),
	   terms.size="medium".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4')), TRUE,
			    terms.size='medium')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4")),
	   terms.size="max".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4')), TRUE,
			    terms.size='max')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1",x2=x2max),
	   terms.size="min".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1',x2=x2max), TRUE,
			    terms.size='min')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1",x2=x2max),
	   terms.size="medium".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1',x2=x2max), TRUE,
			    terms.size='medium')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1",x2=x2max),
	   terms.size="max".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1',x2=x2max), TRUE,
			    terms.size='max')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="min".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4'), x2=x2max),
			    TRUE, terms.size='min')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="medium".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4'), x2=x2max),
			    TRUE, terms.size='medium')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="max".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4'), x2=x2max),
			    TRUE, terms.size='max')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(), terms.size="min".', {
	expect_error(plot_contour(tmdl, c('x0','x1'), list(), FALSE,
				  terms.size='min'))
})
test_that('plot_contour, summed=FALSE, cond=list(), terms.size="medium".', {
	expect_error(plot_contour(tmdl, c('x0','x1'), list(), FALSE,
				  terms.size='medium'))
})
test_that('plot_contour, summed=FALSE, cond=list(), terms.size="max".', {
	expect_error(plot_contour(tmdl, c('x0','x1'), list(), FALSE,
				  terms.size='max'))
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1"),
	   terms.size="min".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1'), FALSE,
			    terms.size='min')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 100)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-46.31, -45.20]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1"),
	   terms.size="medium".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1'), FALSE,
			    terms.size='medium')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']),  54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-17.28, -16.10]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1"),
	   terms.size="max".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1'), FALSE,
			    terms.size='max')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']),  54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-17.28, -16.10]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4")),
	   terms.size="min".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4')), FALSE,
			    terms.size='min')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 100)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-46.31, -45.20]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4")),
	   terms.size="medium".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4')), FALSE,
			    terms.size='medium')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']),  54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-17.28, -16.10]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4")),
	   terms.size="max".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4')), FALSE,
			    terms.size='max')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']),  54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-17.28, -16.10]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1",x2=x2max),
	   terms.size="min".', {
	expect_error(plot_contour(tmdl, c('x0','x1'), list(fac='1',x2=x2max),
				  FALSE, terms.size='min'))
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1",x2=x2max),
	   terms.size="medium".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1',x2=x2max), FALSE,
			    terms.size='medium')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-20.57, -19.40]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1",x2=x2max),
	   terms.size="max".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac='1',x2=x2max), FALSE,
			    terms.size='max')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-20.57, -19.40]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="min".', {
	expect_error(plot_contour(tmdl, c('x0','x1'),
				  list(fac=c('1','4'), x2=x2max), FALSE,
				  terms.size='min'))
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="medium".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4'),x2=x2max),
			    FALSE, terms.size='medium')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-20.57, -19.40]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="max".', {
	plt <- plot_contour(tmdl, c('x0','x1'), list(fac=c('1','4'),x2=x2max),
			    FALSE, terms.size='max')
	bld <- ggplot_build(plt)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-20.57, -19.40]',
		     fixed=TRUE)
})
test_that('add_fit, verbose, when no term is matched (terms.size=min).', {
	tgt <- c('foo','bar')
	cnd <- list(fbar='baz')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_snapshot(expect_error(add_fit(ndat, tmdl, terms=tgt, cond=cnd,
					     terms.size='min', ci.mult=1,
					     verbose=TRUE)))
})
test_that('add_fit, verbose, when no term is matched (terms.size=medium).', {
	tgt <- c('foo','bar')
	cnd <- list(fbar='baz')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_snapshot(expect_error(add_fit(ndat, tmdl, terms=tgt, cond=cnd,
					     terms.size='medium', ci.mult=1,
					     verbose=TRUE)))
})
test_that('add_fit, verbose, when no term is matched (terms.size=max).', {
	tgt <- c('foo','bar')
	cnd <- list(fbar='baz')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_snapshot(expect_error(add_fit(ndat, tmdl, terms=tgt, cond=cnd,
					     terms.size='max', ci.mult=1,
					     verbose=TRUE)))
})
test_that('add_fit prints out a verbose message to indicate which terms are
	   selected.', {
	tgt <- c('x0','x1')
	cnd <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_output(add_fit(ndat, tmdl, terms=tgt, cond=cnd, ci.mult=1,
			      verbose=TRUE),'Selected:\nti(x0,x1):fac1',
		      fixed=TRUE)
})
test_that('plot_contour returns an error when view is not length=2.', {
	expect_error(plot_contour(tmdl, c('x0'), list(fac='1'), TRUE))
})
test_that('add_fit prints out a verbose message that all the terms are
	   selected.', {
	tgt <- c('x0','x1')
	cnd <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_output(add_fit(ndat, tmdl, terms=NULL, cond=cnd, ci.mult=1,
			      verbose=TRUE),'Selected: All (summed effect).',
		      fixed=TRUE)
})
test_that('add_fit gives an error when terms.size is not "min", "medium", or
	   "max".', {
	tgt <- c('x0','x1')
	cnd <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_error(add_fit(ndat, tmdl, terms=tgt, cond=cnd,
			     terms.size='foobar', ci.mult=1, verbose=TRUE))
})
test_that('add_fit produces the correct dataframe when there is no factor
	   variable.', {
	tmdl2 <- gam(y ~ s(x0, by=fac) + s(x1, by=fac, k=5) + ti(x0,x1),
		     data=tdat)
	tgt <- c('x0','x1')
	ndat <- mdl_to_ndat(mdl=tmdl2, target=tgt, len=50, method=median)
	ndat <- add_fit(ndat, tmdl2, terms=tgt, terms.size='min', ci.mult=1,
			verbose=FALSE)
	expect_equal(nrow(ndat), 2500)
	expect_equal(round(mean(ndat$x0), 5),  0.50298)
	expect_equal(round(mean(ndat$x1), 5),  0.49812)
	expect_equal(round(mean(ndat$fit),5),  0.00033)
	expect_equal(round(mean(ndat$se), 5),  0.30191)
	expect_equal(round(mean(ndat$upr),5),  0.30225)
	expect_equal(round(mean(ndat$lwr),5), -0.30158)
})
test_that('add_fit returns an error when there are multiple factor
	   variables.', {# This feature should perhaps be changed.
	tdat3 <- tdat
	set.seed(432)
	tdat3$foo <- factor(sample(LETTERS[1:3], nrow(tdat3), replace=TRUE))
	tmdl3 <- gam(y ~ s(x0, by=fac) + s(x1, by=foo) + ti(x0,x1, by=fac),
		     data=tdat3)
	tgt <- c('x0','x1')
	cnd <- list(fac='2','foo'='A')
	ndat <- mdl_to_ndat(mdl=tmdl3, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_error(add_fit(ndat, tmdl3, terms=tgt, cond=cnd,
			     terms.size='medium', ci.mult=1, verbose=FALSE))
})
test_that('ndat_to_contour produces a contour plot without confidence interval
	   lines (se=FALSE).', {
	tgt <- c('x0','x1')
	cnd <- list(fac='2')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	ndat <- add_fit(ndat, tmdl, terms=tgt, cond=cnd, terms.size='min',
			ci.mult=1, verbose=FALSE)
	plt <- ndat_to_contour(ndat, 'x0', 'x1', 'fit', se=FALSE)
	bld <- ggplot_build(plt)
	expect_length(unique(bld$data[[2]]$colour), 1)
	expect_match(unique(bld$data[[2]]$colour), '#000000')
	expect_length(unique(bld$data[[2]]$linetype), 1)
	expect_match(unique(bld$data[[2]]$linetype), 'solid')
	expect_length(levels(bld$data[[1]]$PANEL), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 6)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 184)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-2.54, -2.49]',
		     fixed=TRUE)

})
test_that('ndat_to_contour produces a contour plot with a given zlim.', {
	tgt <- c('x0','x1')
	cnd <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	ndat <- add_fit(ndat, tmdl, terms=tgt, cond=cnd, terms.size='min',
			ci.mult=1, verbose=FALSE)
	plt <- ndat_to_contour(ndat, 'x0', 'x1', 'fit', zlim=c(-20,20))
	bld <- ggplot_build(plt)
	expect_length(unique(bld$data[[2]]$colour), 3)
	expect_match(unique(bld$data[[2]]$colour)[3], '#1B9E77')
	expect_length(unique(bld$data[[2]]$linetype), 3)
	expect_match(unique(bld$data[[2]]$linetype)[3], 'dotted')
	expect_length(levels(bld$data[[1]]$PANEL), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#3485BB']),  76)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FFFDBC']), 472)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-20.0, -19.6]',
		     fixed=TRUE)

})
test_that('ndat_to_contour corrects non-factor "facet.col" to factor.', {
	tgt <- c('x0','x1')
	cnd <- list(fac=c('1','4'))
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	ndat <- add_fit(ndat, tmdl, terms=tgt, cond=cnd, terms.size='min',
			ci.mult=1, verbose=FALSE)
	ndat$fac <- as.character(ndat$fac)
	plt <- ndat_to_contour(ndat, 'x0', 'x1', 'fit', facet.col='fac',
			       zlim=c(-20,20))
	bld <- ggplot_build(plt)
	expect_length(unique(bld$data[[2]]$colour), 3)
	expect_match(unique(bld$data[[2]]$colour)[3], '#1B9E77')
	expect_length(unique(bld$data[[2]]$linetype), 3)
	expect_match(unique(bld$data[[2]]$linetype)[3], 'dotted')
	expect_length(levels(bld$data[[1]]$PANEL), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#3485BB']),  76)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FFFDBC']), 844)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-20.0, -19.6]',
		     fixed=TRUE)

})
test_that('ndat_to_contour handles the argument facet.col=="type".', {
	tgt <- c('x0','x1')
	cnd <- list(fac=c(1,4))
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	ndat <- add_fit(ndat, tmdl, terms=tgt, cond=cnd, terms.size='min',
			ci.mult=1, verbose=FALSE)
	colnames(ndat)[colnames(ndat)=='fac'] <- 'type'
	plt <- ndat_to_contour(ndat, 'x0', 'x1', 'fit', se=FALSE, facet.col='type')
	bld <- ggplot_build(plt)
	expect_length(unique(bld$data[[2]]$colour), 1)
	expect_match(unique(bld$data[[2]]$colour), '#000000')
	expect_length(unique(bld$data[[2]]$linetype), 1)
	expect_match(unique(bld$data[[2]]$linetype), 'solid')
	expect_length(levels(bld$data[[1]]$PANEL), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 100)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-46.31, -45.20]',
		     fixed=TRUE)
})
test_that('ndat_to_contour handles the argument facet.labeller properly.', {
	tgt <- c('x0','x1')
	cnd <- list(fac=c(1,4))
	ndat <- mdl_to_ndat(mdl=tmdl, target=tgt, cond=cnd, len=50,
			    method=median)
	ndat <- add_fit(ndat, tmdl, terms=tgt, cond=cnd, terms.size='min',
			ci.mult=1, verbose=FALSE)
	plt <- ndat_to_contour(ndat, 'x0', 'x1', 'fit', se=FALSE,
			       facet.col='fac',
			       facet.labeller=c('1'='One','4'='Four'))
	bld <- ggplot_build(plt)
	expect_mapequal(bld$layout$facet_params$plot_env$facet.labeller,
			c('1'='One','4'='Four'))
})
test_that('example_df produces a certain dataframe.', {
	dat <- example_df()
	expect_equal(nrow(dat), 1000)
	expect_true(all(colnames(dat)==c('y','x0','x1','x2')))
})
