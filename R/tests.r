# Copyright 2012 Steven E. Pav. All Rights Reserved.
# Author: Steven E. Pav

# This file is part of Ratarb.
#
# Ratarb is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ratarb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Ratarb.  If not, see <http://www.gnu.org/licenses/>.

# env var:
# nb: 
# see also:
# todo:
# changelog: 
#
# Created: 2012.05.19
# Copyright: Steven E. Pav, 2012-2013
# Author: Steven E. Pav
# Comments: Steven E. Pav
# SVN: $Id: blankheader.txt 25454 2012-02-14 23:35:25Z steven $

#         @include utils.r
#source("utils.r")
#         @include distributions.r
#source("distributions.r")

########################################################################
# Tests 
########################################################################

# equality of SR#FOLDUP

#' @title Paired test for equality of Sharpe ratio
#'
#' @description 
#'
#' Performs a hypothesis test of equality of Sharpe ratios of p assets
#' given paired observations.
#'
#' @details 
#'
#' Given \eqn{n} \emph{i.i.d.} observations of the excess returns of
#' \eqn{p} strategies, we test
#' \deqn{H_0: \frac{\mu_i}{\sigma_i} = \frac{\mu_j}{\sigma_j}, 1 \le i < j \le p}{H0: sr1 = sr2 = ...}
#' using the method of Wright, et. al. 
#' 
#' More generally, a matrix of constrasts, \eqn{E}{E} can be given, and we can
#' test
#' \deqn{H_0: E s = 0,}{H0: E s = 0,}
#' where \eqn{s}{s} is the vector of Sharpe ratios of the \eqn{p} strategies.
#' 
#' Both chi-squared and F- approximations are supported.
#' 
#' @usage
#'
#' sr.equality.test(X,contrasts=NULL,type=c("chisq","F"))
#'
#' @param X an \eqn{n \times p}{n x p} matrix of paired observations.
#' @param contrasts an \eqn{k \times p}{k x p} matrix of the contrasts
#         to test. This defaults to a matrix which tests sequential equality.
#' @param type which approximation to use. 'chisq' is preferred when
#'        the returns are non-normal, but the approximation is asymptotic.
#' @keywords htest
#' @return Object of class \code{htest}, a list of the test statistic,
#' the size of \code{X}, and the \code{method} noted.
#' @seealso \code{\link{sr.test}}
#' @export 
#' @author Steven E. Pav \email{shabbychef@@gmail.com}
#' @references 
#'
#' Wright, J. A., Yam, S. C. P., and Yung, S. P. "A note on the test for the
#' equality of multiple Sharpe ratios and its application on the evaluation
#' of iShares." J. Risk. to appear. 
#' \url{http://www.sta.cuhk.edu.hk/scpy/Preprints/John\%20Wright/A\%20test\%20for\%20the\%20equality\%20of\%20multiple\%20Sharpe\%20ratios.pdf}
#'
#' Leung, P.-L., and Wong, W.-K. "On testing the equality of multiple Sharpe ratios, with 
#' application on the evaluation of iShares." J. Risk 10, no. 3 (2008): 15-30.
#' \url{http://papers.ssrn.com/sol3/papers.cfm?abstract_id=907270}
#'
#' Memmel, C. "Performance hypothesis testing with the Sharpe ratio." Finance
#' Letters 1 (2003): 21-23.
#'
#' @examples 
#' rv <- sr.equality.test(matrix(rnorm(500*5),500,5))
#' # test for uniformity
#' pvs <- replicate(500,{ x <- sr.equality.test(matrix(rnorm(400*5),400,5),type="chisq")
#'                        x$p.value })
#' plot(ecdf(pvs))
#' abline(0,1,col='red') 
#'
#'@export
sr.equality.test <- function(X,contrasts=NULL,type=c("chisq","F")) {
	dname <- deparse(substitute(X))
	type <- match.arg(type)
	n <- dim(X)[1]
	p <- dim(X)[2]
	if (is.null(contrasts))
		contrasts <- .atoeplitz(c(1,-1,array(0,p-2)),c(1,array(0,p-2)))
	k <- dim(contrasts)[1]
	if (dim(contrasts)[2] != p)
		stop("size mismatch in 'X', 'contrasts'")

	# compute moments
	m1 <- colMeans(X)
	m2 <- colMeans(X^2)
	# construct Sigma hat
	Shat <- cov(cbind(X,X^2))
	#Shat <- .agram(cbind(X,X^2))
	# the SR
	SR <- m1 / sqrt(diag(Shat[1:p,1:p]))

	# construct D matrix
	deno <- (m2 - m1^2)^(3/2)
	D1 <- diag(m2 / deno)
	D2 <- diag(-m1 / (2*deno))
	Dt <- rbind(D1,D2)

	# Omegahat
	Ohat <- t(Dt) %*% Shat %*% Dt

	# the test statistic:
	ESR <- contrasts %*% SR
	T2 <- n * t(ESR) %*% solve(contrasts %*% Ohat %*% t(contrasts),ESR)

	pval <- switch(type,
								 chisq = pchisq(T2,df=k,ncp=0,lower.tail=FALSE),
								 F = pf((n-k) * T2/((n-1) * k),df1=k,df2=n-k,lower.tail=FALSE))

	# attach names
	names(T2) <- "T2"
	names(k) <- "contrasts"
	method <- paste(c("test for equality of Sharpe ratio, via",type,"test"),collapse=" ")
	names(SR) <- sapply(1:p,function(x) { paste(c("strat",x),collapse="_") })

	retval <- list(statistic = T2, parameter = k,
							 df1 = p, df2 = n, p.value = pval, 
							 SR = SR,
							 method = method, data.name = dname)
	class(retval) <- "htest"
	return(retval)
}
#UNFOLD

# SR test#FOLDUP
#getAnywhere("t.test.default")
#' @title test for Sharpe ratio
#'
#' @description 
#'
#' Performs one and two sample tests of Sharpe ratio on vectors of data.
#'
#' @details 
#'
#' 2FIX
#' 
#' @usage
#'
#' sr.test(x,y=NULL,alternative=c("two.sided","less","greater"),
#'         snr=0,opy=1,paired=FALSE,conf.level=0.95)
#'
#' @param x a (non-empty) numeric vector of data values.
#' @param y an optional (non-empty) numeric vector of data values.
#' @param snr a number indicating .... 2FIX START HERE ... 
#' @keywords htest
#' @return  2FIX ... 
#' @seealso \code{\link{sr.equality.test}}, \code{\link{t.test}}.
#' @export 
#' @author Steven E. Pav \email{shabbychef@@gmail.com}
#' @examples 
#' # should reject null
#' x <- sr.test(rnorm(1000,mean=0.5,sd=0.1),snr=2,opy=1,alternative="greater")
#' x <- sr.test(rnorm(1000,mean=0.5,sd=0.1),snr=2,opy=1,alternative="two.sided")
#' # should not reject null
#' x <- sr.test(rnorm(1000,mean=0.5,sd=0.1),snr=2,opy=1,alternative="less")
#'
#' # test for uniformity
#' pvs <- replicate(1000,{ x <- sr.test(rnorm(1000),opy=253,alternative="two.sided")
#'                         x$p.value })
#' plot(ecdf(pvs))
#' abline(0,1,col='red') 
#'
#'@export
sr.test <- function(x,y=NULL,alternative=c("two.sided","less","greater"),
										snr=0,opy=1,paired=FALSE,conf.level=0.95) {
	# all this stolen from t.test.default:
	alternative <- match.arg(alternative)
	if (!missing(snr) && (length(snr) != 1 || is.na(snr))) 
		stop("'snr' must be a single number")
	if (!missing(conf.level) && (length(conf.level) != 1 || !is.finite(conf.level) || 
		conf.level < 0 || conf.level > 1)) 
		stop("'conf.level' must be a single number between 0 and 1")

	if (!is.null(y)) {
		dname <- paste(deparse(substitute(x)), "and", deparse(substitute(y)))
		if (paired) {
			xok <- yok <- complete.cases(x, y)
		} else {
			yok <- !is.na(y)
			xok <- !is.na(x)
		}
		y <- y[yok]
	} else {
		dname <- deparse(substitute(x))
		if (paired) 
			stop("'y' is missing for paired test")
		xok <- !is.na(x)
		yok <- NULL
	}
	x <- x[xok]
	mx <- mean(x)
	vx <- var(x)
	sx <- mx / sqrt(vx)
	if (is.null(y)) {
		nx <- length(x)
		if (nx < 2) 
			stop("not enough 'x' observations")
		estimate <- .annualize(sx,opy)
		tstat <- .sr_to_t(sx,nx)
		df <- nx - 1

		method <- "One Sample sr test"
		names(estimate) <- "Sharpe ratio of x"

		# 2FIX: add CIs here.
		if (alternative == "less") {
			pval <- psr(estimate, df=nx, snr=snr, opy=opy)
		}
		else if (alternative == "greater") {
			pval <- psr(estimate, df=nx, snr=snr, opy=opy, lower.tail = FALSE)
		}
		else {
			pval <- 1 - 2 * abs(0.5 - psr(estimate, df=nx, snr=snr, opy=opy))
		}
	} else {
		ny <- length(y)
		if (paired) {
			if (nx != ny)
				stop("'x','y' must be same length")
			df <- nx - 1

			subtest <- sr.equality.test(cbind(x,y),type="chisq")
			# x minus y
			estimate <- - diff(as.vector(subtest$SR))
			method <- "Paired sr-test"
			tstat <- sqrt(subtest$statistic) * sign(estimate)

			pval <- subtest$p.value
			if (alternative == "less") {
				pval <- - pval
			}
			else if (alternative == "two.sided") {
				pval <- 1 - 2 * abs(pval - 0.5)
			}
		} else {
			# not yet implemented!
			stop("NYI")

			my <- mean(y)
			vy <- var(y)
			sy <- my / sqrt(vy)
			estimate <- sx - sy
			method <- "unpaired sr-test"
		}
		names(estimate) <- "difference in Sharpe ratios"
	}

	names(tstat) <- "t"
	names(df) <- "df"
	#attr(cint, "conf.level") <- conf.level
	retval <- list(statistic = tstat, parameter = df,
								 estimate = estimate, p.value = pval, 
								 alternative = alternative, null.value = snr,
								 method = method, data.name = dname)
	class(retval) <- "htest"
	return(retval)
}
#UNFOLD

# power of tests:#FOLDUP

#' @title Power calculations for Sharpe ratio tests
#'
#' @description 
#'
#' Compute power of test, or determine parameters to obtain target power.
#'
#' @details 
#'
#' Suppose you perform a single-sample test for significance of the
#' Sharpe ratio based on the corresponding single-sample t-test. 
#' Given any three of: the effect size (the population SNR), the
#' number of observations, and the type I and type II rates,
#' this computes the fourth.
#'
#' This is a thin wrapper on \code{\link{power.t.test}}.
#'
#' Exactly one of the parameters \code{n}, \code{snr}, \code{power}, and 
#' \code{sig.level} must be passed as NULL, and that parameter is determined 
#' from the others.  Notice that \code{sig.level} has non-NULL default, so NULL 
#' must be explicitly passed if you want to compute it.
#' 
#' @usage
#'
#' power.sr.test(n=NULL,snr=NULL,sig.level=0.05,power=NULL,
#'                           alternative=c("one.sided","two.sided"),opy=NULL) 
#'
#' @param n Number of observations
#' @param snr the 'signal-to-noise' parameter, defined as the population
#'        mean divided by the population standard deviation, 'annualized'.
#' @param sig.level Significance level (Type I error probability).
#' @param power Power of test (1 minus Type II error probability).
#' @param alternative One- or two-sided test.
#' @param opy the number of observations per 'year'. \code{x}, \code{q}, and 
#'        \code{snr} are quoted in 'annualized' units, that is, per square root 
#'        'year', but returns are observed possibly at a rate of \code{opy} per 
#'        'year.' default value is 1, meaning no deannualization is performed.
#' @keywords htest
#' @return Object of class \code{power.htest}, a list of the arguments
#' (including the computed one) augmented with \code{method}, \code{note}
#' and \code{n.yr} elements, the latter is the number of years under the
#' given annualization (\code{opy}), \code{NA} if none given.
#' @seealso \code{\link{power.t.test}}
#' @export 
#' @author Steven E. Pav \email{shabbychef@@gmail.com}
#' @examples 
#' anex <- power.sr.test(253,1,0.05,NULL,opy=253) 
#' anex <- power.sr.test(n=253,snr=NULL,sig.level=0.05,power=0.5,opy=253) 
#' anex <- power.sr.test(n=NULL,snr=0.6,sig.level=0.05,power=0.5,opy=253) 
#'
#'@export
power.sr.test <- function(n=NULL,snr=NULL,sig.level=0.05,power=NULL,
													alternative=c("one.sided","two.sided"),
													opy=NULL) {
	# stolen from power.t.test
	if (sum(sapply(list(n, snr, power, sig.level), is.null)) != 1) 
			stop("exactly one of 'n', 'snr', 'power', and 'sig.level' must be NULL")
	if (!is.null(sig.level) && !is.numeric(sig.level) || any(0 > 
			sig.level | sig.level > 1)) 
			stop("'sig.level' must be numeric in [0, 1]")
	type <- "one.sample"
	alternative <- match.arg(alternative)
	if (!missing(opy) && !is.null(opy) && !is.null(snr)) {
		snr <- .deannualize(snr,opy)
	}
	# delegate
	subval <- power.t.test(n=n,delta=snr,sd=1,sig.level=sig.level,
												 power=power,type=type,alternative=alternative,
												 strict=FALSE)
	# interpret
	subval$snr <- subval$delta
	if (!missing(opy) && !is.null(opy)) {
		subval$snr <- .annualize(subval$snr,opy)
		subval$n.yr <- subval$n / opy
	} else {
		subval$n.yr <- NA
	}
	
	retval <- subval[c("n","n.yr","snr","sig.level","power","alternative","note","method")]
	retval <- structure(retval,class=class(subval))
	return(retval)
}

# 2FIX: should this be expanded in its own right?
power.T2.test <- function(df1=NULL,df2=NULL,ncp=NULL,sig.level=0.05,power=NULL) {
	# stolen from power.anova.test
	if (sum(sapply(list(df1, df2, ncp, power, sig.level), is.null)) != 1) 
		stop("exactly one of 'df1', 'df2', 'ncp', 'power', and 'sig.level' must be NULL")
	if (!is.null(sig.level) && !is.numeric(sig.level) || any(0 > 
		sig.level | sig.level > 1)) 
		stop("'sig.level' must be numeric in [0, 1]")
	p.body <- quote({
		delta2 <- df2 * ncp
		pT2(qT2(sig.level, df1, df2, lower.tail = FALSE), df1, df2, delta2, lower.tail = FALSE)
	})
	if (is.null(power)) 
		power <- eval(p.body)
	else if (is.null(df1)) 
		df1 <- uniroot(function(df1) eval(p.body) - power, c(1, 3e+03))$root
	else if (is.null(df2)) 
		df2 <- uniroot(function(df2) eval(p.body) - power, c(3, 1e+06))$root
	else if (is.null(ncp))
		ncp <- uniroot(function(ncp) eval(p.body) - power, c(0, 3e+01))$root
	else if (is.null(sig.level)) 
		sig.level <- uniroot(function(sig.level) eval(p.body) - power, c(1e-10, 1 - 1e-10))$root
	else stop("internal error")
	NOTE <- "one sided test"
	METHOD <- "Hotelling test"
	retval <- structure(list(df1 = df1, df2 = df2, ncp = ncp, delta2 = df2 * ncp,
								 sig.level = sig.level, power = power, 
								 note = NOTE, method = METHOD), class = "power.htest")
	return(retval)
}

#UNFOLD

#for vim modeline: (do not edit)
# vim:ts=2:sw=2:tw=79:fdm=marker:fmr=FOLDUP,UNFOLD:cms=#%s:syn=r:ft=r:ai:si:cin:nu:fo=croql:cino=p0t0c5(0: