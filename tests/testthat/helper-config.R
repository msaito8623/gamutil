library(testthat)
library(ggplot2)
library(mgcv)
RhpcBLASctl::blas_set_num_threads(1)
RhpcBLASctl::omp_set_num_threads(1)

set.seed(534)
invisible(capture.output(tdat <- mgcv::gamSim(eg=6,verbose=FALSE)))
tmdl0 <- mgcv::gam(y ~ s(x0, by=fac) + s(x1, by=fac, k=5)
		     + s(x2) + ti(x0,x1,by=fac)
		     + ti(x0,x2,by=fac), data=tdat)
x2max <- max(tmdl0$model$x2)
tmdl1 <- mgcv::gam(y ~ s(x0), data=tdat)
tmdl2 <- mgcv::gam(y ~ s(x0, by=fac) + s(x1, by=fac, k=5)
		     + ti(x0,x1), data=tdat)
tdat3 <- tdat

set.seed(432)
tdat3$foo <- factor(sample(LETTERS[1:3], nrow(tdat3), replace=TRUE))
tmdl3 <- mgcv::gam(y ~ s(x0, by=fac) + s(x1, by=foo)
		     + ti(x0,x1, by=fac), data=tdat3)

