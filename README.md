# chewR

`chewR` is an R package for processing scanned gum images and summarizing chewing efficiency using hue-based image analysis.

## There is a step-by-step tutorial within the "docs" folder, please see the PDF file for the tutorial

## What the package does

`chewR` can:

- auto-crop each gum image to the gum region
- extract pixel-level hue information from filtered images
- summarize hue variability by side and across sides
- compute:
  - `chewr_raw_score`
  - `chewr_chewing_efficiency_score`
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

- `ID_5chews_side1.png`
- `ID_10chews_side2.jpg`

Examples:

- `1_5chews_side1.png`
- `1_5chews_side2.png`
- `2_20chews_side1.png`

•	Here, 1 refers to the participant ID, 
•	The next string of text after the underscore refers to the number of chews, 
• The final text after the second underscore refers to the front of back of the scan (side 1 and side 2)

Rules:

- `ID` must be numeric only
- `side` must be `side1` or `side2`
- `chews` must be numeric

### 2. Fixed protocol

Use this when filenames do **not** include chew count.

Accepted format:

- `ID_side1.png`
- `ID_side2.jpg`

Examples:

- `1_side1.png`
- `1_side2.png`
- `2_side1.jpg`

•	Here, 1 refers to the participant ID, 
•	The final string of text after the underscore refers to the front of back of the scan (side 1 and side 2)

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

### Install required packages

```r
install.packages(c("devtools", "dplyr", "imager", "colorspace", "magrittr", "stringr", "writexl"))
install.packages("BiocManager")
BiocManager::install("EBImage")
```

### Install `chewR` from GitHub

```r
install.packages("devtools")
devtools::install_github("JohnLongPhD/chewR")
```

Then load the package:

```r
library(chewR)
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

setwd("C:/path/to/your/image_folder")

pipeline_results <- run_chewr_pipeline(
  protocol             = "chew",
  output_excel_path    = "chewR_results.xlsx",
  output_plot_dir      = "chewR_plots",
  auto_crop            = TRUE,
  save_analysis_images = TRUE
)

pipeline_results
```

## Example: fixed protocol

```r
library(chewR)

setwd("C:/path/to/your/image_folder")

pipeline_results <- run_chewr_pipeline(
  protocol             = "fixed",
  output_excel_path    = "chewR_results.xlsx",
  output_plot_dir      = "chewR_plots",
  auto_crop            = TRUE,
  save_analysis_images = TRUE
)

pipeline_results
```

#In both formats, run the run_chewr_pipeline and these are the various modifications:
•	protocol = “chew” or “fixed” 
  o	Chew = you had participants chew different number of times 
  o	Fixed = you had participants chew one sample of gum 
  
•	output_excel_path = the name of your excel spreadsheet that is generated once all your images have been analyzed

•	output_plot_dir = the name of the folder that will contain the images used in the analysis 

•	auto_crop = “TRUE” or “FALSE”
  o	Run true if you want your images to be auto cropped for analysis and if you have not manually cropped your images
  o	Run false if your images have already been cropped
•	save_analysis_images = “TRUE” or “FALSE”
  o	Run true if you want your images to be saved that were used for analysis 
  o	Run false if you don’t want the images that were used for analysis to be saved



## Main outputs

Running `run_chewr_pipeline()` produces:

- an Excel file, such as `chewR_results.xlsx`
- an output folder, such as `chewR_plots`
- cropped analysis images if `save_analysis_images = TRUE`

### Excel tabs

#### `summary_sides_combined`

Pooled result across both sides.

Common columns:

- `Name`
- `Chews`
- `H_SD_combined`
- `n_pixels`
- `chewr_raw_score`
- `chewr_chewing_efficiency_score`

#### `summary_by_side`

Side-specific result.

Common columns:

- `Name`
- `Chews`
- `Side`
- `H_SD`
- `n_pixels`
- `chewr_raw_score`
- `chewr_chewing_efficiency_score`

## Score interpretation
• Use the summary_sides_combined data for analyses
•	chewr_raw_score is the raw variable based on the H_SD where lower values indicate better chewing and higher values indicate worse chewing 
•	chewr_chewing_efficiency_score is the transformed variable where it is linearly transformed so that lower values indicate worse chewing and higher values indicate better chewing
•	We suggest using the transformed variable when reporting data in abstracts, conferences, manuscripts, etc.

## The chewr_chewing_efficiency score is what you should use for analyses

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

