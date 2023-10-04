library(mgcv)

### For README and vignettes ###
example_df <- function (n=1000) {
	set.seed(123)
	x0 <- runif(n, -1, 1)
	set.seed(1234)
	x1 <- runif(n, -1, 1)
	set.seed(12345)
	x2 <- runif(n, -1, 1)
	set.seed(123456)
	e <- rnorm(n, 0, 1)
	f <- function (x, a, b, d, g) a*x^3 + b*x^2 + d*x^1 + g
	f0 <-  0.1 * f(x0,  0.02,  0.01, -0.01,  0.00)
	f1 <-  0.1 * f(x1,  0.02,  0.00, -0.02,  0.02)
	f2 <-  0.1 * f(x2,  0.01, -0.01,  0.03, -0.03)
	f3 <-  0.5 * f(x0,  0.02,  0.00, -0.04,  0.04) *
		     f(x1,  0.20,  0.00,  0.50, -0.05)
	f4 <-  1.0 * f(x0,  0.02,  0.10,  0.01,  0.02) *
		     f(x2,  0.20,  0.10, -0.60,  0.06)
	f5 <-  5.0 * f(x1,  1.20, -0.25, -0.01,  0.20) *
		     f(x2,  0.60, -0.25, -0.10,  0.06)
	f6 <- 10.0 * f(x0,  0.10,  0.20,  0.25,  0.20) *
		     f(x1, -1.20,  0.03,  0.10,  1.20) *
		     f(x2,  0.50,  0.40, -0.20,  0.60)
	y <- f0 + f1 + f2 + f3 + f4 + f5 + f6 + e
	dat <- data.frame(y, x0, x1, x2)
	return(dat)
}
dat <- gamutil::example_df()
mdl <- gam(y ~ s(x0) + s(x1) + s(x2) +
	       ti(x0, x1) + ti(x0, x2) + ti(x1, x2) +
	       ti(x0, x1, x2), data=dat)

### For README ###
set.seed(1234)
dat$fac <- factor(sample(c("A","B"), size=nrow(dat), replace=TRUE))
mdl_fac <- gam(y ~ s(x1, by=fac) + s(x2, by=fac)
	         + ti(x1, x2, by=fac), data=dat)


### Output ###
usethis::use_data(mdl, mdl_fac, internal=TRUE, overwrite=TRUE)
