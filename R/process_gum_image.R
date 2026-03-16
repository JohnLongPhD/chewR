#' Process a gum image to extract pixel data
#'
#' @param file Path to the image file (.png or .jpg)
#' @param white_dist_thresh Threshold for filtering out white background (default = 0.85)
#' @param protocol Naming protocol: "chew" (default) or "fixed"
#' @param auto_crop If TRUE, pre-crop around gum using EBImage (default TRUE)
#'
#' @return A data frame of filtered pixels with RGB and HSV values, plus metadata.
#'         Returns NULL if filename doesn't match expected pattern.
#' @importFrom magrittr %>%
#' @export
process_gum_image <- function(file, white_dist_thresh = 0.85, protocol = "chew", auto_crop = TRUE) {

  sat_floor      <- 0.18
  min_pixels     <- 1200
  pad_frac       <- 0.10
  cap_highlights <- TRUE
  highlight_cap  <- 0.98
  save_debug     <- FALSE

  file_to_load <- file
  if (isTRUE(auto_crop)) {
    file_to_load <- tryCatch(
      gum_autocrop_file(
        infile         = file,
        outfile        = NULL,
        sat_floor      = sat_floor,
        min_pixels     = min_pixels,
        pad_frac       = pad_frac,
        cap_highlights = cap_highlights,
        highlight_cap  = highlight_cap,
        save_debug     = save_debug
      ),
      error = function(e) {
        warning("Auto-crop failed on ", basename(file), ": ", e$message, " — using original image.")
        file
      }
    )
  }

  img <- imager::load.image(file_to_load)
  img_df <- as.data.frame(img, wide = "c")

  img_df <- img_df %>%
    dplyr::mutate(white_dist = sqrt((c.1 - 1)^2 + (c.2 - 1)^2 + (c.3 - 1)^2)) %>%
    dplyr::filter(white_dist > white_dist_thresh)

  if (nrow(img_df) == 0) {
    warning(paste("No gum pixels found in", file))
    return(NULL)
  }

  rgb_vals <- with(img_df, colorspace::RGB(c.1, c.2, c.3))
  hsv_vals <- as(rgb_vals, "HSV")
  hues <- hsv_vals@coords[, 1]

  meta <- parse_filename_metadata(file, protocol = protocol)
  if (is.null(meta)) {
    warning(paste("Skipping file due to unrecognized filename format:", file))
    return(NULL)
  }

  img_df$Hue   <- hues
  img_df$Name  <- meta$name
  img_df$Chews <- meta$chews
  img_df$Side  <- meta$side
  img_df$File  <- basename(file)

  return(img_df)
}
