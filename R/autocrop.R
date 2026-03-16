#' Auto-crop gum wafer from a scan (EBImage backend)
#'
#' Uses saturation + optional highlight capping, selects the largest component,
#' pads the bounding box, and writes a cropped image (PNG by default).
#'
#' @param infile  Path to input image (png/jpg/jpeg)
#' @param outfile Path to write the cropped image. If NULL, a temp file is used.
#' @param sat_floor Minimum saturation threshold floor (0–1)
#' @param min_pixels Minimum connected component area in pixels
#' @param pad_frac  Padding fraction of bbox size (0–1)
#' @param cap_highlights If TRUE, exclude very bright pixels (glare)
#' @param highlight_cap  V (value) cutoff to exclude highlights (0–1)
#' @param save_debug If TRUE, writes a mask overlay image (outfile*_mask.png)
#'
#' @return Path to the cropped image (invisible).
#' @keywords internal
gum_autocrop_file <- function(
    infile,
    outfile         = NULL,
    sat_floor       = 0.18,
    min_pixels      = 1200,
    pad_frac        = 0.10,
    cap_highlights  = TRUE,
    highlight_cap   = 0.98,
    save_debug      = FALSE
) {
  if (!requireNamespace("EBImage", quietly = TRUE)) {
    stop("EBImage is required for auto-crop. Install via BiocManager::install('EBImage').")
  }
  
  img <- EBImage::readImage(infile)
  if (EBImage::colorMode(img) != EBImage::Color) img <- EBImage::channel(img, "rgb")
  
  # RGB -> HSV
  r <- EBImage::channel(img, "red")
  g <- EBImage::channel(img, "green")
  b <- EBImage::channel(img, "blue")
  hsv <- grDevices::rgb2hsv(rbind(as.numeric(r), as.numeric(g), as.numeric(b)))
  S <- EBImage::Image(matrix(hsv["s", ], nrow = nrow(img), ncol = ncol(img)), colormode = EBImage::Grayscale)
  
  if (isTRUE(cap_highlights)) {
    V <- EBImage::Image(matrix(hsv["v", ], nrow = nrow(img), ncol = ncol(img)), colormode = EBImage::Grayscale)
  }
  
  # Otsu (with floor)
  otsu_threshold <- function(x, bins = 256) {
    h <- graphics::hist(x, breaks = seq(0, 1, length.out = bins + 1), plot = FALSE)
    p <- h$counts / sum(h$counts); idx <- 0:(bins - 1)
    w0 <- cumsum(p); w1 <- 1 - w0
    m  <- sum(idx * p)
    m0 <- cumsum(idx * p) / pmax(w0, .Machine$double.eps)
    m1 <- (m - cumsum(idx * p)) / pmax(w1, .Machine$double.eps)
    thr_idx <- which.max(w0 * w1 * (m0 - m1)^2)
    (thr_idx - 1) / (bins - 1)
  }
  t_otsu <- otsu_threshold(as.numeric(S))
  thr <- max(sat_floor, t_otsu)
  
  mask <- S > thr
  if (isTRUE(cap_highlights)) mask <- mask & (V < highlight_cap)
  
  # Relax if too sparse
  if (sum(mask) / (nrow(img) * ncol(img)) < 0.001) {
    thr <- max(sat_floor * 0.75, thr * 0.8)
    mask <- S > thr
    if (isTRUE(cap_highlights)) mask <- mask & (V < highlight_cap)
  }
  
  # Clean + label
  mask <- EBImage::fillHull(mask)
  mask <- EBImage::opening(mask, EBImage::makeBrush(7, shape = "disc"))
  mask <- EBImage::closing(mask, EBImage::makeBrush(11, shape = "disc"))
  cc   <- EBImage::bwlabel(mask)
  
  shp <- EBImage::computeFeatures.shape(cc)
  if (nrow(shp) == 0) stop("Auto-crop found no object in: ", infile)
  largest <- as.integer(rownames(shp)[which.max(shp[, "s.area"])])
  if (shp[as.character(largest), "s.area"] < min_pixels) {
    stop("Auto-crop object too small in: ", infile)
  }
  keep <- cc == largest
  
  rows <- which(rowSums(keep) > 0); cols <- which(colSums(keep) > 0)
  rmin <- max(1, min(rows)); rmax <- min(nrow(img), max(rows))
  cmin <- max(1, min(cols)); cmax <- min(ncol(img), max(cols))
  
  h <- rmax - rmin + 1; w <- cmax - cmin + 1
  rpad <- round(pad_frac * h); cpad <- round(pad_frac * w)
  rmin <- max(1, rmin - rpad); rmax <- min(nrow(img), rmax + rpad)
  cmin <- max(1, cmin - cpad); cmax <- min(ncol(img), cmax + cpad)
  
  cropped <- img[rmin:rmax, cmin:cmax, ]
  if (is.null(outfile)) outfile <- tempfile(fileext = ".png")
  EBImage::writeImage(cropped, outfile)
  
  if (isTRUE(save_debug)) {
    outline <- EBImage::dilate(keep, EBImage::makeBrush(3, "diamond"))
    prev <- img; prev[,,1][outline] <- 1
    EBImage::writeImage(prev, sub("\\.(png|jpg|jpeg)$", "_mask.png", outfile, ignore.case = TRUE))
  }
  
  invisible(outfile)
}
