plt0  <- plot_contour(tmdl0, view=c('x0','x1'))
plt1  <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(),                          TRUE, terms.size='min')
plt2  <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(),                          TRUE, terms.size='medium')
plt3  <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(),                          TRUE, terms.size='max')
plt4  <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1'),                   TRUE, terms.size='min')
plt5  <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1'),                   TRUE, terms.size='medium')
plt6  <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1'),                   TRUE, terms.size='max')
plt7  <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4')),            TRUE, terms.size='min')
plt8  <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4')),            TRUE, terms.size='medium')
plt9  <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4')),            TRUE, terms.size='max')
plt10 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1',x2=x2max),          TRUE, terms.size='min')
plt11 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1',x2=x2max),          TRUE, terms.size='medium')
plt12 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1',x2=x2max),          TRUE, terms.size='max')
plt13 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4'), x2=x2max),  TRUE, terms.size='min')
plt14 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4'), x2=x2max),  TRUE, terms.size='medium')
plt15 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4'), x2=x2max),  TRUE, terms.size='max')
plt16 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1'),                  FALSE, terms.size='min')
plt17 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1'),                  FALSE, terms.size='medium')
plt18 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1'),                  FALSE, terms.size='max')
plt19 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4')),           FALSE, terms.size='min')
plt20 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4')),           FALSE, terms.size='medium')
plt21 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4')),           FALSE, terms.size='max')
plt22 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1',x2=x2max),         FALSE, terms.size='medium')
plt23 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac='1',x2=x2max),         FALSE, terms.size='max')
plt24 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4'),x2=x2max),  FALSE, terms.size='medium')
plt25 <- plot_contour(tmdl0, view=c('x0','x1'), cond=list(fac=c('1','4'),x2=x2max),  FALSE, terms.size='max')

test_that('plot_contour produces the same plot as plt1,plt2,plt3.', {
	gtypes <- vapply(plt0$layers,
			 function(x) class(x$geom)[1],
			 character(1))
	expect_s3_class(plt0, 'ggplot')
	expect_match(gtypes[1], 'GeomPolygon', fixed=TRUE)
	expect_match(gtypes[2], 'GeomContour', fixed=TRUE)
	expect_match(gtypes[3], 'GeomTextContour', fixed=TRUE)
	scl <- layer_scales(plt0)
	expect_equal(round(scl$x$range$range[1],7), 0.0066501)
	expect_equal(round(scl$x$range$range[2],7), 0.9993194)
	expect_equal(round(scl$y$range$range[1],7), 0.0013797)
	expect_equal(round(scl$y$range$range[2],7), 0.9948520)
})
test_that('plot_contour, summed=TRUE, cond=list(), terms.size="min".', {
	bld <- ggplot_build(plt1)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#3288BD']),  70)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FFFDBC']), 334)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(5.91, 6.09]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(), terms.size="medium".', {
	bld <- ggplot_build(plt2)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#3288BD']),  70)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FFFDBC']), 334)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(5.91, 6.09]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(), terms.size="max".', {
	bld <- ggplot_build(plt3)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#3288BD']),  70)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FFFDBC']), 334)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(5.91, 6.09]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1"), terms.size="min".', {
	bld <- ggplot_build(plt4)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1"),
	   terms.size="medium".', {
	bld <- ggplot_build(plt5)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1"), terms.size="max".', {
	bld <- ggplot_build(plt6)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4")),
	   terms.size="min".', {
	bld <- ggplot_build(plt7)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4")),
	   terms.size="medium".', {
	bld <- ggplot_build(plt8)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4")),
	   terms.size="max".', {
	bld <- ggplot_build(plt9)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-1.75, -0.57]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1",x2=x2max),
	   terms.size="min".', {
	bld <- ggplot_build(plt10)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1",x2=x2max),
	   terms.size="medium".', {
	bld <- ggplot_build(plt11)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac="1",x2=x2max),
	   terms.size="max".', {
	bld <- ggplot_build(plt12)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="min".', {
	bld <- ggplot_build(plt13)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="medium".', {
	bld <- ggplot_build(plt14)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=TRUE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="max".', {
	bld <- ggplot_build(plt15)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-4.21, -3.04]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(), terms.size="min".', {
	expect_error(plot_contour(tmdl0, c('x0','x1'), list(), FALSE,
				  terms.size='min'))
})
test_that('plot_contour, summed=FALSE, cond=list(), terms.size="medium".', {
	expect_error(plot_contour(tmdl0, c('x0','x1'), list(), FALSE,
				  terms.size='medium'))
})
test_that('plot_contour, summed=FALSE, cond=list(), terms.size="max".', {
	expect_error(plot_contour(tmdl0, c('x0','x1'), list(), FALSE,
				  terms.size='max'))
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1"),
	   terms.size="min".', {
	bld <- ggplot_build(plt16)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 100)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-46.31, -45.20]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1"),
	   terms.size="medium".', {
	bld <- ggplot_build(plt17)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']),  54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-17.28, -16.10]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1"),
	   terms.size="max".', {
	bld <- ggplot_build(plt18)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']),  54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-17.28, -16.10]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4")),
	   terms.size="min".', {
	bld <- ggplot_build(plt19)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 100)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-46.31, -45.20]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4")),
	   terms.size="medium".', {
	bld <- ggplot_build(plt20)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']),  54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-17.28, -16.10]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4")),
	   terms.size="max".', {
	bld <- ggplot_build(plt21)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']),  10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']),  54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-17.28, -16.10]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1",x2=x2max),
	   terms.size="min".', {
	expect_error(plot_contour(tmdl0, c('x0','x1'), list(fac='1',x2=x2max),
				  FALSE, terms.size='min'))
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1",x2=x2max),
	   terms.size="medium".', {
	bld <- ggplot_build(plt22)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-20.57, -19.40]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac="1",x2=x2max),
	   terms.size="max".', {
	bld <- ggplot_build(plt23)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 1) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-20.57, -19.40]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="min".', {
	expect_error(plot_contour(tmdl0, c('x0','x1'),
				  list(fac=c('1','4'), x2=x2max), FALSE,
				  terms.size='min'))
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="medium".', {
	bld <- ggplot_build(plt24)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-20.57, -19.40]',
		     fixed=TRUE)
})
test_that('plot_contour, summed=FALSE, cond=list(fac=c("1","4"),x2=x2max),
	   terms.size="max".', {
	bld <- ggplot_build(plt25)
	expect_equal(length(levels(bld$data[[1]]$PANEL)), 2) # facet number
	expect_equal(unname(table(bld$data[[1]]$fill)['#A30743']), 10)
	expect_equal(unname(table(bld$data[[1]]$fill)['#FEF6B1']), 54)
	expect_match(names(table(bld$data[[1]]$order)[1]), '(-20.57, -19.40]',
		     fixed=TRUE)
})
test_that('plot_contour returns an error when view is not length=2.', {
	expect_error(plot_contour(tmdl0, c('x0'), list(fac='1'), TRUE))
})
