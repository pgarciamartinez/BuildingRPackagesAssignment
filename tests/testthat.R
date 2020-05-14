library(testthat)
library(BuildingRPackagesAssignment)

test_check("BuildingRPackagesAssignment")
prints_text(fars_summarize_years(c(2013,2014)))
