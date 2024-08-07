% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setting-transmission-matrix.R
\name{transmission_probability_matrix}
\alias{transmission_probability_matrix}
\title{Create a setting transmission matrix}
\usage{
transmission_probability_matrix(..., age_breaks)
}
\arguments{
\item{...}{list of matrices}

\item{age_breaks}{age breaks - numeric}
}
\value{
transmission probability matrix
}
\description{
Helper function to create your own setting transmission matrix, which you
may want to use in ... or \code{autoplot}. This class is the
output of functions like \code{...}, and ... . We recommend using this
function is only for advanced users, who are creating their own
transmission probability matrix.
}
\examples{

age_breaks_0_80_plus <- c(seq(0, 80, by = 10), Inf)
one_05 <- matrix(0.05, nrow = 9, ncol = 9)

x_example <- transmission_probability_matrix(
  home = one_05,
  work = one_05,
  age_breaks = age_breaks_0_80_plus
)

x_example <- transmission_probability_matrix(
  one_05,
  one_05,
  age_breaks = age_breaks_0_80_plus
)

x_example

}
