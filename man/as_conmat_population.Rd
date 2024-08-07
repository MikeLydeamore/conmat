% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/conmat-population.R
\name{as_conmat_population}
\alias{as_conmat_population}
\alias{as_conmat_population.default}
\alias{as_conmat_population.data.frame}
\alias{as_conmat_population.list}
\alias{as_conmat_population.grouped_df}
\title{Convert to conmat population}
\usage{
as_conmat_population(data, ...)

\method{as_conmat_population}{default}(data, ...)

\method{as_conmat_population}{data.frame}(data, age, population, ...)

\method{as_conmat_population}{list}(data, age, population, ...)

\method{as_conmat_population}{grouped_df}(data, age, population, ...)
}
\arguments{
\item{data}{data.frame}

\item{...}{extra arguments}

\item{age}{age column - an unquoted variable of numeric integer ages}

\item{population}{population column - an unquoted variable, numeric value}
}
\description{
Convert to conmat population
}
\examples{
some_age_pop <- data.frame(
  age = 1:10,
  pop = 101:110
)

some_age_pop

as_conmat_population(
  some_age_pop,
  age = age,
  population = pop
)
}
