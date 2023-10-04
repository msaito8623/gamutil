test_that('ndat_to_contour produces a contour plot without confidence interval
	   lines (se=FALSE).', {
	tgt <- c('x0','x1')
	cnd <- list(fac='2')
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	ndat <- add_fit(ndat, tmdl0, terms=tgt, cond=cnd, terms.size='min',
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
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	ndat <- add_fit(ndat, tmdl0, terms=tgt, cond=cnd, terms.size='min',
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
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	ndat <- add_fit(ndat, tmdl0, terms=tgt, cond=cnd, terms.size='min',
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
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	ndat <- add_fit(ndat, tmdl0, terms=tgt, cond=cnd, terms.size='min',
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
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	ndat <- add_fit(ndat, tmdl0, terms=tgt, cond=cnd, terms.size='min',
			ci.mult=1, verbose=FALSE)
	plt <- ndat_to_contour(ndat, 'x0', 'x1', 'fit', se=FALSE,
			       facet.col='fac',
			       facet.labeller=c('1'='One','4'='Four'))
	bld <- ggplot_build(plt)
	expect_mapequal(bld$layout$facet_params$plot_env$facet.labeller,
			c('1'='One','4'='Four'))
})
