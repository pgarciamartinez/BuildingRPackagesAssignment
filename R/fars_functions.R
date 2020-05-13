#' Reading CSV files with "fars_read" function and placing extracted data into data frame.
#'
#' This is a simple function that reads a CSV file (after checking if it exists) and places
#' its content into a data frame without showing any messages to the user along the process.
#'
#' @param filename A character string that provides the location and name of the file to import.
#'
#' @importFrom readr read_csv
#'
#' @importFrom dplyr tbl_df
#'
#' @return This function returns a data frame (tbl_df).
#'
#' @example
#' fars_read("data/MIE.csv")
#' sample_data <- fars_read("data/MIE.csv")
#'
#' @export
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#' Printing "accident_d.csv.bz2" where d gets replaced by the year that gets passed as an input.
#'
#' This is a simple function that prints out the name of a compressed CSV file depending on the
#' year that gets passed to the function.
#'
#' @param year A character string or a numeric that provides the year to be used in the file name.
#'    The first command within the function coerces the type of the variable year into an integer.
#'
#' @return NULL. This function simply prints out the name of the compressed file that should contain some
#'    data.
#'
#' @example
#' make_filename("2003")
#' make_filename(2010)
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        system.file("extdata", sprintf("accident_%d.csv.bz2", year), package="BuildingRPackagesAssignment")
}

#' Showing table with month and year for each year in the list passed as an input.
#'
#' In cases where each year in the list is valid, it prints out a table with month and year. In other
#' cases, where the value provided is not valid, it highlights that it prints out an error message
#' ("invalid year: " and the troublesome year provided)
#'
#' @param years A list of character strings or numeric values that provides the individual years to
#'    be used in the file names
#'
#' @importFrom dplyr mutate
#'
#' @importFrom dplyr select
#'
#' @return This function simply prints out tables with month and year for each year contained in the
#'    list passed on as an input
#'
#' @example
#' fars_read_years(c("2003", "2007", "2012", "2019"))
#' fars_read_years(c(2003, 2007, 2012, 2019))
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>%
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' Showing table with month and year for each year in the list passed as an input.
#'
#' This function first joins the results provided by the function "fars_read_years", then groups the
#' data by the variables "year" and 'MONTH", followed by the grouping by the number of rows in each
#' group and finally splitting the year observations into columns.
#'
#' @param years A list of character strings or numeric values that provides the individual years to
#'    be used in the file names
#'
#' @importFrom dplyr bind_rows
#'
#' @importFrom dplyr group_by
#'
#' @importFrom dplyr summarize
#'
#' @importFrom tidyr spread
#'
#' @return This function simply returns or prints out tables with summaries split by year of the
#'    the number of observations per year and month
#'
#' @example
#' fars_summarize_years(c("2003", "2007", "2012", "2019"))
#' fars_summarize_years(c(2003, 2007, 2012, 2019))
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by(year, MONTH) %>%
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}

#' Shows in a map all the accidents on a given state.
#'
#' Before plotting any accident on the map, this function contains two initial checks: first, by
#' checking that the state number is valid and, second, by seeing if there were no accidents in that
#' state. For the first type of check, the error message is "invalid STATE number: %d" with %d being
#' the state ID provided. The second type of check prints the message "no accidents to plot" if no
#' observations are present in the data frame for that state.
#'
#' @param state.num A list of character strings or numeric values that provides the individual state
#'
#' @param year A character string or a numeric that provides the year to be used in the file.
#'
#' @importFrom dplyr filter
#'
#' @importFrom maps map
#'
#' @importFrom graphics points
#'
#' @return This function plots in a map the locations where accidents occur for a given state.
#'
#' @example
#' fars_map_state("13", "2007")
#' fars_map_state(15, 2010)
#'
#' @export
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
