test_that('constant() returns the most frequent value for character/factor.', {
	vec <- c(rep('A',2), rep('B',3), rep('C',1))
	expect_match(constant(vec), 'B', fixed=TRUE)
	vec <- factor(vec)
	expect_match(constant(vec), 'B', fixed=TRUE)
})
test_that('constant() returns an error if not numeric/character/factor.', {
	lst <- list(rep('A',2), rep('B',3), rep('C',1))
	expect_error(constant(lst))
})
