#' Summarize hue standard deviation per subject and side
#'
#' @param df Data frame with Hue, Name, Chews, and Side
#'
#' @return Summary data frame with H_SD by Name, Chews, and Side
#' @export
summarize_hue_by_side <- function(df) {
  grouping_vars <- c("Name")
  if ("Chews" %in% names(df) && any(!is.na(df$Chews))) {
    grouping_vars <- c(grouping_vars, "Chews")
  }
  if ("Side" %in% names(df) && any(!is.na(df$Side))) {
    grouping_vars <- c(grouping_vars, "Side")
  }

  df %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_vars))) %>%
    dplyr::summarise(H_SD = round(sd(Hue, na.rm = TRUE), 4), .groups = "drop") %>%
    dplyr::arrange(dplyr::across(dplyr::all_of(grouping_vars)))
}
