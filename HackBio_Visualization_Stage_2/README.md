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
