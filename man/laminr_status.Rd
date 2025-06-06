% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sitrep.R
\name{laminr_status}
\alias{laminr_status}
\title{laminr status}
\usage{
laminr_status()
}
\value{
Prints details of the current laminr status
}
\description{
Overview of the current status of the laminr package and its dependencies.
Can be useful for debugging.
}
\details{
Provides information that can be useful for debugging. To run the function
when an error occurs set \code{options(error = laminr::laminr_status)}. Note that
this should be used with some caution as it will print the status whenever
any error occurs.
}
\examples{
laminr_status()
}
