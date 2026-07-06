# chewR

`chewR` is an R package to compute masticatory performance metrics from scanned gum images using hue-based image analysis.

## What the package does

`chewR` can:

- auto-crop each gum image to the gum region
- extract pixel-level hue information from filtered images
- summarize hue variability by side and across sides
- compute:
  - `chewr_raw_score`
  - `chewr_masticatory_performance_score`
- write an Excel workbook with two output tabs:
  1. `summary_sides_combined`
  2. `summary_by_side`

## Supported image formats

`chewR` accepts these image file types:

- `.png`
- `.jpg`
- `.jpeg`
- `.tif`
- `.tiff`

File matching is case-insensitive.

Use png if possible.

## Filename conventions

### 1. Chew protocol

Use this when filenames include the number of chews.

Accepted format:
- `1_5chews_side1.png`
- `1_5chews_side2.png`
- `2_20chews_side1.png`

Here, 1 refers to the **participant ID**

The next string of text after the underscore refers to the number of chewing cycles, 

The final text after the second underscore refers to the front or back or the scan (side 1 and side 2)

Rules:

- `ID` must be numeric only
- `side` must be `side1` or `side2`
- `chews` must be numeric

### 2. Fixed protocol

Use this when filenames do **not** include chew count.

Accepted format:
- `1_side1.png`
- `1_side2.png`
- `2_side1.jpg`

Here, 1 refers to the **participant ID**

The final string of text after the underscore refers to the front of back of the scan (side 1 and side 2)

Rules:

- `ID` must be numeric only
- `side` must be `side1` or `side2`
- `Chews` is automatically assigned as `20`

### Examples that are rejected

These formats are not accepted:

- `PSU12_20chews_side1.jpg`
- `ID_3_5chews_side2.png`
- `PSU12_side1.jpg`

## Installation

Install `chewR` from GitHub:

```r
install.packages("devtools")
install.packages("remotes")

devtools::install_github("JohnLongPhD/chewR")
```

Then load the package:

```r
library(chewR)
```

### If installation fails

If the installation above does not successfully install all required dependencies, manually install the required packages:

```r
install.packages(c(
  "dplyr",
  "imager",
  "colorspace",
  "magrittr",
  "stringr",
  "writexl"
))

install.packages("BiocManager")
BiocManager::install("EBImage")
```

Then reinstall `chewR`:

```r
devtools::install_github("JohnLongPhD/chewR")
```

## Basic workflow

1. Scan all gum images.
2. Save all images into a single folder.
3. Name the files using either the **chew** or **fixed** convention.
4. Set that folder as your R working directory.
5. Load the package.
6. Run the pipeline.
7. Open the Excel file and review the results.

## Example: chew protocol

```r
library(chewR)

#set your working directory to the folder that contains the images
setwd("C:/path/to/your/image_folder") 

pipeline_results <- run_chewr_pipeline(
  protocol             = "chew",
  output_excel_path    = "chewR_results.xlsx",
  output_plot_dir      = "chewR_plots",
  auto_crop            = TRUE,
  save_analysis_images = TRUE
)

#see the excel file in your working directory for the masticatory performance variables
```

## Example: fixed protocol

```r
library(chewR)

#set your working directory to the folder that contains the images
setwd("C:/path/to/your/image_folder")

pipeline_results <- run_chewr_pipeline(
  protocol             = "fixed",
  output_excel_path    = "chewR_results.xlsx",
  output_plot_dir      = "chewR_plots",
  auto_crop            = TRUE,
  save_analysis_images = TRUE
)

#see the excel file in your working directory for the masticatory performance variables
```

## Pipeline arguments

In both protocols, run `run_chewr_pipeline()` and adjust the following arguments as needed:

- **protocol = "chew" or "fixed"**  
  - **chew**: participants chewed gum a specified number of times  
  - **fixed**: participants chewed one standardized sample of gum  

- **output_excel_path**  
  The name of the Excel spreadsheet that is generated once all images have been analyzed.

- **output_plot_dir**  
  The name of the folder that will contain the images used in the analysis.

- **auto_crop = TRUE or FALSE**  
  - **TRUE**: automatically crop the gum region before analysis if images have not been manually cropped  
  - **FALSE**: use this if images have already been manually cropped  

- **save_analysis_images = TRUE or FALSE**  
  - **TRUE**: saves the images used for analysis  
  - **FALSE**: does not save the images used for analysis



## Main outputs

Running `run_chewr_pipeline()` produces:

- an Excel file, such as `chewR_results.xlsx`
- an output folder, such as `chewR_plots`
- cropped analysis images if `save_analysis_images = TRUE`

### Excel tabs

#### `summary_sides_combined`

Pooled result across both sides.

The variables:

- `Name`
- `Chews`
- `n_pixels`
- `chewr_raw_score`
- `chewr_masticatory_performance_score`

#### `summary_by_side`

Side-specific result.

The variables:

- `Name`
- `Chews`
- `Side`
- `n_pixels`
- `chewr_raw_score`
- `chewr_masticatory_performance_score`


## Score interpretation

- Use the **summary_sides_combined** output for statistical analyses.

- **chewr_raw_score**  
  The raw score derived from `H_SD`. Lower values indicate **better masticatory performance**, while higher values indicate **worse masticatory performance**.

- **chewr_masticatory_performance_score**  
  A linearly transformed version of the raw score where **higher values indicate better masticatory performance** and **lower values indicate worse masticatory performance**.

- We recommend using **chewr_masticatory_performance_score** when reporting results in abstracts, conference presentations, manuscripts, and publications.

- The chewr_masticatory_performance_score is what you should use for analyses

## If something goes wrong

### Filenames are skipped

Check that filenames:

- use numeric IDs only
- use `side1` or `side2`
- include `5chews`, `10chews`, etc. for chew protocol
- do not include lab-specific prefixes like `PSU` or `ID_`

### No valid results produced

This usually means:

- filenames did not match the required pattern, or
- auto-cropped images could not be parsed because names were changed unexpectedly

## There is a step-by-step tutorial within the "docs" folder, see the PDF file for the tutorial

## Citation

If you use chewR in research, please cite:

Long JW (2026). *chewR: An Open-Source R Package for Quantifying Masticatory Performance*.  
R package version 0.0.1.  
https://github.com/JohnLongPhD/chewR

You can also retrieve the citation directly in R with:

citation("chewR")
