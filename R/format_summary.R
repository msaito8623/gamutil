#' Render a model summary as a knitr::kable table
#'
#' Takes a `summary()` object from a fitted model and returns a
#' [knitr::kable] suitable for inclusion in a LaTeX, Markdown, or
#' reStructuredText document. The function is an S3 generic that
#' dispatches on the class of the summary object. Methods are
#' provided for:
#'
#' * `lm`, `glm` (Gaussian or non-Gaussian families), `lme4::lmer`,
#'   `lme4::glmer`, and `lmerTest::lmer`: a single coefficient table
#'   with columns Estimate, SE, optional df (only with `lmerTest`),
#'   *t* or *z*, and optional *p* (`lme4::lmer` produces none).
#' * `mgcv::gam` and `mgcv::bam`: two sub-tables (parametric and
#'   smooth). `gam_layout` controls whether they are combined into a
#'   single stacked table with embedded section-header rows, or
#'   returned as a named list of two separate kables.
#'
#' p-values below 0.001 are formatted as `"<0.001"`. Column headers for
#' test statistics are wrapped in math italics: for LaTeX, `$t$`, `$z$`,
#' `$F$`, `$\chi^2$`, `$p$`; for Markdown / RST, `*t*`, `*z*`, `*F*`,
#' the Unicode chi-squared character (U+03C7 U+00B2) wrapped in `*...*`,
#' and `*p*`.
#'
#' @param smry A `summary` object as returned by `summary()` for a
#'   fitted `lm`, `glm`, `lme4::lmer`, `lme4::glmer`, `lmerTest::lmer`,
#'   `mgcv::gam`, or `mgcv::bam` model.
#' @param format A character of length 1. One of `"latex"` (default),
#'   `"markdown"`, or `"rst"`. Passed through to [knitr::kable].
#' @param digits Integer. Number of decimal places to show for numeric
#'   cells. Default `3`.
#' @param ... Method-specific arguments. The `summary.gam` method
#'   accepts `gam_layout`: `"stacked"` (default) returns a single
#'   table with embedded section-header rows `(A. Parametric)` and
#'   `(B. Smooth)`; `"split"` returns a named list with elements
#'   `parametric` and `smooth`, each a separate kable.
#' @return For non-GAM summaries: a `knitr_kable` object. For GAM/BAM
#'   summaries with `gam_layout="stacked"`: a `knitr_kable` object
#'   (with a manually-assembled body for LaTeX). For GAM/BAM with
#'   `gam_layout="split"`: a named `list(parametric, smooth)` of two
#'   `knitr_kable` objects.
#' @author Motoki Saito, \email{motoki.saito@uni-oldenburg.de}
#' @keywords utilities
#' @examples
#' \donttest{
#' set.seed(1); n <- 200
#' dat <- data.frame(y=rnorm(n), x1=rnorm(n), x2=rnorm(n))
#' fit <- lm(y ~ x1 + x2, data=dat)
#' format_summary(summary(fit), format='markdown')
#'
#' library(mgcv)
#' g <- gam(y ~ x1 + s(x2), data=dat)
#' format_summary(summary(g), format='latex', gam_layout='stacked')
#' k <- format_summary(summary(g), format='latex', gam_layout='split')
#' k$parametric
#' k$smooth
#' }
#' @export
format_summary <- function(smry, format='latex', digits=3, ...) {
	if (!requireNamespace("knitr", quietly=TRUE)) {
		stop("Package 'knitr' is required by format_summary(). ",
		     "Install it with install.packages(\"knitr\").",
		     call.=FALSE)
	}
	UseMethod("format_summary")
}

#' @exportS3Method format_summary default
format_summary.default <- function(smry, format='latex', digits=3, ...) {
	stop("format_summary() has no method for class '",
	     paste(class(smry), collapse="', '"), "'.", call.=FALSE)
}

#' @exportS3Method format_summary summary.lm
format_summary.summary.lm <- function(smry, format='latex', digits=3, ...) {
	.coefs_to_kable(as.data.frame(smry$coefficients),
			format=format, digits=digits)
}

#' @exportS3Method format_summary summary.glm
format_summary.summary.glm <- function(smry, format='latex', digits=3, ...) {
	.coefs_to_kable(as.data.frame(smry$coefficients),
			format=format, digits=digits)
}

#' @exportS3Method format_summary summary.merMod
format_summary.summary.merMod <- function(smry, format='latex', digits=3, ...) {
	.coefs_to_kable(as.data.frame(smry$coefficients),
			format=format, digits=digits)
}

#' @exportS3Method format_summary summary.lmerModLmerTest
format_summary.summary.lmerModLmerTest <- function(smry, format='latex', digits=3, ...) {
	.coefs_to_kable(as.data.frame(smry$coefficients),
			format=format, digits=digits)
}

#' @exportS3Method format_summary summary.gam
format_summary.summary.gam <- function(smry, format='latex', digits=3,
					       gam_layout='stacked', ...) {
	.gam_to_kable(smry, format=format, digits=digits, layout=gam_layout)
}

# Translate a test-statistic label into a format-specific glyph. "Chi.sq" is
# replaced with \chi^2 in LaTeX and the Unicode chi-squared character (U+03C7
# U+00B2) in Markdown / RST, since neither CommonMark nor RST guarantees
# math-mode support. All other labels (t, z, F, p) are passed through
# unchanged.
.stat_glyph <- function(letter, format) {
	if (letter == "Chi.sq") {
		if (format == 'latex') "\\chi^2"
		else                   "\u03c7\u00b2"
	} else {
		letter
	}
}

.coefs_to_kable <- function(coefs, format='latex', digits=3) {
	# Helper for lm/glm/lmer/glmer-style coefficient matrices.
	cols <- colnames(coefs)
	est_col <- match("Estimate", cols)
	se_col  <- grep("^Std", cols)[1]
	df_col  <- match("df", cols)
	t_col   <- match("t value", cols)
	z_col   <- match("z value", cols)
	p_col   <- grep("^Pr\\(", cols)[1]
	if (!is.na(z_col)) { stat_col <- z_col; stat_letter <- "z" }
	else               { stat_col <- t_col; stat_letter <- "t" }
	has_df <- !is.na(df_col)
	has_p  <- !is.na(p_col)
	keep <- c(est_col, se_col,
		  if (has_df) df_col,
		  stat_col,
		  if (has_p)  p_col)
	coefs <- coefs[, keep, drop=FALSE]
	if (has_p) {
		last <- ncol(coefs)
		coefs[, last] <- ifelse(coefs[, last] < 0.001, "<0.001",
					sprintf("%.3f", coefs[, last]))
	}
	wrap <- if (format == 'latex') function(s) sprintf("$%s$", s)
		else                   function(s) sprintf("*%s*", s)
	col_names <- c("Estimate", "SE",
		       if (has_df) "df",
		       wrap(.stat_glyph(stat_letter, format)),
		       if (has_p)  wrap("p"))
	# Force right-alignment of all data columns.
	align <- rep("r", ncol(coefs))
	if (format == 'latex') {
		knitr::kable(coefs, format='latex', digits=digits, booktabs=TRUE,
			     escape=FALSE, col.names=col_names, align=align)
	} else {
		knitr::kable(coefs, format=format, digits=digits, col.names=col_names,
			     align=align)
	}
}

.process_p_table <- function(p) {
	# Pulls Estimate, SE, t/z, p out of a gam summary $p.table.
	cols <- colnames(p)
	est_col <- match("Estimate", cols)
	se_col  <- grep("^Std", cols)[1]
	t_col   <- match("t value", cols)
	z_col   <- match("z value", cols)
	p_col   <- grep("^Pr\\(", cols)[1]
	stat_letter <- if (!is.na(z_col)) "z" else "t"
	stat_col    <- if (!is.na(z_col)) z_col else t_col
	df <- p[, c(est_col, se_col, stat_col, p_col), drop=FALSE]
	df[, 4] <- ifelse(df[, 4] < 0.001, "<0.001", sprintf("%.3f", df[, 4]))
	list(df=df, stat_letter=stat_letter)
}

.process_s_table <- function(s) {
	# Pulls edf, Ref.df, F/Chi.sq, p out of a gam summary $s.table.
	cols <- colnames(s)
	edf_col <- match("edf", cols)
	ref_col <- match("Ref.df", cols)
	F_col   <- match("F", cols)
	Chi_col <- match("Chi.sq", cols)
	p_col   <- grep("^p", cols)[1]
	stat_letter <- if (!is.na(Chi_col)) "Chi.sq" else "F"
	stat_col    <- if (!is.na(Chi_col)) Chi_col else F_col
	df <- s[, c(edf_col, ref_col, stat_col, p_col), drop=FALSE]
	df[, 4] <- ifelse(df[, 4] < 0.001, "<0.001", sprintf("%.3f", df[, 4]))
	list(df=df, stat_letter=stat_letter)
}

.gam_to_kable <- function(smry, format='latex', digits=3, layout='stacked') {
	p_proc <- .process_p_table(as.data.frame(smry$p.table))
	s_proc <- .process_s_table(as.data.frame(smry$s.table))
	if (layout == 'split') {
		.gam_split(p_proc, s_proc, format=format, digits=digits)
	} else if (layout == 'stacked') {
		spec <- .gam_stacked_spec(p_proc, s_proc, digits)
		if (format == 'latex') .gam_stacked_latex(spec)
		else                   .gam_stacked_md_rst(spec, format)
	} else {
		stop(sprintf("Unknown gam_layout: '%s' (expected 'stacked' or 'split')",
			     layout))
	}
}

# Shared specification for the stacked GAM table. Both renderers below consume
# this so column definitions, number formatting, and data extraction live in
# one place; the renderers only add format-specific markup. Each element of the
# returned list is a section block:
#   label: row-leader text (e.g. "(A. Parametric)")
#   cols:  column header labels in display order
#   body:  character matrix of formatted cells, rownames = term names
.gam_stacked_spec <- function(p_proc, s_proc, digits) {
	fmt_num <- function(x) sprintf(paste0("%.", digits, "f"), x)
	fmt_block <- function(d) {
		out <- matrix("", nrow=nrow(d), ncol=4)
		for (k in 1:3) out[, k] <- fmt_num(d[, k])
		out[, 4] <- as.character(d[, 4])
		rownames(out) <- rownames(d)
		out
	}
	list(
		list(label="(A. Parametric)",
		     cols =c("Estimate", "SE", p_proc$stat_letter, "p"),
		     body =fmt_block(p_proc$df)),
		list(label="(B. Smooth)",
		     cols =c("edf", "Ref.df", s_proc$stat_letter, "p"),
		     body =fmt_block(s_proc$df))
	)
}

.gam_split <- function(p_proc, s_proc, format='latex', digits=3) {
	wrap <- if (format == 'latex') function(s) sprintf("$%s$", s)
		else                   function(s) sprintf("*%s*", s)
	p_cols <- c("Estimate", "SE", wrap(.stat_glyph(p_proc$stat_letter, format)), wrap("p"))
	s_cols <- c("edf",      "Ref.df", wrap(.stat_glyph(s_proc$stat_letter, format)), wrap("p"))
	# Force right-alignment of all data columns.
	align <- rep("r", 4)
	if (format == 'latex') {
		k_p <- knitr::kable(p_proc$df, format='latex', digits=digits,
				    booktabs=TRUE, escape=FALSE, col.names=p_cols, align=align)
		k_s <- knitr::kable(s_proc$df, format='latex', digits=digits,
				    booktabs=TRUE, escape=FALSE, col.names=s_cols, align=align)
	} else {
		k_p <- knitr::kable(p_proc$df, format=format, digits=digits,
				    col.names=p_cols, align=align)
		k_s <- knitr::kable(s_proc$df, format=format, digits=digits,
				    col.names=s_cols, align=align)
	}
	list(parametric=k_p, smooth=k_s)
}

# LaTeX is hand-assembled into \begin{tabular}...\end{tabular} because
# knitr::kable cannot inject mid-table \midrule separators between
# sub-tables that have different column meanings, which is required by the
# stacked layout needs: parametric and smooth blocks share the table envelope
# but expose distinct column sets.
.gam_stacked_latex <- function(spec) {
	cells <- function(xs) paste(xs, collapse=" & ")
	fmt_section <- function(sec) {
		head <- c(sec$label, sec$cols[1], sec$cols[2],
			  sprintf("$%s$", .stat_glyph(sec$cols[3], 'latex')),
			  sprintf("$%s$", sec$cols[4]))
		rows <- vapply(seq_len(nrow(sec$body)), function(i) {
			paste(cells(c(rownames(sec$body)[i], sec$body[i, ])),
			      "\\\\")
		}, character(1))
		c(paste(cells(head), "\\\\"), "\\midrule", rows)
	}
	sections <- lapply(spec, fmt_section)
	lines <- c("\\begin{tabular}{lrrrr}",
		   "\\toprule",
		   sections[[1]],
		   "\\midrule",
		   sections[[2]],
		   "\\bottomrule",
		   "\\end{tabular}")
	structure(paste(lines, collapse="\n"),
		  class="knitr_kable", format="latex")
}

# Markdown/RST: section labels and column-header labels are emitted as inline
# rows in a single data frame so knitr::kable can render the whole stacked
# table in one call. Section labels are bolded so they visually separate the
# sub-tables in lieu of a \midrule.
.gam_stacked_md_rst <- function(spec, format) {
	italic <- function(s) sprintf("*%s*", s)
	bold   <- function(s) sprintf("**%s**", s)
	terms <- character(); c2 <- character(); c3 <- character()
	c4    <- character(); c5 <- character()
	for (sec in spec) {
		terms <- c(terms, bold(sec$label), rownames(sec$body))
		c2 <- c(c2, sec$cols[1],          sec$body[, 1])
		c3 <- c(c3, sec$cols[2],          sec$body[, 2])
		c4 <- c(c4, italic(.stat_glyph(sec$cols[3], format)),  sec$body[, 3])
		c5 <- c(c5, italic(sec$cols[4]),  sec$body[, 4])
	}
	df <- data.frame(Term=terms, V2=c2, V3=c3, V4=c4, V5=c5,
			 stringsAsFactors=FALSE)
	knitr::kable(df, format=format, col.names=c("Term", "", "", "", ""),
		     row.names=FALSE, align=c("l", "r", "r", "r", "r"))
}
