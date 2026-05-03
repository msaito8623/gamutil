test_that('plot_curve errors on view of length 0 or > 2.', {
	expect_error(plot_curve(tmdl0, character(0)),    'length 1 or 2')
	expect_error(plot_curve(tmdl0, c('x0','x1','x2')), 'length 1 or 2')
})
test_that('plot_curve errors when view variables are not in mdl$model.', {
	expect_error(plot_curve(tmdl0, 'no_such_var'), 'not in mdl\\$model')
})
test_that('plot_curve errors when view has no numeric variable.', {
	expect_error(plot_curve(tmdl0, 'fac'),
		     'must contain at least one numeric')
})
test_that('plot_curve redirects 2-numeric view to plot_contour with a hint.', {
	expect_error(plot_curve(tmdl0, c('x0','x1')), 'plot_contour')
})
test_that('plot_curve returns a ggplot for 1 numeric.', {
	# Smooth-only model on x0 alone.
	m1 <- mgcv::bam(y ~ s(x0, k = 3), data = tdat, method = 'ML')
	plt <- plot_curve(m1, view = 'x0', summed = FALSE,
			  terms.size = 'medium')
	expect_s3_class(plt, 'ggplot')
})
test_that('plot_curve returns a ggplot for 1 numeric + 1 factor.', {
	# By-variable smooth + parametric main effect on fac.
	m2 <- mgcv::bam(y ~ fac + s(x0, by = fac, k = 3), data = tdat,
			method = 'ML')
	plt <- plot_curve(m2, view = c('x0', 'fac'), summed = FALSE,
			  terms.size = 'medium', joint.se = TRUE)
	expect_s3_class(plt, 'ggplot')
})
test_that('plot_curve auto-adds factor view to cond.', {
	# When the user does not supply cond, the factor view variable is
	# added with all its levels so that add_fit's by-expansion works.
	m2 <- mgcv::bam(y ~ fac + s(x0, by = fac, k = 3), data = tdat,
			method = 'ML')
	# This call would otherwise fail with '"by" must be included in
	# "cond"' if the auto-add did not happen.
	plt <- plot_curve(m2, view = c('x0', 'fac'), summed = FALSE,
			  terms.size = 'medium')
	expect_s3_class(plt, 'ggplot')
})
test_that('plot_curve respects view ordering (factor first).', {
	m2 <- mgcv::bam(y ~ fac + s(x0, by = fac, k = 3), data = tdat,
			method = 'ML')
	plt <- plot_curve(m2, view = c('fac', 'x0'), summed = FALSE,
			  terms.size = 'medium')
	expect_s3_class(plt, 'ggplot')
})
test_that('plot_curve summed=TRUE includes intercept and runs end-to-end.', {
	m1 <- mgcv::bam(y ~ s(x0, k = 3), data = tdat, method = 'ML')
	plt <- plot_curve(m1, view = 'x0', summed = TRUE, axis.len = 20)
	expect_s3_class(plt, 'ggplot')
})
