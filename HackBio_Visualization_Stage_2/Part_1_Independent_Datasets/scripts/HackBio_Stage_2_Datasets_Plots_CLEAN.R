# Install and load required packages
install.packages("ggplot2")
install.packages("dplyr")

# ComplexHeatmap requires Bioconductor
BiocManager::install("ComplexHeatmap")

library(ggplot2)
library(dplyr)
library(ComplexHeatmap)
library(grid)

################################################################################

# PART 1: GENE EXPRESSION (HEATMAP & VOLCANO PLOT)

############ HEATMAP (Normalized counts for HBR vs UHR samples) ################

# Load normalized gene expression counts
norm_counts <- read.csv('https://raw.githubusercontent.com/HackBio-Internship/2025_project_collection/refs/heads/main/Python/Dataset/hbr_uhr_top_deg_normalized_counts.csv', 
                        row.names = 1)

mat <- as.matrix(norm_counts)

# Color palette: white to dark blue gradient
col_fun <- colorRampPalette(c("white", "lightblue", "steelblue", "darkblue"))(100)

# Set column order: HBR samples first, then UHR
desired_col_order <- c("HBR_1", "HBR_2", "HBR_3", "UHR_1", "UHR_2", "UHR_3")
mat <- mat[, desired_col_order]

# Build column dendrogram and reorder leaves to match desired order
col_hclust <- hclust(dist(t(mat)))
col_dend <- reorder(as.dendrogram(col_hclust),
                    wts = match(desired_col_order, colnames(mat)))

# Row clustering (data-driven)
row_hclust <- hclust(dist(mat))

# Show labels only for selected genes
labeled_genes <- c("IGLC3", "IGLC2", "CDC45", "MPPED1", "RP3-323A16.1", "RP5-1119A7.17")
row_labels <- ifelse(rownames(mat) %in% labeled_genes, rownames(mat), "")

# Create heatmap
ht <- Heatmap(mat, col = col_fun,
              width  = unit(6 * 0.95, "cm"),
              height = unit(12 * 0.75, "cm"),
              
              cluster_rows = row_hclust,
              cluster_columns = col_dend,      
  
              row_dend_side = "left",
              column_dend_side = "top",
  
              row_labels = row_labels,
              row_names_side = "right",
              row_names_gp = gpar(fontsize = 9),
              column_names_side = "bottom",
              column_names_rot = 90,
              column_names_gp = gpar(fontsize = 9),
  
              name = " ",
              heatmap_legend_param = list(
                at = c(0, 500, 1000),
                labels = c("0", "500", ""),
                legend_height = unit(3, "cm"),
                title = "",
                border = FALSE,
                tick_length = unit(5, "mm")
              ),
  
              rect_gp = gpar(col = "black", lwd = 0.4)
)

# Display
draw(ht, heatmap_legend_side = "left")

# Save to PNG
png("Heatmap_Gene_Expression_Analysis.png", width = 7, height = 7, units = "in", res = 300)
draw(ht, heatmap_legend_side = "left")
dev.off()

################################################################################
########### VOLCANO PLOT (Differential expression results, Chromosome 22) ######

# Load differential expression results
deg_results <- read.csv('https://raw.githubusercontent.com/HackBio-Internship/2025_project_collection/refs/heads/main/Python/Dataset/hbr_uhr_deg_chr22_with_significance.csv', 
                        row.names = 1)

# Create volcano plot
p <- ggplot(deg_results, 
            aes(x = log2FoldChange, 
                y = X.log10PAdj,
                fill = significance)) + 
  
            geom_point(shape = 21,               
                      color = "white",        
                      size = 3.3,
                      stroke = 0.8,              
                      alpha = 1) +
  
            scale_fill_manual(
                      values = c("down" = "#f4a340",
                                 "ns"   = "#b0b0b0",
                                 "up"   = "#3ab54a"),
                      name = "significance") +
  
            geom_vline(xintercept = c(-1, 1),
                       linetype = "dashed",
                       color = "grey40") +
  
            geom_hline(yintercept = 0,
                       linetype = "dashed",
                       color = "grey40") +
  
            labs(x = "log2FoldChange",
                 y = "-log10PAdj") +
  
            coord_cartesian(
                  xlim = c(-10, 12),   
                  ylim = c(-2, 210)) +
  
            theme_classic() +
            theme(aspect.ratio = 1,
                  panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
                  legend.background = element_rect(color = "grey", fill = "white"),
                  legend.key.size = unit(0.6, "cm"),
                  legend.margin = margin(4, 6, 4, 6),
                  legend.title = element_text(size = 12),
                  legend.text = element_text(size = 12),
                  legend.position = c(0.88, 0.88),
                  axis.text.x = element_text(size = 11),
                  axis.text.y = element_text(size = 11),
                  axis.title.x = element_text(size = 11, margin = margin(t = 4)),
                  axis.title.y = element_text(size = 11, margin = margin(r = 4)))

print(p)

ggsave(filename = "Volcano_Plot_DE_Chromosome22.png", plot = p, width = 6, height = 6, dpi = 300, bg = "white")

################################################################################

# PART 2: BREAST CANCER DIAGNOSTIC DATA (CORRELATION & SCATTER/DENSITY PLOTS)

################################################################################

# Load breast cancer diagnostic dataset
breast_cancer <- read.csv('https://raw.githubusercontent.com/HackBio-Internship/2025_project_collection/refs/heads/main/Python/Dataset/data-3.csv')

################### SCATTER PLOT (radius vs texture)  ##########################

p <- ggplot(breast_cancer,
            aes(x = radius_mean, 
                y = texture_mean, 
                fill = diagnosis)) +        
  
            geom_point(shape = 21,
                       color = "white",          
                       size = 3.3,
                       stroke = 0.8,
                       alpha = 1) +
  
            scale_fill_manual(values = c("M" = "#4C96D7", "B" = "#F4803C"),        
                              name = "diagnosis") +
  
            guides(fill = guide_legend(reverse = TRUE)) +   
  
            scale_x_continuous(breaks = seq(10, 25, by = 5)) +  
            scale_y_continuous(breaks = seq(10, 40, by = 5)) +  
  
            labs(x = "radius_mean", y = "texture_mean") +
  
            coord_cartesian(xlim = c(6, 29), ylim = c(9, 39)) +
  
            theme_classic() +
            theme(aspect.ratio = 1,
                  panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
                  legend.background = element_rect(color = "grey", fill = "white", linewidth = 0.5),
                  legend.title = element_text(size = 12),
                  legend.text = element_text(size = 12),
                  legend.key.size = unit(0.8, "cm"),
                  legend.margin = margin(4, 6, 4, 6),
                  legend.position = c(0.9, 0.89),
                  axis.text.x = element_text(size = 12),
                  axis.text.y = element_text(size = 12),
                  axis.title.x = element_text(size = 12, margin = margin(t = 5)),
                  axis.title.y = element_text(size = 12, margin = margin(r = 5)))

print(p)

ggsave(filename = "Scatter_Plot_RadiusVSTexture.png", plot = p, width = 6, height = 6, dpi = 300, bg = "white")

################################################################################
######################### CORRELATION HEATMAP ##################################

# Select numeric features and compute correlation matrix
features <- breast_cancer %>%
  select(radius_mean, texture_mean, perimeter_mean, 
         area_mean, smoothness_mean, compactness_mean)

cor_matrix <- cor(features)

# Color palette for correlation values
col_fun <- colorRampPalette(c("white", "#c6dbef", "#6baed6", "#2171b5"))(100)

# Create correlation heatmap with values displayed in cells
ht <- Heatmap(cor_matrix,
              col = col_fun,
              cluster_rows = FALSE,
              cluster_columns = FALSE,

              width  = unit(5, "cm"),
              height = unit(6, "cm"),
  
              # Display correlation values inside cells
              cell_fun = function(j, i, x, y, width, height, fill) {
                grid.text(
                  sprintf("%.1f", cor_matrix[i, j]), x, y,
                  gp = gpar(fontsize = 9,
                            col = ifelse(cor_matrix[i, j] > 0.4, "white", "black")))
              },
  
              rect_gp = gpar(col = "black", lwd = 1),
              row_names_side = "left",
              column_names_rot = 90,
              row_names_gp = gpar(fontsize = 9),
              column_names_gp = gpar(fontsize = 9),
  
              name = " ",
              heatmap_legend_param = list(
                at = c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0),
                labels = c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0"),
                legend_height = unit(6, "cm"),
                legend_width = unit(0.5, "cm"),
                border = NA,
                tick_length = unit(3, "mm"),        
                labels_gp = gpar(fontsize = 9)))

# Display
draw(ht, heatmap_legend_side = "right")

# Save to PNG
png("Correlation_Heatmap.png", width = 8, height = 6, units = "in", res = 300)
draw(ht, heatmap_legend_side = "right")
dev.off()

################################################################################
################## SCATTER PLOT (smoothness vs compactness) ####################

p <- ggplot(breast_cancer,
            aes(x = smoothness_mean, 
                y = compactness_mean, 
                fill = diagnosis)) +
  
            geom_point(shape = 21,
                       color = "white",
                       size = 3.3,
                       alpha = 1, 
                       stroke = 0.8) +
  
            scale_fill_manual(values = c("M" = "#4C96D7", "B" = "#F4803C"),    
                              name = "diagnosis") +
  
            guides(fill = guide_legend(reverse = TRUE)) + 
  
            scale_x_continuous(breaks = seq(0.050, 0.150, by = 0.025)) +  
            scale_y_continuous(breaks = seq(0.05, 0.35, by = 0.05)) +  
  
            labs(x = "smoothness_mean", y = "compactness_mean") +
  
            coord_cartesian(xlim = c(0.05, 0.165), ylim = c(0.02, 0.35)) +
  
            theme_bw() +
            theme(aspect.ratio = 1,
                  panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
                  legend.background = element_rect(color = "grey", fill = "white", linewidth = 0.5),
                  legend.title = element_text(size = 14),
                  legend.text = element_text(size = 14),
                  legend.key.size = unit(0.9, "cm"),
                  legend.margin = margin(4, 6, 4, 6),
                  legend.position = c(0.13, 0.87),
                  axis.text.x = element_text(size = 12),
                  axis.text.y = element_text(size = 12),
                  axis.title.x = element_text(size = 12, margin = margin(t = 5)),
                  axis.title.y = element_text(size = 12, margin = margin(r = 5)))

print(p)

ggsave(filename = "Scatter_compactness_vs_smoothness.png", plot = p, width = 6, height = 6, dpi = 300, bg = "white")

################################################################################
####################### DENSITY PLOT (area distribution) #######################

p <- ggplot(breast_cancer,
            aes(x = area_mean, fill = diagnosis, color = diagnosis)) +
  
            geom_density(alpha = 0.4, linewidth = 0.8) +
  
            scale_fill_manual(values = c("M" = "#4C96D7", "B" = "#F4803C"),
                              name = "diagnosis") +
  
            scale_color_manual(values = c("M" = "#4C96D7", "B" = "#F4803C"),
                               name = "diagnosis") +
  
            scale_y_continuous(breaks = seq(0, 0.003, by = 0.00025),
                               labels = scales::number_format(accuracy = 0.00001),
                               expand = c(0, 0)) +
  
            scale_x_continuous(breaks = seq(0, 3000, by = 1000),
                               limits = c(0, 3000),
                               expand = c(0.02, 0)) +
  
            guides(fill = guide_legend(reverse = TRUE),
                   color = guide_legend(reverse = TRUE)) +
  
            labs(x = "area_mean", y = "Density") +
  
            coord_cartesian(ylim = c(0, 0.0032)) +
  
            theme_classic() +
            theme(aspect.ratio = 1,
                  panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
                  legend.position = c(0.97, 0.97),
                  legend.justification = c(1, 1),
                  legend.background = element_rect(color = "grey", fill = "white", linewidth = 0.5),
                  legend.key = element_rect(color = NA, fill = NA),
                  legend.key.size = unit(0.5, "cm"),
                  legend.key.spacing.x = unit(1, "cm"),
                  legend.key.spacing.y = unit(0.3, "cm"),
                  legend.title = element_text(size = 13),
                  legend.text = element_text(size = 13),
                  legend.margin = margin(5, 7, 5, 7),
                  axis.text.x = element_text(size = 11),
                  axis.text.y = element_text(size = 11),
                  axis.title.x = element_text(size = 12, margin = margin(t = 3)),
                  axis.title.y = element_text(size = 12, margin = margin(r = 5)))

print(p)

ggsave(filename = "Density_area_mean.png", plot = p, width = 6, height = 6, dpi = 300, bg = "white")

################################################################################

# FINAL ASSEMBLY: Arrange all panels into a single figure

install.packages("patchwork")
install.packages("cowplot")
install.packages("magick")

library(patchwork)
library(cowplot)
library(magick)
library(ggplot2)

# Load saved PNG panels as ggplot objects
plot_a <- ggdraw() + draw_image("Heatmap_Gene_Expression_Analysis.png")
plot_b <- ggdraw() + draw_image("Volcano_Plot_DE_Chromosome22.png")
plot_c <- ggdraw() + draw_image("Scatter_Plot_RadiusVSTexture.png")
plot_d <- ggdraw() + draw_image("Correlation_Heatmap.png")
plot_e <- ggdraw() + draw_image("Scatter_compactness_vs_smoothness.png")
plot_f <- ggdraw() + draw_image("Density_area_mean.png")

# Assemble: top row (a, b, c) / bottom row (d, e, f)
final_figure <- (plot_a | plot_b | plot_c) /
  (plot_d | plot_e | plot_f) +
  plot_layout(widths = c(1, 1, 1),
              heights = c(1, 1)) +
  plot_annotation(tag_levels = list(c('a', 'b', 'c', 'd', 'e', 'f'))) &
  theme(plot.tag.position = c(0.02, 0.98),
        plot.tag = element_text(size = 18, 
                                face = "plain",
                                hjust = 1,
                                vjust = 3),
        plot.margin = margin(20, 20, 20, 20))

print(final_figure)

ggsave("Final_Figure_Assembled_Datasets.png", final_figure, width = 24, height = 13, dpi = 300)
