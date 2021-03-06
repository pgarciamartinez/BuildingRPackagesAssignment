% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fars_functions.R
\name{fars_read_years}
\alias{fars_read_years}
\title{Showing table with month and year for each year in the list passed as an input.}
\usage{
fars_read_years(years)
}
\arguments{
\item{years}{A list of character strings or numeric values that provides the individual years to
be used in the file names}
}
\value{
This function simply prints out tables with month and year for each year contained in the
   list passed on as an input
}
\description{
In cases where each year in the list is valid, it prints out a table with month and year. In other
cases, where the value provided is not valid, it highlights that it prints out an error message
("invalid year: " and the troublesome year provided)
}
