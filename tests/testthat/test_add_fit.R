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
test_that('add_fit decomposes parametric ":" interactions (terms.size=min).', {
	# tmdl_pi: y ~ fac + x0 + fac:x0 (parametric only). With
	# terms.size="min" and target = c("x0","fac"), the only term whose
	# variables exactly equal the target is the fac:x0 interaction.
	tgt  <- c('x0','fac')
	ndat <- mdl_to_ndat(mdl=tmdl_pi, target=tgt, len=10, method=median)
	ndat <- add_fit(ndat, tmdl_pi, terms=tgt, terms.size='min', ci.mult=1)
	expect_s3_class(ndat, 'data.frame')
	expect_equal(nrow(ndat), 40)
	expect_equal(round(mean(ndat$fit), 5), -0.53158)
	expect_equal(round(mean(ndat$se),  5),  0.67523)
})
test_that('add_fit decomposes parametric ":" interactions (terms.size=medium).', {
	# Should sum fac + x0 + fac:x0, equal to summed - intercept.
	tgt  <- c('x0','fac')
	ndat <- mdl_to_ndat(mdl=tmdl_pi, target=tgt, len=10, method=median)
	ndat_med <- add_fit(ndat, tmdl_pi, terms=tgt, terms.size='medium',
			    ci.mult=1)
	ndat_sum <- add_fit(ndat, tmdl_pi, ci.mult=1)
	icpt <- as.numeric(coef(tmdl_pi)['(Intercept)'])
	expect_equal(as.numeric(ndat_med$fit),
		     as.numeric(ndat_sum$fit) - icpt)
	expect_equal(round(mean(ndat_med$fit), 5), 4.81159)
})
test_that('add_fit decomposes parametric ":" interactions (terms.size=max).', {
	# tmdl_pi has no extra terms, so "max" matches "medium" exactly here.
	tgt  <- c('x0','fac')
	ndat <- mdl_to_ndat(mdl=tmdl_pi, target=tgt, len=10, method=median)
	ndat_max <- add_fit(ndat, tmdl_pi, terms=tgt, terms.size='max',
			    ci.mult=1)
	ndat_med <- add_fit(ndat, tmdl_pi, terms=tgt, terms.size='medium',
			    ci.mult=1)
	expect_equal(ndat_max$fit, ndat_med$fit)
	expect_equal(ndat_max$se,  ndat_med$se)
})
test_that('add_fit verbose lists fac:x0 as selected when both vars are in terms.', {
	tgt  <- c('x0','fac')
	ndat <- mdl_to_ndat(mdl=tmdl_pi, target=tgt, len=10, method=median)
	expect_output(add_fit(ndat, tmdl_pi, terms=tgt, terms.size='min',
			      ci.mult=1, verbose=TRUE),
		      'Selected:\nfac:x0', fixed=TRUE)
})
test_that('add_fit include.parametric=FALSE drops a parametric-only model.', {
	# tmdl_pi has no smooths; with include.parametric=FALSE no term should
	# remain after filtering, so add_fit must error out.
	tgt  <- c('x0','fac')
	ndat <- mdl_to_ndat(mdl=tmdl_pi, target=tgt, len=10, method=median)
	expect_error(add_fit(ndat, tmdl_pi, terms=tgt, terms.size='medium',
			     ci.mult=1, include.parametric=FALSE),
		     'No term matched')
})
test_that('add_fit handles deparse-wrapped formula RHS.', {
	# tmdl_long has a >500-char RHS that R's deparser wraps into "\n    "
	# mid-term (specifically, inside one of the s(..., k=3) calls).
	# Without the whitespace-normalization step in add_fit, the wrapped
	# term would be misparsed and the by-smooth dropped.
	rhs <- as.character(formula(tmdl_long))[3]
	expect_true(grepl('\n', rhs))   # confirms wrap is present in fixture
	tgt  <- 'x0'
	cnd  <- list(fac = levels(tmdl_long$model$fac))
	ndat <- mdl_to_ndat(mdl = tmdl_long, target = tgt, cond = cnd, len = 10,
			    method = median)
	out  <- add_fit(ndat, tmdl_long, terms = tgt, cond = cnd,
			terms.size = 'medium', ci.mult = 1)
	# With the by-smooth selected, fit varies meaningfully with x0
	# within each fac level. If the by-smooth were dropped, fit would
	# be constant within each fac level (only the parametric fac shift).
	by_fac_range <- tapply(out$fit, out$fac, function (x) diff(range(x)))
	expect_true(all(by_fac_range > 0.05))
})
test_that('add_fit include.parametric does not affect smooth-only models.', {
	# tmdl0 has only smooth terms wrt c(x0, x2, fac), so toggling
	# include.parametric should not change the result.
	tgt  <- c('x0','x2')
	cnd  <- list(fac='1')
	ndat <- mdl_to_ndat(mdl=tmdl0, target=tgt, cond=cnd, len=10,
			    method=median)
	a <- add_fit(ndat, tmdl0, terms=tgt, cond=cnd, terms.size='medium',
		     ci.mult=1)
	b <- add_fit(ndat, tmdl0, terms=tgt, cond=cnd, terms.size='medium',
		     ci.mult=1, include.parametric=FALSE)
	expect_equal(a$fit, b$fit)
	expect_equal(a$se,  b$se)
	expect_equal(round(mean(a$fit), 5), -0.64058)
})
test_that('joint.se preserves fit but tightens SE on correlated terms.', {
	# tmdl_pi: y ~ fac + x0 + fac:x0. The parametric main effects and
	# the :-interaction are negatively correlated, so the marginal SE
	# (sum-of-variances) overestimates the joint variance.
	ndat <- mdl_to_ndat(mdl=tmdl_pi, target=c('x0','fac'), len=10,
			    method=median)
	marg  <- add_fit(ndat, tmdl_pi, terms=c('x0','fac'),
			 terms.size='medium', ci.mult=1)
	joint <- add_fit(ndat, tmdl_pi, terms=c('x0','fac'),
			 terms.size='medium', ci.mult=1, joint.se=TRUE)
	# Fit unchanged.
	expect_equal(joint$fit, marg$fit)
	# Joint SE strictly smaller than marginal here.
	expect_lt(mean(joint$se), mean(marg$se))
	expect_equal(round(mean(joint$se), 5), 0.8329)
	# Joint partial fit equals (full summed prediction) - intercept,
	# since tmdl_pi has only intercept + the three terms in 'medium'.
	full <- add_fit(ndat, tmdl_pi, ci.mult=1)
	icpt <- as.numeric(coef(tmdl_pi)['(Intercept)'])
	expect_equal(joint$fit, as.numeric(full$fit) - icpt)
})
test_that('joint.se=FALSE (default) preserves backward compatibility.', {
	# Default path must give the same numbers as the prior medium test.
	ndat <- mdl_to_ndat(mdl=tmdl_pi, target=c('x0','fac'), len=10,
			    method=median)
	out <- add_fit(ndat, tmdl_pi, terms=c('x0','fac'),
		       terms.size='medium', ci.mult=1)  # joint.se default FALSE
	expect_equal(round(mean(out$fit), 5), 4.81159)
	# Marginal SE per the original test snapshot.
	expect_gt(mean(out$se), 0.83)   # > joint SE (0.8329)
})
test_that('joint.se has no effect when terms is NULL (full summed).', {
	# With terms=NULL, add_fit calls predict.gam(se.fit=TRUE) directly,
	# which already returns the joint SE; joint.se should be ignored.
	ndat <- mdl_to_ndat(mdl=tmdl0, target=c('x0','x2'),
			    cond=list(fac='1'), len=10, method=median)
	a <- add_fit(ndat, tmdl0, ci.mult=1)
	b <- add_fit(ndat, tmdl0, ci.mult=1, joint.se=TRUE)
	expect_equal(a$fit, b$fit)
	expect_equal(a$se,  b$se)
})
test_that('marginal path keeps parametric main effect of by-variable (regression).', {
	# When a model has both a parametric main effect of f and a by-smooth
	# s(x, by=f), the marginal-path by-expansion used to incorrectly catch
	# the parametric f and rewrite it into f<level> names that mgcv does
	# not recognise, silently dropping the main effect from the fit. The
	# joint.se path bypassed this bug. This test confirms that, after
	# the fix, the two paths return identical fit values.
	set.seed(11); n <- 600
	d <- data.frame(x = rnorm(n),
			f = factor(sample(c('A','B','C'), n, TRUE)))
	# Enforce different intercepts per level + level-specific x slopes,
	# so the parametric main effect contributes meaningfully to the fit.
	d$y <- 0.5*d$x + ifelse(d$f=='B', -0.6, 0) + ifelse(d$f=='C', 0.4, 0) +
	       ifelse(d$f=='B', -0.5*d$x, 0) + rnorm(n, 0, .3)
	m <- mgcv::bam(y ~ f + s(x, by=f, k=3), data=d, method='ML')
	nd <- mdl_to_ndat(m, target=c('x','f'), len=10, method=median)
	out_m <- add_fit(nd, m, terms=c('x','f'),
			 cond=list(f=levels(d$f)),
			 terms.size='medium', ci.mult=1)
	out_j <- add_fit(nd, m, terms=c('x','f'),
			 cond=list(f=levels(d$f)),
			 terms.size='medium', ci.mult=1, joint.se=TRUE)
	expect_equal(out_m$fit, out_j$fit, tolerance = 1e-9)
	# Sanity: the parametric main effect must shift the per-level means.
	mean_by_lev <- tapply(out_m$fit, out_m$f, mean)
	expect_gt(diff(range(mean_by_lev)), 0.2)
})
test_that('joint.se on a smooth-only model is close to the marginal SE.', {
	# tmdl0's selected terms (s(x0,by=fac=1) + s(x2)) have only modest
	# cross-covariance in practice; joint and marginal SE differ by
	# at most a few percent. Fit is identical.
	ndat <- mdl_to_ndat(mdl=tmdl0, target=c('x0','x2'),
			    cond=list(fac='1'), len=10, method=median)
	marg  <- add_fit(ndat, tmdl0, terms=c('x0','x2'),
			 cond=list(fac='1'), terms.size='medium', ci.mult=1)
	joint <- add_fit(ndat, tmdl0, terms=c('x0','x2'),
			 cond=list(fac='1'), terms.size='medium', ci.mult=1,
			 joint.se=TRUE)
	expect_equal(joint$fit, marg$fit, tolerance = 1e-6)
	# SEs should be in the same ballpark (within ~10%).
	expect_lt(max(abs(joint$se - marg$se) / marg$se), 0.10)
})
