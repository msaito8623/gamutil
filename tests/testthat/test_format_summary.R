## Helper: kable returns a single string for latex but a per-line
## character vector for md/rst; collapse so grepl always sees one
## string for matching.
render <- function(...) paste(as.character(format_summary(...)),
			      collapse='\n')

test_that('format_summary handles lm', {
	sm <- summary(lm(mpg ~ wt + cyl, data=mtcars))
	out <- format_summary(sm, format='latex')
	expect_s3_class(out, 'knitr_kable')
	tex <- render(sm, format='latex')
	expect_match(tex, '\\$t\\$')
	expect_match(tex, '\\$p\\$')
	expect_no_match(tex, '\\$z\\$')
	expect_match(tex, 'toprule')
	expect_match(tex, 'Estimate')

	md <- render(sm, format='markdown')
	expect_match(md, '\\*t\\*')
	expect_match(md, '\\*p\\*')
	expect_no_match(md, '\\$t\\$')

	rst <- render(sm, format='rst')
	expect_match(rst, '\\*t\\*')
})

test_that('format_summary handles glm', {
	sm_bin <- summary(glm(am ~ wt + hp, data=mtcars, family=binomial))
	tex_b <- render(sm_bin, format='latex')
	expect_match(tex_b, '\\$z\\$')
	expect_no_match(tex_b, '\\$t\\$')
	md_b <- render(sm_bin, format='markdown')
	expect_match(md_b, '\\*z\\*')

	sm_g <- summary(glm(mpg ~ wt, data=mtcars, family=gaussian))
	tex_g <- render(sm_g, format='latex')
	expect_match(tex_g, '\\$t\\$')
	expect_no_match(tex_g, '\\$z\\$')
})

test_that('format_summary formats p-values', {
	tex_strong <- render(summary(lm(mpg ~ wt, data=mtcars)),
			     format='latex')
	expect_match(tex_strong, '<0.001')

	set.seed(1)
	df_null <- data.frame(y=rnorm(50), x=rnorm(50))
	tex_null <- render(summary(lm(y ~ x, data=df_null)),
			   format='latex')
	expect_no_match(tex_null, 'x +& [^&]*<0\\.001')
})

test_that('format_summary handles lme4::lmer (no df, no p)', {
	skip_if_not_installed('lme4')
	fit <- lme4::lmer(Reaction ~ Days + (Days|Subject),
			  data=lme4::sleepstudy)
	tex <- render(summary(fit), format='latex')
	expect_match(tex, '\\$t\\$')
	expect_no_match(tex, '\\$p\\$')
	expect_no_match(tex, '& df &')
})

test_that('format_summary handles lme4::glmer', {
	skip_if_not_installed('lme4')
	fit <- lme4::glmer(
		cbind(incidence, size - incidence) ~ period + (1|herd),
		data=lme4::cbpp, family=binomial)
	tex <- render(summary(fit), format='latex')
	expect_match(tex, '\\$z\\$')
	expect_match(tex, '\\$p\\$')
	expect_no_match(tex, '\\$t\\$')
})

test_that('format_summary handles lmerTest::lmer (with df)', {
	skip_if_not_installed('lmerTest')
	skip_if_not_installed('lme4')
	fit <- lmerTest::lmer(Reaction ~ Days + (Days|Subject),
			      data=lme4::sleepstudy)
	tex <- render(summary(fit), format='latex')
	expect_match(tex, '\\$t\\$')
	expect_match(tex, '\\$p\\$')
	expect_match(tex, 'df')
	md <- render(summary(fit), format='markdown')
	expect_match(md, '\\| *df *\\|')
})

test_that('format_summary handles mgcv::gam stacked layout', {
	set.seed(1); n <- 200
	dat <- data.frame(y=rnorm(n), x1=rnorm(n),
			  x2=rnorm(n), x3=rnorm(n))
	g <- mgcv::gam(y ~ x1 + s(x2) + s(x3), data=dat)
	sm <- summary(g)

	tex <- render(sm, format='latex', gam_layout='stacked')
	expect_match(tex, '\\\\toprule')
	expect_match(tex, '\\\\bottomrule')
	expect_match(tex, 'A\\. Parametric')
	expect_match(tex, 'B\\. Smooth')
	expect_match(tex, '& \\$t\\$')
	expect_match(tex, '& \\$F\\$')
	expect_match(tex, '& edf &')
	expect_match(tex, '& Estimate &')

	md <- render(sm, format='markdown', gam_layout='stacked')
	expect_match(md, '\\*\\*\\(A\\. Parametric\\)\\*\\*')
	expect_match(md, '\\*\\*\\(B\\. Smooth\\)\\*\\*')
	expect_match(md, '\\*t\\*')
	expect_match(md, '\\*F\\*')

	rst <- render(sm, format='rst', gam_layout='stacked')
	expect_match(rst, '\\*\\*\\(A\\. Parametric\\)\\*\\*')
	expect_match(rst, '\\*F\\*')
})

test_that('format_summary handles mgcv::gam split layout', {
	set.seed(1); n <- 200
	dat <- data.frame(y=rnorm(n), x1=rnorm(n),
			  x2=rnorm(n), x3=rnorm(n))
	g <- mgcv::gam(y ~ x1 + s(x2) + s(x3), data=dat)
	sm <- summary(g)

	sp <- format_summary(sm, format='latex', gam_layout='split')
	expect_type(sp, 'list')
	expect_named(sp, c('parametric', 'smooth'))
	expect_s3_class(sp$parametric, 'knitr_kable')
	expect_s3_class(sp$smooth,     'knitr_kable')

	tex_p <- paste(as.character(sp$parametric), collapse='\n')
	tex_s <- paste(as.character(sp$smooth),     collapse='\n')
	expect_match(tex_p, '\\$t\\$')
	expect_match(tex_p, 'Estimate')
	expect_no_match(tex_p, 'edf')
	expect_match(tex_s, '\\$F\\$')
	expect_match(tex_s, 'edf')
})

test_that('format_summary right-aligns numeric columns in md/rst', {
	set.seed(1); n <- 100
	dat <- data.frame(y=rnorm(n), x1=rnorm(n), x2=rnorm(n))

	# lm path (.coefs_to_kable)
	md_lm <- render(summary(lm(y ~ x1, data=dat)), format='markdown')
	expect_match(md_lm,    '\\*p\\*\\|')
	expect_no_match(md_lm, '\\|\\*p\\*')

	# gam split path (.gam_split)
	g <- mgcv::gam(y ~ x1 + s(x2), data=dat)
	sp <- format_summary(summary(g), format='markdown', gam_layout='split')
	md_p <- paste(as.character(sp$parametric), collapse='\n')
	md_s <- paste(as.character(sp$smooth),     collapse='\n')
	expect_match(md_p,    '\\*p\\*\\|')
	expect_no_match(md_p, '\\|\\*p\\*')
	expect_match(md_s,    '\\*p\\*\\|')
	expect_no_match(md_s, '\\|\\*p\\*')
})

test_that('format_summary handles mgcv::gam binomial family', {
	set.seed(2); n <- 200
	dat <- data.frame(yb=rbinom(n, 1, 0.5),
			  x1=rnorm(n), x2=rnorm(n), x3=rnorm(n))
	g <- mgcv::gam(yb ~ x1 + s(x2) + s(x3), data=dat, family=binomial)
	tex <- render(summary(g), format='latex', gam_layout='stacked')
	expect_match(tex, '& \\$z\\$')
	expect_match(tex, '& \\$\\\\chi\\^2\\$')
	expect_no_match(tex, '& \\$t\\$')
	expect_no_match(tex, 'Chi\\.sq')

	md <- render(summary(g), format='markdown', gam_layout='stacked')
	expect_match(md, '\\*z\\*')
	expect_match(md, '\\*\u03c7\u00b2\\*')
	expect_no_match(md, 'Chi\\.sq')
})

test_that('format_summary handles mgcv::bam', {
	set.seed(1); n <- 200
	dat <- data.frame(y=rnorm(n), x1=rnorm(n),
			  x2=rnorm(n), x3=rnorm(n))
	b <- mgcv::bam(y ~ x1 + s(x2) + s(x3), data=dat)
	tex <- render(summary(b), format='latex', gam_layout='stacked')
	expect_match(tex, 'A\\. Parametric')
	expect_match(tex, 'B\\. Smooth')
})

test_that('format_summary rejects unknown gam_layout', {
	set.seed(1); n <- 100
	dat <- data.frame(y=rnorm(n), x1=rnorm(n), x2=rnorm(n))
	g <- mgcv::gam(y ~ x1 + s(x2), data=dat)
	expect_error(
		format_summary(summary(g), gam_layout='banana'),
		'Unknown gam_layout'
	)
})
