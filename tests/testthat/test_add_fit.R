test_that('add_fit works properly with "terms".', {
	tgt <- c('x0','x1')
	cnd <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=10,
			    method=median)
	ndat <- add_fit(ndat, tmdl0, terms=tgt, cond=cnd)
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
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt,
			    len=10, method=median)
	ndat <- add_fit(ndat, tmdl0)
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
test_that('add_fit, verbose, when no term is matched (terms.size=min).', {
	tgt <- c('foo','bar')
	cnd <- list(fbar='baz')
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_snapshot(expect_error(add_fit(ndat, tmdl0, terms=tgt, cond=cnd,
					     terms.size='min', ci.mult=1,
					     verbose=TRUE)))
})
test_that('add_fit, verbose, when no term is matched (terms.size=medium).', {
	tgt <- c('foo','bar')
	cnd <- list(fbar='baz')
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_snapshot(expect_error(add_fit(ndat, tmdl0, terms=tgt, cond=cnd,
					     terms.size='medium', ci.mult=1,
					     verbose=TRUE)))
})
test_that('add_fit, verbose, when no term is matched (terms.size=max).', {
	tgt <- c('foo','bar')
	cnd <- list(fbar='baz')
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_snapshot(expect_error(add_fit(ndat, tmdl0, terms=tgt, cond=cnd,
					     terms.size='max', ci.mult=1,
					     verbose=TRUE)))
})
test_that('add_fit prints out a verbose message to indicate which terms are
	   selected.', {
	tgt <- c('x0','x1')
	cnd <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_output(add_fit(ndat, tmdl0, terms=tgt, cond=cnd, ci.mult=1,
			      verbose=TRUE),'Selected:\nti(x0,x1):fac1',
		      fixed=TRUE)
})
test_that('add_fit prints out a verbose message that all the terms are
	   selected.', {
	tgt <- c('x0','x1')
	cnd <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_output(add_fit(ndat, tmdl0, terms=NULL, cond=cnd, ci.mult=1,
			      verbose=TRUE),'Selected: All (summed effect).',
		      fixed=TRUE)
})
test_that('add_fit gives an error when terms.size is not "min", "medium", or
	   "max".', {
	tgt <- c('x0','x1')
	cnd <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_error(add_fit(ndat, tmdl0, terms=tgt, cond=cnd,
			     terms.size='foobar', ci.mult=1, verbose=TRUE))
})
test_that('add_fit produces the correct dataframe when there is no factor
	   variable.', {
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
	tgt <- c('x0','x1')
	cnd <- list(fac='2','foo'='A')
	ndat <- mdl_to_ndat(mdl=tmdl3, target=tgt, cond=cnd, len=50,
			    method=median)
	expect_error(add_fit(ndat, tmdl3, terms=tgt, cond=cnd,
			     terms.size='medium', ci.mult=1, verbose=FALSE))
})
