library(mgcv)

### For testing ###
set.seed(534)
invisible(capture.output(tdat <- gamSim(eg=6,verbose=FALSE)))

tmdl0  <- gam(y ~ s(x0, by=fac) + s(x1, by=fac, k=5) + s(x2) + ti(x0,x1,by=fac) + ti(x0,x2,by=fac), data=tdat)
x2max <- max(tmdl0$model$x2)

tmdl1  <- gam(y ~ s(x0), data=tdat)

tmdl2 <- gam(y ~ s(x0, by=fac) + s(x1, by=fac, k=5) + ti(x0,x1),
		     data=tdat)
tdat3 <- tdat
set.seed(432)
tdat3$foo <- factor(sample(LETTERS[1:3], nrow(tdat3), replace=TRUE))
tmdl3 <- gam(y ~ s(x0, by=fac) + s(x1, by=foo) + ti(x0,x1, by=fac),
	     data=tdat3)

### For vignettes ###
dat <- gamutil::example_df()
mdl <- gam(y ~ s(x0) + s(x1) + s(x2) +
	       ti(x0, x1) + ti(x0, x2) + ti(x1, x2) +
	       ti(x0, x1, x2), data=dat)

### Output ###
usethis::use_data(tdat, tdat3, tmdl0, tmdl1, tmdl2, tmdl3, x2max, dat, mdl, internal=TRUE, overwrite=TRUE)
