# TASK 0: Install and load packages

#install.packages("readxl")
#install.packages("ggplot2")
#install.packages("pheatmap")
#install.packages("igraph")
#install.packages("dplyr")

# Load libraries
library(readxl)
library(ggplot2)
library(pheatmap)
library(igraph)
library(dplyr)

excel_file <- "dataset/hb_stage_2.xlsx"

###############################################################

# Helper function: Create transparent colors
transparent_color <- function(color, percent = 50, name = NULL) {
  rgb.val <- col2rgb(color)
  t.col <- rgb(rgb.val[1], rgb.val[2], rgb.val[3],
               max = 255,
               alpha = (100 - percent) * 255 / 100,
               names = name)
  invisible(t.col)
}

# HackBio color palette
hb_pal <- c("#4e79a7",
            "#8cd17d",
            "#e15759",
            "#fabfd2",
            "#a0cbe8",
            "#59a14f",
            "#b07aa1",
            "#ff9d9a",
            "#f28e2b",
            "#f1ce63",
            "#79706e",
            "#d4a6c8",
            "#e9e9e9",
            "#ffbe7d",
            "#bab0ac",
            "#9d7660",
            "#d37295",
            "#86bcb6",
            "#362a39",
            "#cd9942")

# Preview the color palette
plot(1:length(hb_pal), 1:length(hb_pal), col = hb_pal, pch = 19, 
     main = "HackBio Color Palette",
     xlab = "", ylab = "")

###########################################################################

# TASK 1: Reproduce panel 2a - Boxplot
# Cell-type ratio distributions

# Read sheet 'a' and convert to data frame
data <- as.data.frame(read_excel(excel_file, sheet = "a"))
data$new_ratio <- as.numeric(data$new_ratio)

# Set cell type order for x-axis
data$cell_type <- factor(data$cell_type, 
                         levels = c("B", "Basophil", "DC", "HSPC", "Macrophage", 
                                    "Monocyte", "Neutrophil", "NK", "Pre B", "T"))

# Assign colors from hb_pal (one per cell type)
box_colors <- c("#4e79a7", "#8cd17d", "#e15759", "#fabfd2", "#a0cbe8", 
                "#59a14f", "#b07aa1", "#ff9d9a", "#f28e2b", "#f1ce63")

# Save to PNG
png("panel_2a_boxplot.png", width = 800, height = 600, res = 150)

par(mar = c(6, 4, 2, 1))  # Bottom, Left, Top, Right margins

# Create boxplot using base R
boxplot(new_ratio ~ cell_type, 
        data = data, 
        col = box_colors, 
        las = 2,           # Rotate x-axis labels vertically
        ylab = "Ratio", 
        xlab = "", 
        ylim = c(0, 0.5),
        outcex = 0.6,      # Outlier dot size
        outpch = 1,        # Outlier dot shape (open circle)
        boxwex = 0.6)      # Box width

dev.off()

#############################################################################

# TASK 2: Reproduce panel 2b - Scatter plot
# Half-life vs alpha-life (kinetic regimes)

# Read sheet 'b'
data_b <- read_excel(excel_file, sheet = "b")

# Calculate log2 transformations
data_b <- data_b %>%
  mutate(
    log2_half_life = log2(half_life),
    log2_alpha = log2(alpha)
  )

# Define cutoff thresholds to divide kinetic regimes into quadrants
half_life_cutoff <- 2.5   # Vertical dashed line
alpha_cutoff <- -3.5      # Horizontal dashed line

# Assign each gene to a quadrant based on cutoffs
data_b <- data_b %>%
  mutate(
    quadrant = case_when(
      log2_half_life <= half_life_cutoff & log2_alpha > alpha_cutoff ~ "upper_left",
      log2_half_life > half_life_cutoff & log2_alpha > alpha_cutoff ~ "upper_right",
      log2_half_life <= half_life_cutoff & log2_alpha <= alpha_cutoff ~ "lower_left",
      log2_half_life > half_life_cutoff & log2_alpha <= alpha_cutoff ~ "lower_right"
    )
  )

# Quadrant colors from hb_pal
quadrant_colors <- c(
  "upper_left" = "#8cd17d",    # Green (Ccr2 quadrant)
  "upper_right" = "#e15759",   # Red
  "lower_left" = "#bab0ac",    # Grey (majority of points)
  "lower_right" = "#4e79a7"    # Blue (Camp quadrant)
)

# Select genes to label on the plot
genes_to_label <- data_b %>%
  filter(cell %in% c("Ccr2", "Camp"))

# Create the scatter plot
plot_2b <- ggplot(data_b, aes(x = log2_half_life, y = log2_alpha, color = quadrant)) +
  geom_point(alpha = 0.5, size = 1) +
  geom_vline(xintercept = half_life_cutoff, linetype = "dashed", color = "black") +
  geom_hline(yintercept = alpha_cutoff, linetype = "dashed", color = "black") +
  geom_text(data = genes_to_label,
            aes(x = log2_half_life, y = log2_alpha, label = cell),
            color = "black",
            size = 8,
            nudge_x = 0.3,
            nudge_y = 0.3) +
  scale_color_manual(values = quadrant_colors) +
  scale_x_continuous(breaks = seq(-1, 5, by = 1)) +
  scale_y_continuous(breaks = seq(-10, 0, by = 2)) +
  labs(x = "log2(Half Life)",
       y = "log2(Alpha)",
       title = "") +
  theme_classic() +
  theme(legend.position = "none",
        panel.border = element_rect(color = "black", fill = NA, linewidth = 1),
        panel.grid = element_blank(),
        axis.ticks.length.y = unit(0.4, "cm"),
        axis.ticks.length.x = unit(0.4, "cm"),
        axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title.x = element_text(size = 16, margin = margin(t = 15)),
        axis.title.y = element_text(size = 16, margin = margin(r = 15)))

print(plot_2b)

ggsave("panel_2b_scatterplot.png", plot_2b, width = 6, height = 6, dpi = 300)

################################################################################

# TASK 3: Reproduce panel 2c - Heatmap with pheatmap
# Temporal structure across immune compartments

# Read sheet 'c'
data_c <- read_excel(excel_file, sheet = "c")

# Set gene names as rownames and convert to numeric matrix
heatmap_matrix_c <- as.data.frame(data_c)
rownames(heatmap_matrix_c) <- heatmap_matrix_c$genes
heatmap_matrix_c <- as.matrix(heatmap_matrix_c[, -1])

# Parse column names to extract CellType and Time annotations
# Column format: "Macrophagen00h", "Monocyten02h", etc.
col_annotations <- data.frame(
  Time = gsub("^.*n", "", colnames(heatmap_matrix_c)),       # Extract time part
  CellType = gsub("n[0-9]{2}h$", "", colnames(heatmap_matrix_c)),  # Extract cell type
  row.names = colnames(heatmap_matrix_c)
)

# Define annotation colors from hb_pal
ann_colors <- list(
  CellType = c(
    "B" = "#fabfd2",
    "Macrophage" = "#b07aa1",
    "Monocyte" = "#8cd17d",
    "Neutrophil" = "#f1ce63",
    "NK" = "#a0cbe8",
    "pDC" = "#f28e2b",
    "T" = "#ff9d9a"
  ),
  Time = c(
    "00h" = "#fabfd2",
    "02h" = "#e15759",
    "06h" = "#a0cbe8",
    "12h" = "#f1ce63",
    "24h" = "#ff9d9a",
    "48h" = "#8cd17d",
    "72h" = "#4e79a7"
  )
)

par(mar = c(4, 4, 2, 1))

graphics.off() 

# Save to PNG
png("panel_2c_boxplot.png", width = 900, height = 1000, res = 150)

# Create the heatmap
pheatmap(
  heatmap_matrix_c,
  color = colorRampPalette(c("white", "lightblue", "steelblue", "darkblue"))(50),
  cluster_rows = TRUE,       # Cluster genes (rows)
  cluster_cols = FALSE,      # Preserve column time order
  show_rownames = FALSE,     # Too many genes to display
  show_colnames = FALSE,     # Column info shown via annotations
  annotation_col = col_annotations,
  annotation_colors = ann_colors,
  main = "",
  fontsize_row = 10,
  fontsize_col = 10,
  annotation_legend = TRUE,
  annotation_names_row = TRUE,
  annotation_names_col = TRUE,
  legend = TRUE,
  fontsize = 14,
  border_color = NA
)

dev.off()

################################################################################

# TASK 4: Reproduce panel 2d - Pathway heatmap
# Pathway enrichment across timepoints

# Read sheet 'd_1'
data_d <- read_excel(excel_file, sheet = "d_1")

# Set pathway names as rownames and convert to numeric matrix
data_d_matrix <- as.data.frame(data_d)
rownames(data_d_matrix) <- data_d_matrix$pathway
pathway_matrix <- as.matrix(data_d_matrix[, -1])

# Create diverging color palette (red = negative, white = zero, blue = positive)
color_palette <- colorRampPalette(c("#e15759", "white", "#4e79a7"))(50)

# Save to PNG
png("panel_2d_pathwayheatmap.png", width = 1000, height = 730, res = 150)

par(mar = c(7, 4, 1, 1))

# Create the heatmap
pheatmap(pathway_matrix,
         color = color_palette,
         cluster_rows = FALSE,    # Preserve pathway order
         cluster_cols = FALSE,    # Preserve time order
         scale = "none",          # Use raw enrichment values
         show_rownames = TRUE,
         show_colnames = TRUE,
         fontsize_row = 10,
         fontsize_col = 10,
         main = "",
         border_color = "grey60",
         cellwidth = 25,
         cellheight = 15)

dev.off()

################################################################################

# TASK 5: Reproduce panel 2e - Bubble plot
# Kinetic regimes weighted by gene count

# Read sheet 'e'
data_e <- read_excel(excel_file, sheet = "e")

# Set stage factor levels and colors
data_e$stage <- factor(data_e$stage, levels = c("72h", "6h"))
stage_colors <- c("72h" = "#59a14f", "6h" = "#4e79a7")

# Offset coordinates for manual size legend placement
x_off <- 45.5
y_off <- 0.155

# Filter out points beyond axis limits
data_plot <- data_e[data_e$half_life <= 55 & data_e$alpha >= 0, ]

# Create the bubble plot
plot_2e <- ggplot(data_plot, aes(x = half_life, y = alpha, 
                                 color = stage, size = count)) +
  geom_point() +
  coord_cartesian(clip = "off", 
                  xlim = c(0, 58), 
                  ylim = c(0, 2.15)) +
  # Color legend (positioned inside the plot)
  scale_color_manual(
    values = stage_colors, 
    guide = guide_legend(
      position = "inside",
      override.aes = list(size = 4), 
      title = NULL,
      keyheight = unit(0.8, "cm"),
      keywidth = unit(0.4, "cm"),
      theme = theme(
        legend.position.inside = c(0.89, 0.871),
        legend.justification = c(1, 1),
        legend.key.spacing.x = unit(0.2, "cm"),
        legend.key.spacing.y = unit(0.2, "cm"),
        legend.margin = margin(18, 25, 18, 18)))) +
  # Size legend disabled (drawn manually below)
  scale_size_continuous(
    range = c(1, 10), 
    guide = "none") +
  scale_x_continuous(breaks = seq(0, 50, by = 10), 
                     expand = c(0, 0.5)) +
  scale_y_continuous(breaks = seq(0, 2.0, by = 0.5), 
                     expand = c(0, 0.025)) +
  labs(x = "Half Life", y = "Alpha") +
  
  # Manual size legend: dots with proportional text
  annotate("point", x = x_off + 3, y = y_off + 0.39, 
           size = 2, color = "black") +
  annotate("text", x = x_off + 6, y = y_off + 0.39, 
           label = "10", size = 2.5, hjust = 0) +
  annotate("point", x = x_off + 3, y = y_off + 0.20, 
           size = 5, color = "black") +
  annotate("text", x = x_off + 6, y = y_off + 0.20, 
           label = "20", size = 4, hjust = 0) +
  annotate("point", x = x_off + 3, y = y_off - 0.01, 
           size = 8, color = "black") +
  annotate("text", x = x_off + 6, y = y_off - 0.01, 
           label = "30", size = 5.5, hjust = 0) +
  
  # Manual size legend border (four line segments)
  annotate("segment", x = x_off - 1, xend = x_off + 13, 
           y = y_off - 0.18, yend = y_off - 0.18, linewidth = 0.3) +
  annotate("segment", x = x_off - 1, xend = x_off + 13, 
           y = y_off + 0.55, yend = y_off + 0.55, linewidth = 0.3) +
  annotate("segment", x = x_off - 1, xend = x_off - 1, 
           y = y_off - 0.18, yend = y_off + 0.55, linewidth = 0.3) +
  annotate("segment", x = x_off + 13, xend = x_off + 13, 
           y = y_off - 0.18, yend = y_off + 0.55, linewidth = 0.3) +
  
  theme_classic(base_size = 13) +
  theme(
    legend.background = element_rect(color = "black", fill = "white", linewidth = 0.5),
    legend.key = element_rect(fill = "white", color = NA),
    legend.text = element_text(size = 11),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.3),
    aspect.ratio = 0.95,
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    axis.ticks.length.y = unit(0.4, "cm"),
    axis.ticks.length.x = unit(0.4, "cm"),
    axis.title.x = element_text(size = 14, margin = margin(t = 15)),
    axis.title.y = element_text(size = 14, margin = margin(r = 15))
  )

print(plot_2e)

ggsave("panel_2e_bubble_plot.png", plot_2e, width = 6, height = 6, dpi = 300)

###############################################################################

# TASK 6: Reproduce panel 2f - Stacked bar chart
# B vs Plasma cell proportions over time

# Read sheet 'f'
data_f <- read_excel(excel_file, sheet = "f")

# Subset to s00h and s72h stages only
data_f_subset <- data_f %>%
  filter(stage %in% c("s00h", "s72h"))

# Create stacked bar chart
plot_2f <- ggplot(data_f_subset, aes(x = stage, y = proportion, fill = cell_type)) +
  geom_bar(stat = "identity", width = 0.8, 
           position = position_stack(reverse = TRUE),  # B on bottom, Plasma on top
           color = "black",       # Black borders around bars
           linewidth = 0.7) +
  scale_fill_manual(values = c("B" = "#fabfd2",        # Light pink for B
                               "Plasma" = "#4e79a7")) +  # Blue for Plasma
  scale_y_continuous(limits = c(0, 0.3),
                     breaks = seq(0, 0.3, by = 0.05),
                     expand = c(0, 0)) +
  scale_x_discrete(expand = c(0.3, 0.2)) +
  # Legend settings: Plasma on top of B, positioned inside the plot
  guides(fill = guide_legend(reverse = TRUE, 
                             byrow = TRUE,
                             keyheight = unit(0.8, "cm"),
                             keywidth = unit(0.8, "cm"),
                             position = "inside",
                             theme = theme(
                               legend.position.inside = c(0.7, 0.825),
                               legend.justification = c(0.5, 1)))) +
  labs(x = "", y = "", fill = "") +
  theme_classic() +
  theme(panel.grid = element_blank(),
        axis.line.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x = element_text(size = 14, vjust = -5.0),
        axis.text.y = element_text(size = 14),
        axis.ticks.length.y = unit(0.4, "cm"),
        legend.background = element_rect(color = "black", fill = "white", linewidth = 0.5),
        legend.key.spacing.y = unit(5, "mm"),
        legend.margin = margin(t = 15, r = 30, b = 12, l = 20),
        legend.text = element_text(size = 16),
        legend.title = element_blank()
  )

print(plot_2f)

ggsave("panel_2f_barchart.png", plot_2f, width = 5, height = 6, dpi = 300)

################################################################################

# TASK 7: Reproduce panel 2g - Network Graph
# Directed cell-cell interaction network

# Read sheet 'g'
data_g <- read_excel(excel_file, sheet = "g")

# Convert to adjacency matrix
adj_matrix <- as.data.frame(data_g)
rownames(adj_matrix) <- adj_matrix[, 1]
adj_matrix <- as.matrix(adj_matrix[, -1])

# Create directed weighted graph from adjacency matrix
g <- graph_from_adjacency_matrix(
  adj_matrix,
  mode = "directed",
  weighted = TRUE,
  diag = FALSE        # Ignore self-loops
)

# Remove zero-weight edges
g <- delete.edges(g, which(E(g)$weight == 0))

# Node colors from hb_pal (all nodes same color)
node_colors <- c(
  "CD4+ T" = "#fabfd2",     
  "CD8+ T" = "#fabfd2",     
  "Naive B" = "#fabfd2",    
  "GC B" = "#fabfd2",         
  "Plasma" = "#fabfd2",     
  "Macrophage" = "#fabfd2", 
  "DC" = "#fabfd2"          
)

# Manual layout to match original figure positioning
layout_manual <- matrix(c(
  0.30, 0.92,   # CD4+ T (top)
  0.58, 0.72,   # CD8+ T (upper-right)
  0.05, 0.55,   # Naive B (left)
  0.60, 0.15,   # GC B (bottom-right)
  0.90, 0.65,   # Plasma (far right)
  0.42, 0.50,   # Macrophage (center)
  0.30, 0.12    # DC (bottom-left)
), ncol = 2, byrow = TRUE)

# Edge attributes
E(g)$arrow.size <- E(g)$weight * 2  # Arrow size proportional to weight
E(g)$width <- 2       
E(g)$color <- "grey70"
E(g)$curved <- 0  # Straight edges

# Node attributes
V(g)$color <- node_colors[V(g)$name]
V(g)$size <- 18
V(g)$label.cex <- 1
V(g)$label.color <- "#4e79a7"  # Label color from hb_pal
V(g)$label.font <- 2           # Bold
V(g)$label.family <- "serif"
V(g)$frame.color <- "grey40"
V(g)$frame.width <- 1.5

# Compute force-directed layout (seed for reproducibility)
#set.seed(200) # tested, not used
#layout <- layout_with_fr(g) # tested, not used

# Save to PNG
png("panel_2g_network.png", width = 900, height = 900, res = 150)

# Per-edge arrow sizes (weight * 2), set earlier via E(g)$arrow.size
sizes <- E(g)$arrow.size

# Total number of edges, used to loop over them one by one
n <- ecount(g)

# Draw edges one at a time, each with its own arrow size
for (i in seq_len(n)) {
  plot(g,
       layout = layout_manual,
       edge.color = ifelse(seq_len(n) == i, "grey70", NA),  # only edge i visible
       edge.arrow.size = sizes[i],
       edge.arrow.mode = ">",
       vertex.color = NA, vertex.frame.color = NA, vertex.label = NA,
       add = (i > 1))   # first call starts the image, later calls draw on top
}

# Draw nodes and labels last, so they sit on top of the edges
plot(g,
     layout = layout_manual,
     edge.color = NA,
     vertex.label = V(g)$name,
     vertex.label.dist = 0,
     add = TRUE)

dev.off()


################################################################################

# TASK 8: Final assembly
# Arrange all panels into a single figure

#install.packages("patchwork")
#install.packages("cowplot")
#install.packages("magick")

library(patchwork)
library(cowplot)
library(magick)

# Load saved PNG panels as ggplot objects
plot_2a <- ggdraw() + draw_image("panel_2a_boxplot.png")
plot_2b <- ggdraw() + draw_image("panel_2b_scatterplot.png")
plot_2c <- ggdraw() + draw_image("panel_2c_boxplot.png")
plot_2d <- ggdraw() + draw_image("panel_2d_pathwayheatmap.png")
plot_2e <- ggdraw() + draw_image("panel_2e_bubble_plot.png")
plot_2f <- ggdraw() + draw_image("panel_2f_barchart.png")
plot_2g <- ggdraw() + draw_image("panel_2g_network.png")

# Assemble: top row (a, b, d, e) / bottom row (c, f, g)
final_figure <- (plot_2a | plot_2b | plot_2d | plot_2e) /
  (plot_2c | plot_2f | plot_2g) +
  plot_layout(widths = c(2, 0.8, 2, 0.8),
              heights = c(1.2, 1.2)) +
  plot_annotation(tag_levels = list(c('a', 'b', 'd', 'e', 'c', 'f', 'g'))) &
  theme(plot.tag.position = c(0.02, 0.98),
        plot.tag = element_text(size = 18, 
                                face = "plain",
                                hjust = 1,
                                vjust = 3),
        plot.margin = margin(20, 20, 20, 20))

print(final_figure)

ggsave("final_figure_assembled_1.png", final_figure, width = 24, height = 13, dpi = 300)
