#' Write chewing efficiency summary to Excel
#'
#' @param df_chewing_efficiency A data frame of summarized hue values (including H_SD)
#' @param filename Output Excel file name
#'
#' @export
write_hsd_to_excel <- function(df_chewing_efficiency, filename = "chewing_efficiency.xlsx") {
  writexl::write_xlsx(df_chewing_efficiency, filename)
}
