# Cell Type Snapshot Explorer

An interactive Shiny web application for exploring marker genes in a simulated single-cell RNA-seq dataset.

**Live app:** https://svetlana--sokolova.shinyapps.io/Shiny_Cell_Types_Snapshot/

Created as part of the HackBio Data Visualization in Bio (vizbio) bioinformatics internship (Stage 3).

--------------------------------------------------------------------------------------------------------------

## The task

**Cell Type Snapshot Explorer (Shiny, minimal scRNA-seq)**

Build a small Shiny web app that helps a user explore which genes best characterize a selected cell type in a simulated single-cell RNA-seq dataset, and visualize the strongest marker signal on a UMAP embedding. The app must be reproducible from the provided CSV files and produce the same outputs every time.

The finished app must include:

- A dropdown selector to choose a cell type
- A UMAP scatter plot of all cells, coloured by cell type before a selection is made, and by the expression of an automatically chosen "best marker gene" once a cell type is selected
- A table of per-gene statistics for the selected cell type: `det_in`, `det_out`, `mean_in`, `mean_out`, `diff`
- A text output stating the selected cell type, the marker gene used for colouring, and that gene's `diff` value
- It must run locally via `shiny::runApp()` with no manual steps beyond placing the data files in the expected folder

The marker gene rule was fixed by the brief: **maximum `diff`, with maximum `det_in` as the tie-breaker.** Four helper functions (`t_col`, `scale_0_100`, `compute_gene_stats`, `pick_marker_gene`) were supplied as required boilerplate.

---

## Repository structure

```
HackBio_Visualization_Stage_3/
├── README.md
├── figures/
│   ├── app_all_view.png
│   └── app_bcell_view.png
└── Shiny_Cell_Types_Snapshot/
    ├── app.R
    ├── cell_metadata.csv
    ├── expression_matrix.csv
    └── umap_coordinates.csv
```

Shiny requires `app.R` and the data files to sit in the same folder, so they are kept together rather than split into `scripts/` and `data/` folders as in the earlier stages. The app folder is self-contained: downloading it is enough to run the app.

---

















## What the app does

Select a cell type from the dropdown to instantly see:
- Which gene best characterizes that cell type (the marker gene)
- A UMAP plot where selected cells are colored by that marker gene's expression
- A ranked table of all genes with their specificity statistics

When "All" is selected, the UMAP shows all cells colored by cell type, and an overview table shows the top marker gene for each cell type.

## How to run the app

**1. Install required R packages** (only needed once):
```r
install.packages(c("shiny", "ggplot2", "dplyr", "DT"))
```

**2. Place all files in one folder:**
```
shiny_app/
  app.R
  cell_metadata.csv
  expression_matrix.csv
  umap_coordinates.csv
```

**3. Run in R:**
```r
setwd("path/to/your/folder")
shiny::runApp()
```

## Input data

| File | Description |
|---|---|
| `expression_matrix.csv` | Cells x genes expression matrix (rows = cells, columns = genes) |
| `cell_metadata.csv` | Cell ID, cell type, and cluster for each cell |
| `umap_coordinates.csv` | UMAP_1 and UMAP_2 coordinates for each cell |

Data source: [HackBio 2025 Project Collection](https://github.com/HackBio-Internship/2025_project_collection)

## Gene specificity score

For each gene, the app computes a **diff score**:

```
diff = mean_in - mean_out
```

Where:
- `mean_in` = average expression across cells of the **selected** cell type
- `mean_out` = average expression across all **other** cells

A high diff score means the gene is expressed much more in the selected cell type — making it a strong marker.

The table also shows:
- `det_in` — proportion of selected-type cells with expression > 0
- `det_out` — proportion of other cells with expression > 0
- `mean_in` — mean expression inside selected type
- `mean_out` — mean expression outside selected type

## How the marker gene is selected

The marker gene is chosen automatically:

1. Compute `diff` for every gene
2. Select the gene with the **highest diff** value
3. Tie-break: highest **detection rate** (`det_in`) inside the selected type

This ensures the result is always deterministic — the same cell type always produces the same marker gene.

## App features

- Dropdown to select cell type (All / B_cell / Monocyte / NK_cell / T_cell)
- UMAP colored by cell type (All) or scaled marker expression (single type)
- Unselected cells shown in grey when a specific type is chosen
- Marker expression scaled to 0-100 for consistent visualization
- Color gradient matches each cell type's color from the All view
- Text box showing selected cell type, marker gene, and diff score
- Cell Type Overview table (visible on All) showing top gene per type
- Per-gene statistics table ranked by diff score (interactive, searchable)
