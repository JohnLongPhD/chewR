#' Run the chewR masticatory performance pipeline on a folder of gum images
#'
#' @param image_dir Directory containing input images (default = current working directory)
#' @param protocol  "chew" (default) or "fixed"
#' @param output_excel_path Path to save the Excel summary
#' @param output_plot_dir   Base directory to save outputs
#' @param auto_crop If TRUE, auto-crops around gum before analysis
#' @param save_analysis_images If TRUE, saves the exact images used for analysis
#' @param analysis_image_dir Where analysis images are written (default: output_plot_dir/pipeline_chew_plots)
#' @param save_pixels Save pixel-level CSVs (gz) per analysis image
#' @param autocrop_args list of args forwarded to gum_autocrop_file()
#' @export
run_chewr_pipeline <- function(
    image_dir            = getwd(),
    protocol             = "chew",
    output_excel_path    = "pipeline_results.xlsx",
    output_plot_dir      = "pipeline_plots",
    auto_crop            = TRUE,
    save_analysis_images = TRUE,
    analysis_image_dir   = file.path(output_plot_dir, "pipeline_chew_plots"),
    save_pixels          = FALSE,
    autocrop_args        = list()
) {
  if (!dir.exists(image_dir)) stop("Image directory does not exist: ", image_dir)
  message("Using image directory: ", normalizePath(image_dir))

  files <- list.files(
    image_dir,
    pattern = "\\.(png|jpg|jpeg|tif|tiff)$",
    full.names = TRUE,
    ignore.case = TRUE
  )

  if (!length(files)) stop("No images found in: ", image_dir)

  if (!dir.exists(output_plot_dir)) dir.create(output_plot_dir, recursive = TRUE)
  if (isTRUE(save_analysis_images) && !dir.exists(analysis_image_dir)) {
    dir.create(analysis_image_dir, recursive = TRUE)
  }

  pixels_dir <- NULL
  if (isTRUE(save_pixels)) {
    pixels_dir <- file.path(output_plot_dir, "pixel_csv")
    dir.create(pixels_dir, recursive = TRUE, showWarnings = FALSE)
  }

  message("Processing ", length(files), " image(s)...")

  # helper: create the exact image that WILL be analyzed (cropped or original)
  prep_for_analysis <- function(f) {
    stem <- tools::file_path_sans_ext(basename(f))

    if (isTRUE(save_analysis_images)) {
      if (isTRUE(auto_crop)) {
        out_path <- file.path(analysis_image_dir, paste0(stem, "_CROP.png"))
        ok <- TRUE
        msg <- NULL

        call_args <- utils::modifyList(
          list(infile = f, outfile = out_path),
          autocrop_args
        )

        tryCatch({
          invisible(do.call(gum_autocrop_file, call_args))
        }, error = function(e) {
          ok <<- FALSE
          msg <<- e$message
        })

        if (ok && file.exists(out_path)) {
          message("  ✓ CROPPED -> ", basename(out_path))
          return(out_path)
        } else {
          warning(
            "Auto-crop failed on ",
            basename(f),
            ": ",
            msg,
            " — using ORIGINAL copy."
          )
          fallback <- file.path(analysis_image_dir, basename(f))
          file.copy(f, fallback, overwrite = TRUE)
          message("  → ORIGINAL -> ", basename(fallback))
          return(fallback)
        }
      } else {
        out_path <- file.path(analysis_image_dir, basename(f))
        file.copy(f, out_path, overwrite = TRUE)
        message("  (no crop) ORIGINAL -> ", basename(out_path))
        return(out_path)
      }
    } else {
      if (isTRUE(auto_crop)) {
        call_args <- utils::modifyList(
          list(infile = f, outfile = NULL),
          autocrop_args
        )

        tmp <- tryCatch({
          do.call(gum_autocrop_file, call_args)
        }, error = function(e) {
          warning(
            "Auto-crop failed on ",
            basename(f),
            ": ",
            e$message,
            " — using original."
          )
          f
        })

        return(tmp)
      } else {
        return(f)
      }
    }
  }

  # process
  results_list <- lapply(files, function(f) {
    message("Processing: ", f)
    f_proc <- prep_for_analysis(f)

    df <- tryCatch(
      process_gum_image(
        file              = f_proc,
        white_dist_thresh = 0.85,
        protocol          = protocol,
        auto_crop         = FALSE
      ),
      error = function(e) {
        warning("Failed to process ", basename(f_proc), ": ", e$message)
        NULL
      }
    )

    if (!is.null(df) && isTRUE(save_pixels)) {
      stem <- tools::file_path_sans_ext(basename(f_proc))
      out_csv <- file.path(pixels_dir, paste0(stem, "_pixels.csv.gz"))
      utils::write.table(
        df,
        gzfile(out_csv),
        sep = ",",
        row.names = FALSE,
        col.names = TRUE,
        quote = FALSE
      )
    }

    df
  })

  pixel_df <- do.call(rbind, results_list)
  if (is.null(pixel_df) || nrow(pixel_df) == 0) {
    warning("No valid results produced.")
    return(NULL)
  }

  # summaries (safe for Excel)
  summary_df <- dplyr::as_tibble(pixel_df) |>
    dplyr::group_by(Name, Chews, Side) |>
    dplyr::summarise(
      H_SD = stats::sd(Hue, na.rm = TRUE),
      n_pixels = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      chewr_raw_score = H_SD,
      chewr_masticatory_performance_score = 2 * ((295 - H_SD) / 295) - 0.79
    ) |>
    dplyr::arrange(as.numeric(Chews), Name, Side)

  summary_combined <- dplyr::as_tibble(pixel_df) |>
    dplyr::group_by(Name, Chews) |>
    dplyr::summarise(
      H_SD_combined = stats::sd(Hue, na.rm = TRUE),
      n_pixels = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      chewr_raw_score = H_SD_combined,
      chewr_masticatory_performance_score = 2 * ((295 - H_SD_combined) / 295) - 0.79
    ) |>
    dplyr::arrange(as.numeric(Chews), Name)

  if (!requireNamespace("writexl", quietly = TRUE)) {
    stop("Package 'writexl' is required to save Excel output.")
  }

  summary_by_side_export <- summary_df |>
    dplyr::select(
      ID = Name,
      Chews,
      side = Side,
      n_pixels,
      chewr_raw_score,
      chewr_masticatory_performance_score
    )

  summary_combined_export <- summary_combined |>
    dplyr::select(
      ID = Name,
      Chews,
      n_pixels,
      chewr_raw_score,
      chewr_masticatory_performance_score
    )

  writexl::write_xlsx(
    list(
      summary_sides_combined = summary_combined_export,
      summary_by_side = summary_by_side_export
    ),
    path = output_excel_path
  )

  message("Summary Excel written to: ", output_excel_path)

  invisible(list(
    summary = summary_df,
    summary_combined = summary_combined,
    analysis_image_dir = if (isTRUE(save_analysis_images)) analysis_image_dir else NULL,
    pixels_dir = pixels_dir
  ))
}
