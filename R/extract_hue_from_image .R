#' Extract Hue Values from Image Data
#'
#' @param img_df A data frame of filtered RGB pixels with `c.1`, `c.2`, `c.3` columns.
#'
#' @return A numeric vector of hue values.
#' @export
extract_hue_from_image <- function(img_df) {
  rgb_vals <- with(img_df, colorspace::RGB(c.1, c.2, c.3))
  hsv_vals <- as(rgb_vals, "HSV")
  hsv_vals@coords[, 1]
}
