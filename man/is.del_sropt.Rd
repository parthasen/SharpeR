% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/sr.r
\name{is.del_sropt}
\alias{is.del_sropt}
\title{Is this in the "del_sropt" class?}
\usage{
is.del_sropt(x)
}
\arguments{
\item{x}{an object of some kind.}
}
\value{
a boolean.
}
\description{
Checks if an object is in the class \code{'del_sropt'}
}
\details{
To satisfy the minimum requirements of an S3 class.
}
\examples{
roll.own <- del_sropt(z.s=2,z.sub=1,df1=10,df2=1000,df1.sub=3,ope=1,epoch="yr")
is.sropt(roll.own)
}
\author{
Steven E. Pav \email{shabbychef@gmail.com}
}
\seealso{
del_sropt

Other del_sropt: \code{\link{as.del_sropt}},
  \code{\link{as.del_sropt.default}},
  \code{\link{as.del_sropt.xts}}; \code{\link{del_sropt}}
}

