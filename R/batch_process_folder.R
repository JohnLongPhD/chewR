#' Batch process all gum images in a folder
#'
#' @param input_dir Folder containing image files
#' @param output_dir Folder to save plots
#' @param protocol Either "chew" or "fixed" (default = "chew")
#'
#' @return A data frame summarizing H_SD per image (per side)
#' @export
batch_process_folder <- function(input_dir = ".", output_dir = "plots", protocol = "chew") {
  image_files <- list.files(input_dir, pattern = "\\.(png|jpg)$", full.names = TRUE)

  all_results <- list()

  for (file in image_files) {
    cat("Processing:", file, "\n")
    img_data <- process_gum_image(file, protocol = protocol)

    if (!is.null(img_data)) {
      summary_row <- summarize_hue_by_side(img_data)
      plot_filtered_image(img_data, output_dir)
      all_results[[length(all_results) + 1]] <- summary_row
    }
  }

  dplyr::bind_rows(all_results)
}
