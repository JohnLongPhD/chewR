#' Write masticatory performance summary to Excel
#'
#' @param df_masticatory_performance A data frame of summarized hue values (including H_SD)
#' @param filename Output Excel file name
#'
#' @export
write_hsd_to_excel <- function(df_masticatory_performance, filename = "masticatory_performance.xlsx") {
  writexl::write_xlsx(df_masticatory_performance, filename)
}
