# Stage 2 - Data Visualization in R #

**The main visualization stage of the HackBio Data Visualization in Bio (vizbio) Internship, made up of two separate assignments:**

| | Assignment | Folder |
|---|---|---|
| **1** | Exploratory visualization of independent datasets - gene expression and cancer diagnostics | [Part_1_Independent_Datasets](Part_1_Independent_Datasets/) |
| **2** | Reproduction of a published seven-panel figure - immune cell RNA kinetics | [Part_2_Article_Reproduction](Part_2_Article_Reproduction/) |

**Each folder has its own README covering the datasets, plot features and the reasoning behind each design decision.**

--------------------------------------------------------------------------------------------------------------------------------------------

## Assignment 1 - Independent dataset analysis ##

### Datasets
1. **Gene expression** (heatmap and volcano plot)
- Normalized counts for HBR vs UHR samples
- Differential expression results, chromosome 22
2. **Breast Cancer Wisconsin (Diagnostic)** (correlation, scatter and density plots)

### Brief

**Gene expression analysis**

- **a. Heatmap** - plot a clustered heatmap of the top differentially expressed genes between HBR and UHR samples. Label both genes and samples. Use a colour gradient (e.g. Blues) to indicate expression levels.
- **b. Volcano plot** - plot log2FoldChange vs log10(Padj). Colour points by significance: upregulated green, downregulated orange, not significant grey. Add dashed vertical lines at log2FoldChange = ±1.

**Breast cancer data exploration**

- **c. Scatter plot** - `texture_mean` vs `radius_mean`, coloured by diagnosis (M = malignant, B = benign).
- **d. Correlation heatmap** - correlation matrix of six key features (`radius_mean`, `texture_mean`, `perimeter_mean`, `area_mean`, `smoothness_mean`, `compactness_mean`), plotted with the correlation values annotated.
- **e. Scatter plot** - `compactness_mean` vs `smoothness_mean`, coloured by diagnosis, with gridlines and clear axis labels.
- **f. Density plot** - kernel density estimates of `area_mean` for both diagnoses on the same axis, with a legend and labelled axes.

**Reasoning**

Provide the reasoning behind each conceptual check, justifying the decision at each step.

-----------------------------------------------------------------------------------------------------------------------------------

## Assignment 2 - Article figure reproduction

Reproduction of Figure 2 (panels a–g) from:

> Xiong, Z., Wu, R., Wang, Y. et al. *scIVNL-seq resolves in vivo single-cell RNA dynamics of immune cells during Salmonella infection.* Nat Commun 16, 7937 (2025). https://doi.org/10.1038/s41467-025-63155-1

**Data source:** [hb_stage_2.xlsx](https://github.com/HackBio-Internship/2025_project_collection/raw/refs/heads/main/hb_stage_2.xlsx)

### Brief

**Task 0 - Orientation and data hygiene**

Identify the Figure 2 panels (a–g) in the source paper, inspect the Excel file and map each sheet to a panel. Required packages: `readxl`, `ggplot2`, `pheatmap`, `igraph`. A transparency helper function and a 20-colour HackBio palette (`hb_pal`) were provided for consistent styling.

**Task 1 - Panel 2a: cell-type ratio distributions**
Read sheet `a`. Boxplot of `new_ratio` grouped by `cell_type`, matching label orientation, relative scaling and outlier visibility.

**Task 2 - Panel 2b: half-life vs alpha scatter**
Read sheet `b`. Plot log2(half_life) vs log2(alpha) with vertical and horizontal cutoffs, colour-coded subsets based on thresholds, and labelled exemplar genes (Camp, Ccr2).
*Conceptual checks: why log2? What do the four quadrants mean?*

**Task 3 - Panel 2c: heatmap across cell types and time**
Read sheet `c`. Convert to a matrix, build column annotations for CellType and Time, cluster rows only.
*Conceptual check: why cluster genes but not time?*

**Task 4 - Panel 2d: pathway enrichment heatmap**
Read sheet `d_1`. Pathway names as rownames, no clustering, diverging colour scale centred at zero.
*Conceptual checks: why no clustering here? Why a diverging palette?*

**Task 5 - Panel 2e: bubble plot of kinetic regimes**
Read sheet `e`. Scatter plot with x = half_life, y = alpha, colour = stage, size = count, and two legends (stage by colour, count by size).

**Task 6 - Panel 2f: stacked proportions**
Read sheet `f`. Subset to s00h and s72h, stacked barplot of proportions, fixed y-axis (0–0.3).
*Conceptual check: why stacked instead of side-by-side?*

**Task 7 - Panel 2g: directed cell–cell interaction network**
Read sheet `g`. Convert to an adjacency matrix, build a directed graph, remove zero-weight edges, make edge arrow size proportional to weight, apply a force-directed layout.
*Conceptual checks: why directed? What does edge weight encode biologically?*

**Task 8 - Final assembly**
Arrange all panels into a single figure with consistent colour usage, readable labels and no clipping. Export at publication quality.

**Reasoning**

Provide the reasoning behind each conceptual check in the figure, justifying the decision at each step.

---

## Answers to the conceptual checks

Every conceptual check listed above is answered in the part READMEs, under the **Conceptual reasoning** heading of the relevant plot.

One deliberate deviation from the brief is worth naming here: Task 7 asks for a force-directed layout. Force-directed placement (`layout_with_fr`) was tested, but on a graph this dense (7 nodes with most pairs connected in both directions) it produced heavy edge overlap. Manual coordinates were used instead, to match the reference figure and keep the connection pattern readable. The reasoning is set out in the Panel 2g section.

---

*Created as part of the HackBio Data Visualization in Bio (vizbio) Internship (Stage 2).*


