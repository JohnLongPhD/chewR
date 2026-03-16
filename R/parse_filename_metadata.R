#' Parse filename metadata for subject, chews, and side
#'
#' Acceptable file names:
#' protocol = "chew"  -> ID_chews_side
#'   examples: 1_5chews_side1, 12_20chews_side2
#'
#' protocol = "fixed" -> ID_side
#'   examples: 1_side1, 2_side2, 12_side1
#'
#' Notes:
#' - ID must be numeric only.
#' - Side must be side1 or side2 (case-insensitive).
#' - Optional trailing suffix is allowed (for example: _CROP).
#' - File extensions can be .png, .jpg, .jpeg, .tif, .tiff.
#'
#' @param filename Image filename, with extension
#' @param protocol Either "chew" or "fixed"
#' @return list(name, chews, side) or NULL if no match
#' @export
parse_filename_metadata <- function(filename, protocol = "chew") {
  base <- tools::file_path_sans_ext(basename(filename))
  base <- trimws(base)

  if (protocol == "chew") {
    pat <- "(?i)^(\\d+)_(\\d+)chews?_(side[12])(?:[_-].+)?$"
    m <- stringr::str_match(base, pat)
    if (any(is.na(m))) return(NULL)

    name  <- m[2]
    chews <- as.numeric(m[3])
    side  <- tolower(m[4])

  } else if (protocol == "fixed") {
    pat <- "(?i)^(\\d+)_(side[12])(?:[_-].+)?$"
    m <- stringr::str_match(base, pat)
    if (any(is.na(m))) return(NULL)

    name  <- m[2]
    side  <- tolower(m[3])
    chews <- 20

  } else {
    stop("Unknown protocol: ", protocol)
  }

  list(name = name, chews = chews, side = side)
}
