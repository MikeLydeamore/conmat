#' @title Transmission probabilities of COVID19 from Eyre et al.
#'
#' @description A dataset containing data digitised from "The impact of
#'  SARS-CoV-2 vaccination on Alpha & Delta variant transmission", by David W
#'  Eyre, Donald Taylor, Mark Purver, David Chapman, Tom Fowler, Koen B Pouwels,
#'  A Sarah Walker, Tim EA Peto
#'  (\doi{https://doi.org/10.1101/2021.09.28.21264260}. The figures were taken
#'  from
#'  \url{https://www.medrxiv.org/content/10.1101/2021.09.28.21264260v1.full-text},
#'  and the code to digitise these figures is in `data-raw` under
#'  "read_eyre_transmission_probabilities.R". When using this data, ensure that
#'   you cite the original authors at 'Eyre, D. W., Taylor, D., Purver, M., Chapman, D., Fowler, T., Pouwels, K. B., Walker, A. S., & Peto, T. E. (2021). The impact of SARS-CoV-2 vaccination on Alpha & Delta variant transmission (Preprint). Infectious Diseases (except HIV/AIDS). https://doi.org/10.1101/2021.09.28.21264260'
#'
#' @format A data frame of the probability of transmission from a case to a contact. There are 40,804 rows and 6 variables.
#' \describe{
#'   \item{setting}{"household", "household_visitor", "work_education", or
#'      "events_activities"}
#'   \item{case_age}{from 0 to 100}
#'   \item{contact_age}{from ages 0 to 100}
#'   \item{case_age_5y}{If case is between ages 0-4, in 5 year bins up to 100}
#'   \item{contact_age_5y}{If contact is between ages 0-4, in 5 year bins up
#'      to 100}
#'   \item{probability}{probability of transmission. Value is 0 - 1}
#' }
#' @examples
#' \dontrun{
#'
#' # plot this
#' library(ggplot2)
#' library(stringr)
#' eyre_transmission_probabilities %>%
#'   group_by(
#'     setting,
#'     case_age_5y,
#'     contact_age_5y
#'   ) %>%
#'   summarise(
#'     across(
#'       probability,
#'       mean
#'     ),
#'     .groups = "drop"
#'   ) %>%
#'   rename(
#'     case_age = case_age_5y,
#'     contact_age = contact_age_5y
#'   ) %>%
#'   mutate(
#'     across(
#'       ends_with("age"),
#'       ~ factor(.x,
#'         levels = str_sort(
#'           unique(.x),
#'           numeric = TRUE
#'         )
#'       )
#'     )
#'   ) %>%
#'   ggplot(
#'     aes(
#'       x = case_age,
#'       y = contact_age,
#'       fill = probability
#'     )
#'   ) +
#'   facet_wrap(~setting) +
#'   geom_tile() +
#'   scale_fill_viridis() +
#'   coord_fixed() +
#'   theme_minimal() +
#'   theme(
#'     axis.text = element_text(angle = 45, hjust = 1)
#'   )
#' }
"eyre_transmission_probabilities"
