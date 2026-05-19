test_that('plot_partial errors on view of length 0 or > 2.', {
	expect_error(plot_partial(tmdl0, character(0)),    'length 1 or 2')
	expect_error(plot_partial(tmdl0, c('x0','x1','x2')), 'length 1 or 2')
})
test_that('plot_partial errors when view variables are not in mdl$model.', {
	expect_error(plot_partial(tmdl0, 'no_such_var'), 'not in mdl\\$model')
})
test_that('plot_partial dispatches 2 numerics to plot_contour.', {
	# tmdl0: y ~ s(x0,by=fac) + s(x1,by=fac) + s(x2) + ti(x0,x1,by=fac) +
	# ti(x0,x2,by=fac). View c(x0, x2) -> 2 numeric -> plot_contour.
	plt <- plot_partial(tmdl0, view = c('x0', 'x2'),
			    cond = list(fac = '1'), summed = TRUE,
			    axis.len = 10)
	# plot_contour returns a ggplot via metR::geom_contour_fill. Verify
	# by checking layer composition matches plot_contour output.
	plt_ref <- plot_contour(tmdl0, view = c('x0', 'x2'),
				cond = list(fac = '1'), summed = TRUE,
				axis.len = 10)
	expect_equal(length(plt$layers), length(plt_ref$layers))
})
test_that('plot_partial dispatches 1 numeric + 1 factor to plot_curve.', {
	m2 <- mgcv::bam(y ~ fac + s(x0, by = fac, k = 3), data = tdat,
			method = 'ML')
	plt <- plot_partial(m2, view = c('x0', 'fac'), summed = FALSE,
			    terms.size = 'medium', joint.se = TRUE)
	plt_ref <- plot_curve(m2, view = c('x0', 'fac'), summed = FALSE,
			      terms.size = 'medium', joint.se = TRUE)
	expect_equal(length(plt$layers), length(plt_ref$layers))
})
test_that('plot_partial silently drops contour-only args when dispatching to plot_curve.', {
	# too.far is a plot_contour argument; passing it through plot_partial
	# while dispatching to plot_curve must not error.
	m2 <- mgcv::bam(y ~ fac + s(x0, by = fac, k = 3), data = tdat,
			method = 'ML')
	expect_no_error(
		plot_partial(m2, view = c('x0', 'fac'), summed = FALSE,
			     terms.size = 'medium', too.far = 0.10)
	)
})
test_that('plot_partial dispatches 1 numeric to plot_curve.', {
	m1 <- mgcv::bam(y ~ s(x0, k = 3), data = tdat, method = 'ML')
	plt <- plot_partial(m1, view = 'x0', summed = FALSE,
			    terms.size = 'medium')
	expect_s3_class(plt, 'ggplot')
})
