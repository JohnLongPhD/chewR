#' Summarize hue standard deviation per subject (with optional grouping)
#'
#' @param df A data frame with columns Hue, Name, Chews, and Side
#' @param combine_sides Logical. If TRUE, collapses across Side (default = TRUE)
#'
#' @return A tibble summarizing H_SD per Name (and optionally Chews and Side)
#' @export
summarize_hue <- function(df, combine_sides = TRUE) {
  grouping_vars <- c("Name")

  if ("Chews" %in% names(df) && any(!is.na(df$Chews))) {
    grouping_vars <- c(grouping_vars, "Chews")
  }

  if (!combine_sides && "Side" %in% names(df) && any(!is.na(df$Side))) {
    grouping_vars <- c(grouping_vars, "Side")
  }

  df %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_vars))) %>%
    dplyr::summarise(H_SD = round(sd(Hue, na.rm = TRUE), 4), .groups = "drop") %>%
    dplyr::arrange(dplyr::across(dplyr::all_of(grouping_vars)))
}
