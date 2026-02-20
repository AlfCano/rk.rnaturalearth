# rk.rnaturalearth: Easy Choropleth Maps for RKWard

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.rnaturalearth/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.rnaturalearth/actions/workflows/lintr.yml)

**rk.rnaturalearth** is a user-friendly wrapper for the `rnaturalearth`, `sf`, and `ggspatial` packages within RKWard. It allows users to generate high-quality administrative Choropleth maps (heat maps based on regions) without needing complex GIS knowledge or shapefile management.

Simply select a country, link your data, and add professional map elements like north arrows and scale bars in seconds.

## 🚀 Features

### 1. Instant Choropleth Maps
*   **Built-in Shapefiles:** No need to download `.shp` files manually. The plugin fetches administrative boundaries (states/provinces) automatically via `rnaturalearth`.
*   **Country Support:** Pre-configured for major countries (Mexico, USA, Brazil, Spain, etc.) with a custom option for any country supported by Natural Earth.
*   **Automatic Joining:** Seamlessly merges your data frame with map data based on region names.

### 2. Professional Cartography Elements (`ggspatial`)
*   **North Arrows:** Add "N" arrows with multiple styles (Classic, Fancy, Minimal) and position them anywhere on the plot.
*   **Scale Bars:** Automatically calculated scale bars (km/miles) to provide spatial context.
*   **Smart Labeling:** Add region names with collision detection (`check_overlap`) to prevent cluttered text.

### 3. Data Helper: Region Name Extractor
*   **Fix Data Mismatches:** One of the hardest parts of mapping is spelling (e.g., "Ciudad de México" vs "Distrito Federal").
*   **Utility Tool:** Includes a dedicated component to extract the *exact* official names used by the map engine into a data frame, so you can clean your data before plotting.

## 📦 Installation

To install this plugin in RKWard, copy and run the following code in your R Console:

```R
# install.packages("devtools")
local({
  require(devtools)
  install_github("AlfCano/rk.rnaturalearth", force = TRUE)
})
```

**Note on System Dependencies:**
This plugin relies on the `sf` package. On Linux (Ubuntu/Debian), you may need to install system libraries first:
`sudo apt-get install libudunits2-dev libgdal-dev libgeos-dev`

## 🌍 Internationalization

This plugin is fully localized and automatically adapts to the language settings of your RKWard installation.

**Supported Languages:**
*   🇺🇸 **English** (Default)
*   🇪🇸 **Spanish** (`es`)
*   🇫🇷 **French** (`fr`)
*   🇩🇪 **German** (`de`)
*   🇧🇷 **Portuguese** (Brazil) (`pt_BR`)

If your system language is not listed, the interface will default to English.

## 💻 Usage

Once installed, the tools are organized under:

**`Plots` -> `Maps`**

1.  **Choropleth Map:** The main visualization interface.
2.  **Get Map Names:** The utility to check official region spellings.

## 🎓 Quick Start Examples

### Example 1: Creating a Map of Mexico
**Scenario:** We want to visualize random "Satisfaction Scores" for every state in Mexico.

**A. Data Preparation (Run in Console):**
First, let's create a synthetic dataset.
```R
library(rnaturalearth)
library(dplyr)

# 1. Get the list of states to ensure perfect matching
mx_geo <- ne_states(country = "Mexico", returnclass = "sf")

# 2. Create random data
set.seed(123)
my_mexico_data <- data.frame(
  StateName = mx_geo$name,
  Score = runif(nrow(mx_geo), min = 50, max = 100)
)
```

**B. Plugin Settings (Choropleth Map):**
*   **Tab: Data & Location**
    *   **Select Country:** `Mexico`
    *   **Data Frame:** `my_mexico_data`
    *   **Region Name Column:** `StateName`
    *   **Value Column:** `Score`
*   **Tab: Appearance**
    *   **Color Palette:** `Magma`
    *   **Map Title:** `Satisfaction by State`
*   **Tab: Map Elements**
    *   **North Arrow:** Checked (Position: Top Left, Style: Fancy)
    *   **Scale Bar:** Checked (Position: Bottom Left)
    *   **Show Region Labels:** Checked (Size: 3)

---

### Example 2: Handling Custom Countries (Spain)
**Scenario:** You have data for Spain but aren't sure if the map uses "Cataluña" or "Catalonia".

**A. Use the "Get Map Names" Component:**
1.  Open **Plots -> Maps -> Get Map Names**.
2.  Select **Spain**.
3.  Save the object as `spain_ref`.
4.  Click **Submit**.
5.  Check the output in RKWard to see the `name` column (e.g., it might list "Cataluña" or "Catalonia" depending on the version).

**B. Plotting:**
```R
# Assuming we found the names use Spanish spelling
spain_data <- data.frame(
  Region = c("Madrid", "Cataluña", "Andalucía", "Galicia"),
  Population_Millions = c(6.6, 7.5, 8.4, 2.7)
)
```
*   **Plugin Settings:** Select Country `Spain`, Map `Region` column, and select `Viridis` palette. Note that regions not in your data (like Valencia) will appear in gray (NA).

## 🛠️ Dependencies

This plugin relies on the following R packages:
*   `rnaturalearth` (Map data source)
*   `sf` (Simple Features for spatial handling)
*   `ggplot2` (Plotting engine)
*   `ggspatial` (North arrows and scales)
*   `viridis` (Color blindness-friendly palettes)
*   `dplyr` (Data manipulation)

## ✍️ Author & License

*   **Author:** Alfonso Cano (<alfonso.cano@correo.buap.mx>)
*   **License:** GPL (>= 3)
