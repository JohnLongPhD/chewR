#' Plot and save the filtered gum pixels from image data
#'
#' @param img_df A data frame output from `process_gum_image()`
#' @param output_dir Directory to save the PNG plot
#'
#' @return Path to saved image
#' @export
plot_filtered_image <- function(img_df, output_dir = "plots") {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  plot_file <- file.path(output_dir, paste0(tools::file_path_sans_ext(img_df$File[1]), "_filtered_plot.png"))

  png(plot_file, width = 800, height = 800)
  plot(
    img_df$x, img_df$y,
    col = rgb(img_df$c.1, img_df$c.2, img_df$c.3),
    pch = 15, asp = 1, axes = FALSE,
    xlab = "", ylab = "", main = paste("Filtered:", img_df$File[1])
  )
  dev.off()

  return(plot_file)
}
