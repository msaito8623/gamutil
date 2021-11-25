library(testthat)
library(gamutil)
library(mgcv)

set.seed(534)
ddd <- gamSim(verbose=FALSE)
mmm <- gam(y ~ s(x0) + s(x1) + s(x2) + ti(x0,x1) + ti(x0,x1,x2), data=ddd)
ttt <- c('x0','x2')
load(system.file('testdata', 'ndat.rda', package='gamutil')) # loads "ndat"
load(system.file('testdata', 'ndat_termsNULL.rda', package='gamutil')) # loads "ndat_termsNULL"

test_that('mdl_to_ndat equals to the first 4 columns of ndat.rda', {
	# vary() and constant() are also checked in this test.
	ndat_test <- mdl_to_ndat(mdl=mmm, target=ttt, len=10, method=median)
	expect_s3_class(ndat_test, 'data.frame')
	expect_true(all(ndat[,c('y','x0','x1','x2')]==ndat_test))
})

test_that('add_fit equals to inst/testdata/ndat.rda', {
	ndat_test <- mdl_to_ndat(mdl=mmm, target=ttt, len=10, method=median)
	ndat_test <- add_fit(ndat_test, mmm, terms=ttt)
	expect_s3_class(ndat_test, 'data.frame')
	expect_true(all(ndat==ndat_test))
})

test_that('add_fit adds predicton of summed effects with terms=NULL (default).', {
	ndat_test <- mdl_to_ndat(mdl=mmm, target=ttt, len=10, method=median)
	ndat_test <- add_fit(ndat_test, mmm)
	expect_s3_class(ndat_test, 'data.frame')
	expect_true(all(ndat_termsNULL==ndat_test))
})

test_that('plot_contour produces the same plot as plt1,plt2,plt3.', {
	load(system.file('testdata', 'plt.Rdata', package='gamutil')) # loads "plt"
	plt0 <- plt
	plt <- plot_contour(mmm, view=ttt)
	gtypes <- sapply(plt$layers, function(x) class(x$geom)[1])
	expect_s3_class(plt, 'ggplot')
	expect_true(all(gtypes == c('GeomPolygon','GeomContour','GeomTextContour')))
	plt0 <- ggplot_build(plt0)$data
	plt  <- ggplot_build(plt)$data
	expect_true(all(sapply(seq_along(plt0), function(x) all(plt0[[x]]==plt[[x]],na.rm=T))))
})

test_that('mdl_to_ndat, add_fit, and ndat_to_contour produces the same as plot_contour.', {
	ndat_test <- mdl_to_ndat(mdl=mmm, target=ttt, len=100, method=median)
	ndat_test <- add_fit(ndat_test, mmm, terms=ttt, ci.mult=1)
	plt0 <- ndat_to_contour(ndat_test, x=ttt[1], y=ttt[2], z='fit', zlim=c(-3,5))
	plt1 <- plot_contour(mmm, view=ttt, zlim=c(-3,5))
	gtypes0 <- sapply(plt0$layers, function(x) class(x$geom)[1])
	gtypes1 <- sapply(plt1$layers, function(x) class(x$geom)[1])
	expect_s3_class(plt0, 'ggplot')
	expect_s3_class(plt1, 'ggplot')
	expect_true(all(gtypes0 == c('GeomPolygon','GeomContour','GeomTextContour')))
	expect_true(all(gtypes1 == c('GeomPolygon','GeomContour','GeomTextContour')))
	plt0 <- ggplot_build(plt0)$data
	plt1 <- ggplot_build(plt1)$data
	expect_true(all(sapply(seq_along(plt0), function(x) all(plt0[[x]]==plt1[[x]],na.rm=T))))
})

test_that('constant() returns the most frequent value for a character/factor vector.', {
	vec <- c(rep('A',2), rep('B',3), rep('C',1))
	expect_match(constant(vec), 'B')
	vec <- factor(vec)
	expect_match(constant(vec), 'B')
})

test_that('constant() returns an error for other inputs than numeric/character/factor.', {
	lst <- list(rep('A',2), rep('B',3), rep('C',1))
	expect_error(constant(lst))
})

test_that('vary() returns a sorted unique vector for a character/factor vector.', {
	vec <- c(rep('A',2), rep('B',3), rep('C',1))
	vry <- vary(vec)
	tst <- LETTERS[1:3]
	expect_true(all(sapply(1:3, function(x) vry[x]==tst[x], USE.NAMES=FALSE)))
	vec <- factor(vec)
	vry <- vary(vec)
	tst <- LETTERS[1:3]
	expect_true(all(sapply(1:3, function(x) vry[x]==tst[x], USE.NAMES=FALSE)))
})

test_that('vary() returns an error for other inputs than numeric/character/factor.', {
	lst <- list(rep('A',2), rep('B',3), rep('C',1))
	expect_error(vary(lst))
})
