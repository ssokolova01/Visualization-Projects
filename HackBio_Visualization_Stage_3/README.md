# Cell Type Snapshot Explorer

**An interactive Shiny web application for exploring marker genes in a simulated single-cell RNA-seq dataset.**

**Live app:** https://svetlana--sokolova.shinyapps.io/Shiny_Cell_Types_Snapshot/

**Created as part of the HackBio Data Visualization in Bio (vizbio) bioinformatics internship (Stage 3).**

--------------------------------------------------------------------------------------------------------------

## The task

**Cell Type Snapshot Explorer (Shiny, minimal scRNA-seq)**

Build a Shiny web application that helps a user explore which genes best characterize a selected cell type in a simulated single-cell RNA-seq dataset, and visualize the strongest marker signal on a UMAP embedding. The app must be reproducible from the provided CSV files and produce the same outputs every time.

The finished app must include:

* A dropdown selector to choose a cell type
* A UMAP scatter plot of all cells, coloured by cell type before a selection is made, and by the expression of an automatically chosen "best marker gene" once a cell type is selected
* A table of per-gene statistics for the selected cell type: `det_in`, `det_out`, `mean_in`, `mean_out`, `diff`
* A text output stating the selected cell type, the marker gene used for colouring, and that gene's `diff` value
* It must run locally via `shiny::runApp()` with no manual steps beyond placing the data files in the expected folder

The marker gene rule was fixed by the brief: **maximum `diff`, with maximum `det_in` as the tie-breaker.** 

Four helper functions (`t_col`, `scale_0_100`, `compute_gene_stats`, `pick_marker_gene`) were supplied as required boilerplate.

---

## Repository structure

```r
HackBio_Visualization_Stage_3/
├── README.md
├── figures/
│   ├── All_Cell_Types_View_R.png
│   └── B_Cell_Selected_View_R.png
└── Shiny_Cell_Types_Snapshot/
    ├── app.R
    ├── cell_metadata.csv
    ├── expression_matrix.csv
    └── umap_coordinates.csv
```

Shiny requires `app.R` and the data files to sit in the same folder, so they are kept together rather than split into `scripts/` and `data/` folders as in the earlier stages. The app folder is self-contained: downloading it is enough to run the app.

---

## Input data

| File | Description |
|---|---|
| `expression_matrix.csv` | Cells × Genes expression matrix (rows = cells, columns = genes), values already processed |
| `cell_metadata.csv` | `cell_id`, `cell_type` and `cluster` for each cell |
| `umap_coordinates.csv` | `cell_id`, `UMAP_1` and `UMAP_2` coordinates for each cell |

Four cell types are represented: T_cell, B_cell, NK_cell and Monocyte.

Data source: [HackBio 2025 Project Collection](https://github.com/HackBio-Internship/2025_project_collection)

**Checking the files match.** The three files are joined by `cell_id`, so the app does not assume they already match. 

On startup the app keeps only the cells present in all three files and puts them in the same order, so expression values can never be attached to the wrong cells.

---

## How to run

**1. Download the app folder.** `Shiny_Cell_Types_Snapshot` holds everything needed: `app.R` and the three CSV files. Keep the four files together in one folder.

**2. Install the required packages** (once):

```r
install.packages(c("shiny", "ggplot2", "dplyr", "DT"))
```

**3. Open `app.R` in RStudio and click Run App.**

Nothing else to set up: the app reads the three CSV files from its own folder, so there are no paths to edit and no data to load by hand.

---

## Screenshots

**All view**. Every cell coloured by cell type. The Overview table displays the top marker gene for each of the four types.

<img src="figures/All_Cell_Types_View_R.png" width="580">

**Single cell type selected**. Example: B_cell, coloured by its marker gene `Gene_10` (diff = 3.1141). Other clusters are greyed out. The per-gene statistics are ranked below. The Overview table is hidden.

<img src="figures/B_Cells_Selected_View_R.png" width="620">

---

## What the app does

Select a cell type from the dropdown menu to see:

* **The text box** with the selected cell type, the best marker gene for that cell type and its `diff` score.
* **A UMAP plot** where only the selected type's cells are coloured, shaded from pale to deep by marker gene expression. All other cells are greyed out.
* **A ranked table** contains per-gene statistics. Genes are sorted by diff in descending order with det_in as the tie-breaker by default, so that the top marker gene sits at the top. The columns are sortable.

With **All** selected: the UMAP shows every cell coloured by cell type; an Overview table lists the top marker gene for each of the four types.

---

## The gene specificity score

For each gene the app computes a **diff score**:

```
diff = mean_in - mean_out
```

* `mean_in` is average expression across cells of the selected cell type
* `mean_out` is average expression across all other cells

A high `diff` means the gene is expressed much more inside the selected cell type than outside it, which makes it a strong marker.

The table also reports the two detection rates: `det_in`, the proportion of selected-type cells expressing the gene at all (above zero); `det_out`, the same proportion outside the type. 

Mean expression and detection rate answer different questions, "how much" versus "how many" cells, which is why the tie-break uses `det_in` rather than another mean.

**Marker gene selection**

1. Compute `diff` for every gene.
2. Take the gene with the highest `diff`.
3. If several genes tie, take the one with the higher `det_in`.

The rule is deterministic: the same cell type always yields the same marker gene, with no random component anywhere in the app.

---

## App features

* Dropdown selector: All, T_cell, B_cell, NK_cell, Monocyte.
* UMAP with all clusters coloured by cell type (All) or with single cluster coloured by scaled top marker expression (Selected Cell Type).
* Clusters of unselected cell types drawn in semi-transparent grey behind the selected ones.
* Top marker gene expression rescaled to 0–100, so the colour gradient always spans the gene's full range of expression.
* Gradient colour matched to each cell type's colour from the All view.
* Text box reporting selected cell type, top marker gene and its diff score.
* Cell Type Overview table (All view) listing cell type with their counts, top gene with its mean and diff for each cell type.
* Per-gene statistics table, sortable and searchable, ranked by diff score with det_in as a tie-breaker.
* Custom CSS header and styled output panels.

---

## Conceptual reasoning

**How UI and server are connected**

The app follows standard Shiny architecture: the UI declares output elements, the server renders them. Three reactive expressions sit between them and update automatically whenever the cell type selection changes:

| Reactive | Returns | Used by |
|---|---|---|
| `gene_stats()` | Per-gene statistics for all genes in the selected type | the gene table and `marker_gene()` |
| `marker_gene()` | The name of the best marker gene | the UMAP colouring and `marker_diff()` |
| `marker_diff()` | That gene's diff value | the text box underneath the application title box |

Each reactive is computed once per change and its result reused by everything downstream, rather than each output recalculating the same statistics independently. 

This chain means one dropdown change propagates to all three outputs on its own.

**Why `renderDT()` rather than `renderTable()`**

The per-gene table holds one row for every gene in the dataset (50 in the provided data), far too many to read at a glance. `renderDT()` from the **DT** package adds pagination, column sorting and a search box, so a user can look up a specific gene or re-rank by detection rate instead of scrolling. The small four-row overview table uses the plain `renderTable()`, where that machinery would only add clutter.

**Why scale marker expression to 0–100**

Different marker genes have different raw expression ranges. Scaling each to 0–100 means the colour gradient always spans the full range of whatever gene is being shown, so the spatial pattern stays readable when switching between cell types. The trade-off is that colour shows relative expression within the selected gene, not an absolute value comparable across genes.

**Why two different UMAP colourings**

The two views answer different questions. The All-Cell-Type view colours by cell type with `scale_colour_manual()`, showing how the clusters sit relative to each other. The Selected-Cell-Type view colours the selected cells by marker expression with `scale_colour_gradient()`, showing how strongly the marker is expressed within that population. Greying out unselected cells with the `t_col()` helper keeps the surrounding clusters visible for context without competing for attention.

The gradient runs from a light version of each cell type's colour to its full-strength version, so the Selected-Cell-Type view stays visually linked to the type's colour in the All-Cell-Type view.

**Why draw unselected cells first**

`plot_df` is ordered by `is_selected` before plotting, so unselected cells are drawn first and the selected ones land on top. Without this, grey background points would be drawn over the coloured cells the plot is meant to show.

**Why custom CSS inside the UI**

Styling is written directly into the UI with `tags$head(tags$style(HTML(...)))` rather than in a separate `www/style.css` file. This keeps the whole app in a single `app.R`, which matches the brief's requirement that it runs after placing only the data files in the folder, and means nothing can be lost when deploying.

**Reproducibility**

The app reads its three CSV files from the working folder, and marker selection is fully deterministic. Restarting R and re-running the app display the same marker gene, the same plots and the same tables. 

This check is required by the brief's final step.

---

## Tools

| Package | Use |
|---------|-----|
| `shiny` | App framework: UI, server, reactivity |
| `ggplot2` | UMAP scatter plots |
| `dplyr` | Gene ranking and row filtering |
| `DT` | Interactive per-gene statistics table |

---

*Created as part of the HackBio Data Visualization in Bio (vizbio) bioinformatics internship (Stage 3).*
