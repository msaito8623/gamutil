test_that('vary() returns a sorted unique vector for character/factor.', {
	vec <- c(rep('A',2), rep('B',3), rep('C',1))
	vry <- vary(vec)
	tst <- LETTERS[1:3]
	expect_true(all(vapply(1:3,
			       function(x) vry[x]==tst[x],
			       FUN.VALUE=logical(1),
			       USE.NAMES=FALSE)))
	vec <- factor(vec)
	vry <- vary(vec)
	tst <- LETTERS[1:3]
	expect_true(all(vapply(1:3,
			       function(x) vry[x]==tst[x],
			       FUN.VALUE=logical(1),
			       USE.NAMES=FALSE)))
})
test_that('vary() returns an error if not numeric/character/factor.', {
	lst <- list(rep('A',2), rep('B',3), rep('C',1))
	expect_error(vary(lst))
})
