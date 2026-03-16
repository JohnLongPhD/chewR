#' Extract Hue from Filtered Image Data
#'
#' Converts RGB to HSV and extracts hue values from an image data frame.
#'
#' @param img_df A data frame with columns c.1, c.2, c.3 (RGB values).
#'
#' @return A numeric vector of hue values (0–1).
#' @importFrom colorspace RGB
#' @importFrom methods as
#' @export
extract_hue <- function(img_df) {
  rgb_vals <- with(img_df, colorspace::RGB(c.1, c.2, c.3))
  hsv_vals <- as(rgb_vals, "HSV")
  hsv_vals@coords[, 1]  # Extract hue
}
