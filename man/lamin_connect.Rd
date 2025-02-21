% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/connect.R
\name{lamin_connect}
\alias{lamin_connect}
\title{Set the default LaminDB instance}
\usage{
lamin_connect(slug)
}
\arguments{
\item{slug}{Slug giving the instance to connect to (\verb{<owner>/<name>})}
}
\description{
Set the default LaminDB instance by calling \verb{lamin connect} on the command
line
}
\examples{
\dontrun{
lamin_connect("laminlabs/cellxgene")
}
}
