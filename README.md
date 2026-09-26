# Visualization Projects

Bioinformatics data visualization in R, produced during the HackBio Data Visualization in Bio (vizbio) internship.

The internship runs from a first R script and a technical writing piece, through exploratory visualization of independent datasets, to the reproduction of a published seven-panel figure and an interactive Shiny web application.

---

## Contents

| Stage | Project | What it covers |
|---|---|---|
| **0** | [Technical Writing and First Steps in R](HackBio_Visualization_Stage_0/) | An article on visualization for healthcare translation. First R script using lists and string handling. |
| **1** | [Functions, Loops and Input Validation](HackBio_Visualization_Stage_1/) | A GC content calculator and a protein molecular weight calculator: both are reusable functions with input validation. |
| **2** | [Data Visualization in R](HackBio_Visualization_Stage_2/) | Exploratory visualization of independent datasets. Reproduction of a seven-panel figure from a 2025 *Nature Communications* paper. |
| **3** | [Cell Type Snapshot Explorer](HackBio_Visualization_Stage_3/) | An interactive Shiny web application for exploring marker genes, deployed on shinyapps.io. |

Each stage folder has its own README covering the task, the data, the code and the reasoning behind each design decision.

---

## Plot types

Across the two visualization stages: boxplots, scatter and volcano plots, quadrant plots, clustered and annotated heatmaps, pathway enrichment heatmaps, correlation matrices, bubble plots, stacked bar charts, kernel density plots, directed network graphs, multi-panel figure assembly.

## Tools

`ggplot2` · `ComplexHeatmap` · `pheatmap` · `igraph` · `shiny` · `DT` · `dplyr` · `tidyr` · `readxl` · `patchwork` · `cowplot`

---

## Datasets

- **Gene expression and differential expression results** (HBR vs UHR) — provided by HackBio · Stage 2
- **Breast Cancer Wisconsin (Diagnostic) Dataset** · Stage 2
- **RNA kinetics during *Salmonella* infection** — Xiong, Z., Wu, R., Wang, Y. et al. *scIVNL-seq resolves in vivo single-cell RNA dynamics of immune cells during Salmonella infection.* Nat Commun 16, 7937 (2025). https://doi.org/10.1038/s41467-025-63155-1 · Stage 2
- **Simulated single-cell RNA-seq dataset** (expression matrix, cell metadata, UMAP coordinates) — provided by HackBio · Stage 3

---

*All work was completed as part of the HackBio Data Visualization in Bio (vizbio) bioinformatics internship.*

