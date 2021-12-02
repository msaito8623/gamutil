library(testthat)
library(mgcv)

set.seed(534)
ddd <- gamSim(verbose=FALSE)
mmm <- gam(y ~ s(x0) + s(x1) + s(x2) + ti(x0,x1) + ti(x0,x1,x2), data=ddd)
ttt <- c('x0','x2')
# load(system.file('testdata', 'ndat.rda', package='gamutil')) # loads "ndat"

test_that('mdl_to_ndat works properly without "cond".', {
	# vary() and constant() are also checked in this test.
	ndat <- mdl_to_ndat(mdl=mmm, target=ttt, len=10, method=median)
	expect_s3_class(ndat, 'data.frame')
	expect_equal(colnames(ndat), c('x0','x1','x2'))
	expect_equal(nrow(ndat), 100)
	expect_length(unique(ndat$x0), 10)
	expect_length(unique(ndat$x1),  1)
	expect_length(unique(ndat$x2), 10)
	expect_equal(round(mean(ndat$x0),5), 0.50298)
	expect_equal(round(mean(ndat$x1),5), 0.52001)
	expect_equal(round(mean(ndat$x2),5), 0.50048)
})

test_that('mdl_to_ndat works properly with "cond".', {
	clist <- list('x0'=10,'x1'=c(20,30),'x2'=c(40,50))
	ndat <- mdl_to_ndat(mdl=mmm, target=ttt, cond=clist,
			    len=10, method=median)
	expect_s3_class(ndat, 'data.frame')
	expect_equal(colnames(ndat), c('x0','x1','x2'))
	expect_equal(ndat$x0, rep(10,4))
	expect_equal(ndat$x1, rep(c(20,30),2))
	expect_equal(ndat$x2, rep(c(40,50),each=2))
})

test_that('mdl_to_ndat works with "cond" for only a subset of variables.', {
	clist <- list('x1'=c(20,30))
	ndat <- mdl_to_ndat(mdl=mmm, target=ttt, cond=clist,
			    len=10, method=median)
	expect_s3_class(ndat, 'data.frame')
	expect_equal(colnames(ndat), c('x0','x1','x2'))
	expect_equal(nrow(ndat), 200)
	expect_length(unique(ndat$x0), 10)
	expect_length(unique(ndat$x1),  2)
	expect_length(unique(ndat$x2), 10)
	expect_equal(round(mean(ndat$x0),5), 0.50298)
	expect_equal(round(mean(ndat$x1),5),      25)
	expect_equal(round(mean(ndat$x2),5), 0.50048)
})

test_that('add_fit works properly with "terms".', {
	ndat_test <- mdl_to_ndat(mdl=mmm, target=ttt,
				 len=10, method=median)
	ndat_test <- add_fit(ndat_test, mmm, terms=ttt)
	expect_s3_class(ndat_test, 'data.frame')
	expect_equal(nrow(ndat_test), 100)
	expect_equal(ncol(ndat_test), 7)
	expect_equal(round(mean(ndat_test$x0), 5),  0.50298)
	expect_equal(round(mean(ndat_test$x1), 5),  0.52001)
	expect_equal(round(mean(ndat_test$x2), 5),  0.50048)
	expect_equal(round(mean(ndat_test$fit),5), -0.48284)
	expect_equal(round(mean(ndat_test$se), 5),  0.44889)
	expect_equal(round(mean(ndat_test$upr),5),  0.39696)
	expect_equal(round(mean(ndat_test$lwr),5), -1.36264)
})

test_that('add_fit adds predicted summed effects with terms=NULL (default).', {
	ndat_test <- mdl_to_ndat(mdl=mmm, target=ttt,
				 len=10, method=median)
	ndat_test <- add_fit(ndat_test, mmm)
	expect_s3_class(ndat_test, 'data.frame')
	expect_equal(nrow(ndat_test), 100)
	expect_equal(ncol(ndat_test), 7)
	expect_equal(round(mean(ndat_test$x0), 5), 0.50298)
	expect_equal(round(mean(ndat_test$x1), 5), 0.52001)
	expect_equal(round(mean(ndat_test$x2), 5), 0.50048)
	expect_equal(round(mean(ndat_test$fit),5), 7.22400)
	expect_equal(round(mean(ndat_test$se), 5), 0.50308)
	expect_equal(round(mean(ndat_test$upr),5), 8.21001)
	expect_equal(round(mean(ndat_test$lwr),5), 6.23799)
})

test_that('plot_contour produces the same plot as plt1,plt2,plt3.', {
	plt <- plot_contour(mmm, view=ttt)
	gtypes <- vapply(plt$layers,
			 function(x) class(x$geom)[1],
			 character(1))
	expect_s3_class(plt, 'ggplot')
	expect_match(gtypes[1], 'GeomPolygon')
	expect_match(gtypes[2], 'GeomContour')
	expect_match(gtypes[3], 'GeomTextContour')
	scl <- layer_scales(plt)
	expect_equal(round(scl$x$range$range[1],7), 0.0066501)
	expect_equal(round(scl$x$range$range[2],7), 0.9993194)
	expect_equal(round(scl$y$range$range[1],7), 0.0010856)
	expect_equal(round(scl$y$range$range[2],7), 0.9998791)
})

test_that('mdl_to_ndat, add_fit, and ndat_to_contour
	  produces the same as plot_contour.', {
	ndat_test <- mdl_to_ndat(mdl=mmm, target=ttt,
				 len=100, method=median)
	ndat_test <- add_fit(ndat_test, mmm, terms=ttt, ci.mult=1)
	plt0 <- ndat_to_contour(ndat_test,
				x=ttt[1], y=ttt[2], z='fit', zlim=c(-3,5))
	plt1 <- plot_contour(mmm, view=ttt, zlim=c(-3,5))
	gtypes0 <- vapply(plt0$layers,
			  function(x) class(x$geom)[1],
			  character(1))
	gtypes1 <- vapply(plt1$layers,
			  function(x) class(x$geom)[1],
			  character(1))
	expect_s3_class(plt0, 'ggplot')
	expect_s3_class(plt1, 'ggplot')
	expect_match(gtypes0[1], 'GeomPolygon')
	expect_match(gtypes0[2], 'GeomContour')
	expect_match(gtypes0[3], 'GeomTextContour')
	expect_match(gtypes1[1], 'GeomPolygon')
	expect_match(gtypes1[2], 'GeomContour')
	expect_match(gtypes1[3], 'GeomTextContour')
	scl0 <- layer_scales(plt0)
	scl1 <- layer_scales(plt1)
	expect_equal(round(scl0$x$range$range[1],7), 0.0066501)
	expect_equal(round(scl0$x$range$range[2],7), 0.9993194)
	expect_equal(round(scl0$y$range$range[1],7), 0.0010856)
	expect_equal(round(scl0$y$range$range[2],7), 0.9998791)
	expect_equal(round(scl1$x$range$range[1],7), 0.0066501)
	expect_equal(round(scl1$x$range$range[2],7), 0.9993194)
	expect_equal(round(scl1$y$range$range[1],7), 0.0010856)
	expect_equal(round(scl1$y$range$range[2],7), 0.9998791)
})

test_that('constant() returns the most frequent value for character/factor.', {
	vec <- c(rep('A',2), rep('B',3), rep('C',1))
	expect_match(constant(vec), 'B')
	vec <- factor(vec)
	expect_match(constant(vec), 'B')
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
