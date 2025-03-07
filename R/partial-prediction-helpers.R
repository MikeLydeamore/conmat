#' Helper functions to create partial predictive plots.
#' 
#' These helper functions exist to make it easier to explore and understand the 
#'   impact of each of the covariates used in the conmat GAM model. These were 
#'   initially developed for the official Journal of Open Source Software paper 
#'   for `conmat`, and have been made available for the user, in case it is of
#'   interest. The relevant excerpt from the paper is included in "details", 
#'   below. How to use the functions is shown in the examples section below.
#' 
#' @details
#' 
#' `conmat` was built to predict at four settings: work, school, home, and 
#'   other. One model is fitted for each setting. Each model fitted is a 
#'   Poisson generalised additive model (GAM) with a log link function, which 
#'   predicts the count of contacts, with an offset for the log of participants. 
#'   The model has six covariates to explain six key features of the 
#'   relationship between ages, and two optional covariates for attendance 
#'   at school or work. The two optional covariates are included depending on 
#'   which setting the model is fitted for.
#'   
#'   Each cell in the resulting contact matrix (after back-transformation of 
#'   the link function), indexed ($i$, $j$), is the predicted number of people 
#'   in age group $j$ that a single individual in age group $i$ will have 
#'   contact with per day. The sum over all age groups $j$ for a particular age 
#'   group $i$ is the predicted total number of contacts per day for each 
#'   individual of age group $i$.
#'   
#'   The six covariates are: (1) $|i-j|$, (2) $|i-j|^{2}$, (3) $i + j$, 
#'   (4) $i \times j$, (5) $\text{max}(i, j)$ and (6) $\text{min}(i, j)$.
#'   
#'   These covariates capture typical features of inter-person contact, where 
#'   individuals primarily interact with people of similar age (the diagonals 
#'   of the matrix), and with grandparents and/or children (the so-called 
#'   'wings' of the matrix). The key features of the relationship between the 
#'   age groups, represented by spline transformations of the six covariates, 
#'   are displayed in the example below for the home setting. The 
#'   spline-transformed $|i-j|$ and $|i-j|^{2}$ terms give the strong diagonal 
#'   lines modelling people generally living with those of similar age and 
#'   the intergenerational effect of parents and (faintly) grandparents with 
#'   children. The spline-transformed $\text{max}(i, j)$ and $\text{min}(i, j)$
#'   terms give the higher rates of at-home contact among younger people of 
#'   similar ages and with their parents. Visualising the partial predictive 
#'   plots for other settings (school, work and other) show patterns that 
#'   correspond with real-life situations.
#'
#' @param ages vector of integer ages
#' @return data frame with 20 columns plus n rows based on expand.grid 
#'   combination of ages. Contains transformed coefficients from ages.
#' @name partial-prediction
#' @noRd
#' @examples
#' fit_home <- polymod_setting_models$home
#' age_grid <- create_age_grid(ages = 1:99)
#' term_names <- extract_term_names(fit_home)
#' term_var_names <- clean_term_names(term_names)
#' age_predictions <- predict_individual_terms(
#'   age_grid = age_grid,
#'   fit = fit_home,
#'   term_names = term_names,
#'   term_var_names = term_var_names
#' )
#' 
#' age_predictions_all_settings <- map_dfr(
#'   .x = polymod_setting_models,
#'   .f = function(x) {
#'     predict_individual_terms(
#'       age_grid = age_grid,
#'       fit = x,
#'       term_names = term_names,
#'       term_var_names = term_var_names
#'     )
#'   },
#'   .id = "setting"
#' )
#' 
#' plot_age_term_settings <- gg_age_terms_settings(age_predictions_all_settings)
#' age_predictions_long <- pivot_longer_age_preds(age_predictions)
#' 
#' library(ggplot2)
#' plot_age_predictions_long <- gg_age_partial_pred_long(age_predictions_long) +
#'   coord_equal() +
#'   labs(
#'     x = "Age from",
#'     y = "Age to"
#'   ) + 
#'   theme(
#'     legend.position = "bottom",
#'     axis.text = element_text(size = 6),
#'     panel.spacing = unit(x = 1, units = "lines")
#'   ) +
#'   scale_x_continuous(expand = c(0,0)) +
#'   scale_y_continuous(expand = c(0,0)) +
#'   expand_limits(x = c(0, 100), y = c(0, 100))
#' 
#' age_predictions_long_sum <- add_age_partial_sum(age_predictions_long)
#' plot_age_predictions_sum <- gg_age_partial_sum(age_predictions_long_sum) + coord_equal() +
#'   labs(x = "Age from",
#'        y = "Age to") +
#'   theme(
#'     legend.position = "bottom"
#'   ) +
#'   scale_x_continuous(expand = c(0,0)) +
#'   scale_y_continuous(expand = c(0,0)) +
#'   expand_limits(x = c(0, 100), y = c(0, 100))
#' 
#' plot_age_term_settings
#' plot_age_predictions_long
#' plot_age_predictions_sum

create_age_grid <- function(ages) {
  age_grid <- expand.grid(
    age_from = ages,
    age_to = ages
  ) |>
    tibble::as_tibble() |>
    # prepare the age data so it has all the right column names
    # that are used inside of `fit_single_contact_model()`
    # conmat::add_symmetrical_features() |>
    add_symmetrical_features() |>
    # this ^^^ does the same as the commented part below:
    # dplyr::mutate(
    #   gam_age_offdiag = abs(age_from - age_to),
    #   gam_age_offdiag_2 = abs(age_from - age_to)^2,
    #   gam_age_diag_prod = abs(age_from * age_to),
    #   gam_age_diag_sum = abs(age_from + age_to),
    #   gam_age_pmax = pmax(age_from, age_to),
    #   gam_age_pmin = pmin(age_from, age_to)
    # ) |>
    # This is to add the school_probability and work_probability columns
    # that are used inside fit_single_contact_model() when fitting the model.
    # conmat::add_modelling_features()
    add_modelling_features()
  
  age_grid
  
}

#' Helper function to extract term names out of GAM fitted model object.
#' 
#' @param fit fitted object for one single conmat model setting. E.g., the 
#'   home setting.
#' @return character vector of term names
#' @noRd
#' @examples
#' extract_term_names(polymod_setting_models$home)
extract_term_names <- function(fit) {
  
  coef_names <- names(fit$coefficients) |>
    stringr::str_remove_all("\\.[^.]*$") |>
    unique() |>
    stringr::str_subset("^s\\(")
  
  coef_names
  
}

#' Clean up GAM term names for use in plotting
#' @param term_names character vector of model term names (e.g., 's(offdiag)').
#' @return names like "offdiag", instead of "s(offdiag)"
#' @noRd
#' @examples
#' extract_term_names(polymod_setting_models$home) |> clean_term_names()
clean_term_names <- function(term_names) {
  
  term_names |>
    stringr::str_remove_all("^s\\(gam_age_") |>
    stringr::str_remove_all("\\)")
  
}

#' 
#' @param age_grid grid of ages from [create_age_grid()]
#' @param fit model fitted object from conmat, e.g., 
#'   `polymod_setting_models$home`.
#' @param term_names terms from model extracted with [extract_term_names()].
#' @param term_var_names Cleaned up term names from model used with 
#'   [clean_term_names()].
#' @return Data frame containing predicted values added to output of 
#'   [create_age_grid()].
#' @noRd
#' @examples
#' fit_home <- polymod_setting_models$home
#' age_grid <- create_age_grid(ages = 1:99)
#' term_names <- extract_term_names(fit_home)
#' term_var_names <- clean_term_names(term_names)
#' age_predictions <- predict_individual_terms(
#'   age_grid = age_grid,
#'   fit = fit_home,
#'   term_names = term_names,
#'   term_var_names = term_var_names
#' )
predict_individual_terms <- function(age_grid, fit, term_names, term_var_names) {
  
  predicted_term <- function(age_grid, fit, term_name, term_var_name){
    predict(object = fit,
            newdata = age_grid,
            type = "terms",
            terms = term_name) |>
      tibble::as_tibble() |>
      stats::setNames(glue::glue("pred_{term_var_name}"))
  }
  
  all_predicted_terms <- purrr::map2_dfc(
    .x = term_names,
    .y = term_var_names,
    .f = function(.x, .y){
      predicted_term(age_grid = age_grid,
                     fit = fit,
                     term_name = .x,
                     term_var_name = .y)
    }
  )
  
  dplyr::bind_cols(age_grid, all_predicted_terms)
  
}

#' Plot all age terms across all settings
#' @param age_predictions_all_settings output from mapped 
#'   `predict_individual_terms`.
#' @return ggplot objects
#' @importFrom ggplot2 ggplot aes geom_tile facet_grid coord_fixed scale_fill_viridis_c theme_minimal facet_wrap labs
#' @noRd
#' @examples
#' library(purrr)
#' fit_home <- polymod_setting_models$home
#' age_grid <- create_age_grid(ages = 1:99)
#' term_names <- extract_term_names(fit_home)
#' term_var_names <- clean_term_names(term_names)
#' age_predictions <- predict_individual_terms(
#'   age_grid = age_grid,
#'   fit = fit_home,
#'   term_names = term_names,
#'   term_var_names = term_var_names
#' )
#' 
#' age_predictions_all_settings <- map_dfr(
#'   .x = polymod_setting_models,
#'   .f = function(x) {
#'     predict_individual_terms(
#'       age_grid = age_grid,
#'       fit = x,
#'       term_names = term_names,
#'       term_var_names = term_var_names
#'     )
#'   },
#'   .id = "setting"
#' )
#' 
#' plot_age_term_settings <- gg_age_terms_settings(age_predictions_all_settings)
#' 
#' plot_age_term_settings
gg_age_terms_settings <- function(age_predictions_all_settings) {
  
  pred_all_setting_longer <- age_predictions_all_settings |>
    tidyr::pivot_longer(
      dplyr::starts_with("pred"),
      names_to = "pred",
      values_to = "value",
      names_prefix = "pred_"
    ) |>
    dplyr::select(age_from,
           age_to,
           value,
           pred,
           setting)
  
  facet_age_plot <- function(data, place){
    data |>
      dplyr::filter(setting == place) |>
      ggplot(aes(x = age_from,
                 y = age_to,
                 fill = value)) +
      geom_tile() +
      facet_grid(setting~pred,
                 switch = "y") +
      coord_fixed() +
      labs(fill = place)
    
  }
  
  p_home <- facet_age_plot(pred_all_setting_longer, "home") + 
    scale_fill_viridis_c()
  p_work <- facet_age_plot(pred_all_setting_longer, "work") + 
    scale_fill_viridis_c(option = "rocket")
  p_school <- facet_age_plot(pred_all_setting_longer, "school") + 
    scale_fill_viridis_c(option = "plasma")
  p_other <- facet_age_plot(pred_all_setting_longer, "other") + 
    scale_fill_viridis_c(option = "mako")
  
  patchwork::wrap_plots(
    p_home,
    p_work,
    p_school,
    p_other,
    nrow = 4
  )
  
}

#' @param age_predictions age predictions
#' @return data frame
#' @noRd
pivot_longer_age_preds <- function(age_predictions) {
  age_predictions |>
    tidyr::pivot_longer(
      dplyr::starts_with("pred"),
      names_to = "pred",
      values_to = "value",
      names_prefix = "pred_"
    )
}

#' @param age_predictions_long age prediction data frame
#' @return ggplot object
#' @noRd
gg_age_partial_pred_long <- function(age_predictions_long) {

  facet_names <- data.frame(
    pred = c("diag_prod", "diag_sum", "offdiag", "offdiag_2", "pmax", "pmin"),
    math_name = c("i x j", "i + j", "|i - j|", "|i - j|^2^", "max(i, j)", "min(i, j)")
  )
  
  age_predictions_long %>%
    dplyr::left_join(facet_names, by = dplyr::join_by("pred")) %>%
    ggplot(
      aes(
        x = age_from,
        y = age_to,
        group = math_name,
        fill = value
      )
    ) +
    facet_wrap(~math_name, ncol = 3) +
    geom_tile() +
    scale_fill_viridis_c(
      name = "log\ncontacts"
    ) +
    theme_minimal()
  
}

#' @param age_predictions_long age prediction data
#' @return data.frame
#' @noRd
add_age_partial_sum <- function(age_predictions_long) {
  
  age_partial_sum <- age_predictions_long |>
    dplyr::group_by(age_from,
             age_to) |>
    dplyr::summarise(
      gam_total_term = exp(sum(value)),
      .groups = "drop"
    )
  
  age_partial_sum
  
}

#' @param age_predictions_long_sum age prediction data
#' @return ggplot object
#' @noRd
gg_age_partial_sum <- function(age_predictions_long_sum) {
  
  ggplot(
    data = age_predictions_long_sum,
    aes(
      x = age_from,
      y = age_to,
      fill = gam_total_term
    )
  ) +
    geom_tile() +
    scale_fill_viridis_c(
      name = "Num.\ncontacts",
      option = "magma",
      limits = c(0, 12)
    ) +
    theme_minimal()
  
}

