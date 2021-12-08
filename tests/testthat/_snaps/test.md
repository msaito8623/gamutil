# add_fit, verbose, when no term is matched (terms.size=min).

    Code
      expect_error(add_fit(ndat, tmdl, terms = tgt, cond = cnd, terms.size = "min",
        ci.mult = 1, verbose = TRUE))
    Output
      
      ###### VERBOSE ######
      ERROR: No term is matched.
      
      terms = c(foo, bar)
      terms.size = min
      Available terms:
      --> s(x0, by = fac), s(x1, by = fac, k = 5), s(x2), ti(x0, x1, by = fac), ti(x0, x2, by = fac)
      
      Since terms.size=min, the only one term that matches exactly c(foo, bar) was searched.
      
      Did you maybe forget to specify a level of the "by" variable?
      "by" variables need to be included in "cond".
      e.g., ti(x0,x1,by=fac)
      --> view/terms=c("x0","x1"), cond=list(fac="1").
      
      Or maybe did you include unnecessary variables in "cond"?
      e.g., view/terms=c("x0","x1"), cond=list(fac="1", x2=0.5)
      --> The terms that also contain "x2" are searched such as ti(x0,x1,x2,by=fac)
      --> Then ti(x0,x1,by=fac) would be excluded for example when terms.size="min".
      
      I hope this explanation helps!.
      ###### VERBOSE ######
      

# add_fit, verbose, when no term is matched (terms.size=medium).

    Code
      expect_error(add_fit(ndat, tmdl, terms = tgt, cond = cnd, terms.size = "medium",
        ci.mult = 1, verbose = TRUE))
    Output
      
      ###### VERBOSE ######
      ERROR: No term is matched.
      
      terms = c(foo, bar)
      terms.size = medium
      Available terms:
      --> s(x0, by = fac), s(x1, by = fac, k = 5), s(x2), ti(x0, x1, by = fac), ti(x0, x2, by = fac)
      
      Since terms.size=medium, the terms were searched that contain only the elements in c(foo, bar).
      
      Did you maybe forget to specify a level of the "by" variable?
      "by" variables need to be included in "cond".
      e.g., ti(x0,x1,by=fac)
      --> view/terms=c("x0","x1"), cond=list(fac="1").
      
      Or maybe did you include unnecessary variables in "cond"?
      e.g., view/terms=c("x0","x1"), cond=list(fac="1", x2=0.5)
      --> The terms that also contain "x2" are searched such as ti(x0,x1,x2,by=fac)
      --> Then ti(x0,x1,by=fac) would be excluded for example when terms.size="min".
      
      I hope this explanation helps!.
      ###### VERBOSE ######
      

# add_fit, verbose, when no term is matched (terms.size=max).

    Code
      expect_error(add_fit(ndat, tmdl, terms = tgt, cond = cnd, terms.size = "max",
        ci.mult = 1, verbose = TRUE))
    Output
      
      ###### VERBOSE ######
      ERROR: No term is matched.
      
      terms = c(foo, bar)
      terms.size = max
      Available terms:
      --> s(x0, by = fac), s(x1, by = fac, k = 5), s(x2), ti(x0, x1, by = fac), ti(x0, x2, by = fac)
      
      Since terms.size=max, the terms were searched that contain at least one of the elements in c(foo, bar).
      
      Did you maybe forget to specify a level of the "by" variable?
      "by" variables need to be included in "cond".
      e.g., ti(x0,x1,by=fac)
      --> view/terms=c("x0","x1"), cond=list(fac="1").
      
      Or maybe did you include unnecessary variables in "cond"?
      e.g., view/terms=c("x0","x1"), cond=list(fac="1", x2=0.5)
      --> The terms that also contain "x2" are searched such as ti(x0,x1,x2,by=fac)
      --> Then ti(x0,x1,by=fac) would be excluded for example when terms.size="min".
      
      I hope this explanation helps!.
      ###### VERBOSE ######
      

