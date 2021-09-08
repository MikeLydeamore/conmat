#' ABS employment by age and lga for 2016
#'
#' A dataset containing Australian Bureau of Statistics employment data by
#'   state for 206
#'
#' @format A data frame with 4317 rows and 13 variables:
#' \describe{
#'   \item{year}{year - 2-16}
#'   \item{state}{state - long state or territory name}
#'   \item{lga}{local government area name}
#'   \item{lga_code}{lga code}
#'   \item{labour_force_status}{contains: "Total Employed", "Total Unemployed",
#'   "Total Labour Force", and "Total". (although initially contained:
#'     "Employed, worked full-time", "Employed, worked part-time",
#'     "Employed, away from work", "Employed, hours of work not stated",
#'     "Unemployed, looking for full-time work",
#'     "Unemployed, looking for part-time work", "Not in the labour force",
#'     "Labour force status not stated", "Total Employed", "Total Unemployed",
#'     "Total Labour Force", "Total"}
#'   \item{age}{4- (4 or younger, then 1 year increments to 20, then 21+ (21 or older)}
#'   \item{males}{number of males in a category}
#'   \item{females}{number of females in a category}
#'   \item{persons}{total number of people in a category}
#'   \item{diff}{difference in numbers, as calcualted as persons - (males + females)}
#' }
#' @source ABS.stat \url{https://stat.data.abs.gov.au/Index.aspx?} LABOUR >
#'   Employment and Unemployment > Labour force status >
#'   Census 2016, G43 labour status by age and sex (LGA)
"abs_employ_age_lga"