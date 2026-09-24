# ==============================================================================
# Cell Type Snapshot Explorer
# HackBio Visualization Internship
# Final Version
# ==============================================================================
# Folder structure:
#   shiny_app/
#     app.R
#     cell_metadata.csv
#     expression_matrix.csv
#     umap_coordinates.csv
# 
# Run with: shiny::runApp("shiny_app")
# ==============================================================================

library(shiny)
library(ggplot2)
library(dplyr)
library(DT)

# ==============================================================================
# STEP 1: Create a project folder (contains app.R and 3 CSV files)
# ==============================================================================
# Folder structure:
#   shiny_app/
#     app.R
#     cell_metadata.csv
#     expression_matrix.csv
#     umap_coordinates.csv
# ==============================================================================
# STEP 2: Load and process the datasets
# ==============================================================================
#setwd("C:/Users/2759309/Desktop/Shiny_New")

expr_mat   <- read.csv("expression_matrix.csv",  row.names = 1, check.names = FALSE)
meta_df    <- read.csv("cell_metadata.csv",       stringsAsFactors = FALSE)
umap_coord <- read.csv("umap_coordinates.csv",    stringsAsFactors = FALSE)

# Confirm all three share the same cell IDs; intersect cell IDs and subset to common cells
common_cells <- Reduce(intersect, list(
  rownames(expr_mat),
  meta_df$cell_id,
  umap_coord$cell_id
))

# Keep only safe cells (whose row names are in common_cells) in each file
expr_mat   <- expr_mat[common_cells, , drop = FALSE]
meta_df    <- meta_df[meta_df$cell_id %in% common_cells, ]
umap_coord <- umap_coord[umap_coord$cell_id %in% common_cells, ]

# Reorder rows to align datasets by cell_id
meta_df    <- meta_df[match(common_cells, meta_df$cell_id), ]
umap_coord <- umap_coord[match(common_cells, umap_coord$cell_id), ]

# ==============================================================================
# STEP 3-5, 7: Write core boilerplate functions:
# 1. Step 3. t_col for color transparency.
# 2. Step 4. scale_0_100 for gradient visualization of gene expression levels.
# 3. Step 5. compute_gene_stats for per-gene statistics for selected cell type.
# 4. Step 7. pick_marker_gene for the best marker gene identification.
# All four functions are defined here and called later in the server.
# ==============================================================================

# 1. Transparent color helper
t_col <- function(color, percent = 50, name = NULL) {
  rgb.val <- col2rgb(color)
  t.col   <- rgb(
    rgb.val[1], rgb.val[2], rgb.val[3], max   = 255,
    alpha = (100 - percent) * 255 / 100, names = name
  )
  invisible(t.col)
  }

# 2. Scale marker expression values to 0-100 range for consistent visualization
scale_0_100 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (rng[1] == rng[2]) return(rep(50, length(x)))
  (x - rng[1]) / (rng[2] - rng[1]) * 100
}

# 3. Compute per-gene statistics for a chosen cell type
compute_gene_stats <- function(expr_mat, meta_df, target_ct) {
  # Identify cells inside and outside the selected cell type
  in_cells  <- meta_df$cell_id[meta_df$cell_type == target_ct]
  out_cells <- meta_df$cell_id[meta_df$cell_type != target_ct]
  # Subset expression matrix
  xin  <- expr_mat[in_cells,  , drop = FALSE]
  xout <- expr_mat[out_cells, , drop = FALSE]
  # Detection rates
  det_in   <- colMeans(xin  > 0)
  det_out  <- colMeans(xout > 0)
  # Mean expression
  mean_in  <- colMeans(xin)
  mean_out <- colMeans(xout)
  # Specificity difference
  diff     <- mean_in - mean_out
  return(data.frame(
    gene     = colnames(expr_mat),
    det_in   = det_in,
    det_out  = det_out,
    mean_in  = mean_in,
    mean_out = mean_out,
    diff     = diff,
    stringsAsFactors = FALSE
  ))
}

# 4. Select the marker gene: max diff, tie-breaker: max det_in
pick_marker_gene <- function(gene_stats_df) {
  gene_stats_df <- gene_stats_df %>%
    arrange(desc(diff), desc(det_in))
  gene_stats_df$gene[1]
}

# ==============================================================================
# STEP 6: Prepare UMAP plotting data
# ==============================================================================

umap_meta <- merge(meta_df, umap_coord, by = "cell_id")

# Color palette for cell types (used in "All" UMAP)
ct_colors <- c(
  T_cell   = "#4E9AC7",
  B_cell   = "#2CA02C",
  NK_cell  = "#1C1C1C",
  Monocyte = "#D46A6A"
)

# Light versions of color palette for gradient low end when a type is selected

ct_colors_light <- c(
  T_cell   = "#cce5f5",
  B_cell   = "#c8e8c8",
  NK_cell  = "#d0d0d0",
  Monocyte = "#f5d0d0"
)

# ==============================================================================
# STEP 8: Building UI
# ==============================================================================

cell_type_choices <- c("All", c("T_cell", "B_cell", "NK_cell", "Monocyte"))

ui <- fluidPage(
  
  tags$head(tags$style(HTML("
    body {
      font-family: 'Helvetica Neue', Arial, sans-serif;
      background-color: #f5f7fa;
      color: #2c3e50;
    }
    .app-header {
      background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
      color: white;
      padding: 20px 28px 16px 28px;
      margin-bottom: 20px;
      border-radius: 0 0 8px 8px;
    }
    .app-header h2 { margin: 0; font-size: 24px; font-weight: 700; }
    .app-header p  { margin: 4px 0 0 0; font-size: 13px; opacity: 0.85; }
    .well {
      background: #ffffff;
      border: 1px solid #dde3ea;
      border-radius: 8px;
      box-shadow: 0 1px 4px rgba(0,0,0,0.06);
    }
    .marker-box {
      background: #eef6fb;
      border-left: 4px solid #3498db;
      border-radius: 4px;
      padding: 10px 16px;
      margin-bottom: 14px;
      font-size: 14px;
      line-height: 1.7;
    }
    .marker-box .label { color: #7f8c8d; font-size: 12px; text-transform: uppercase; }
    .marker-box .value { color: #2c3e50; font-weight: 600; }
    .section-title {
      font-size: 13px; font-weight: 600; color: #7f8c8d;
      text-transform: uppercase; letter-spacing: 0.5px;
      margin: 16px 0 6px 0;
    }
    table { font-size: 13px; }
    thead tr { background-color: #f0f4f8; }
    pre {
      background-color: #eef6fb;
      border-left: 4px solid #3498db;
      border-radius: 4px;
      padding: 10px 16px;
      font-family: 'Helvetica Neue', Arial, sans-serif;
      font-size: 14px;
      border-top: none;
      border-right: none;
      border-bottom: none;
      color: #2c3e50;
    }
  "))),
  
  # Header
  div(class = "app-header",
      tags$h2("Simulated Cell Type Viewer"),
      tags$p("Cell Type Snapshot Explorer | HackBio Visualization Internship")
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      div(class = "section-title", "Cell Type"),
      selectInput(
        inputId  = "cell_type",
        label    = NULL,
        choices  = cell_type_choices,
        selected = "All"
      ),
      tags$hr(style = "border-color:#dde3ea;"),
      tags$small(style = "color:#7f8c8d; line-height:1.6;",
                 tags$b("All:"), " cells coloured by cell type.", tags$br(),
                 tags$b("Single type:"), " cells coloured by best marker gene expression.",
                 tags$br(), tags$br(),
                 tags$b("Marker = "), "gene with highest",
                 tags$code("diff"), "(mean_in - mean_out).",
                 tags$br(),
                 tags$b("Tie-break: "), "highest", tags$code("det_in"), "."
      )
    ),
    
    mainPanel(
      width = 9,
      
      # Output 4: marker gene info (hidden for "All")
      verbatimTextOutput("marker_info"),
      
      # Output 2: UMAP plot
      div(class = "section-title", "UMAP EMBEDDING"),
      plotOutput("umap_plot", height = "480px", width = "100%"),
      tags$hr(style = "border-color:#dde3ea; margin-top:20px;"),
      
      # Summary table (shown only when "All" is selected)
      uiOutput("summary_table_section"),
      
      # Output 3: gene statistics table
      div(class = "section-title", "Per-gene Statistics"),
      DTOutput("gene_table")
    )
  )
)

# ==============================================================================
# STEP 9: Building Server
# ==============================================================================

server <- function(input, output, session) {
  
  # Reactive: recompute gene stats when input$cell_type changes
  # (used in renderDT (gene table) and marker_gene())
  gene_stats <- reactive({
    req(input$cell_type != "All")
    compute_gene_stats(expr_mat, meta_df, input$cell_type)
  })
  
  # Reactive: reselect marker gene based on updated stats
  # (used in renderPlot (UMAP coloring) and marker_diff())
  marker_gene <- reactive({
    req(gene_stats())
    pick_marker_gene(gene_stats())
  })
  
  # Reactive: get diff value of the marker gene
  # (used in renderText (the text box))
  marker_diff <- reactive({
    req(gene_stats(), marker_gene())
    gene_stats()$diff[gene_stats()$gene == marker_gene()]
  })
  
  # Text Output: text reporting selected cell type, marker gene, diff value
  output$marker_info <- renderText({
    if (input$cell_type == "All") return("Select a cell type to see marker gene info.")
    paste0(
      "Cell type:   ", input$cell_type,   "\n",
      "Marker gene: ", marker_gene(),      "\n",
      "Diff score:  ", round(marker_diff(), 4)
    )
  })
  
  # UMAP Output: redraw UMAP colored by marker expression
  output$umap_plot <- renderPlot({
    if (input$cell_type == "All") {
      # Before selection: colour by cell type
      ggplot(umap_meta, aes(x = UMAP_1, y = UMAP_2, colour = cell_type)) +
        geom_point(size = 2.2, alpha = 0.85) +
        scale_colour_manual(values = ct_colors, name = "Cell type",
                            breaks = c("T_cell", "B_cell", "NK_cell", "Monocyte")) +
        labs(
          title    = "All clusters coloured by cell type",
          subtitle = "Select a cell type from the dropdown to explore marker genes",
          x = "UMAP 1", y = "UMAP 2"
        ) +
        theme_bw(base_size = 13) +
        theme(
          plot.title       = element_text(face = "bold", size = 14),
          plot.subtitle    = element_text(colour = "grey50", size = 11),
          legend.position  = "right",
          panel.grid.minor = element_blank(),
          aspect.ratio     = 0.7
        )
    } else {
      # Attach marker expression to umap_meta
      mg      <- marker_gene()
      plot_df <- umap_meta
      plot_df$expr_raw <- expr_mat[plot_df$cell_id, mg]
      
      # Scale marker expression to 0-100
      plot_df$expr_scaled <- scale_0_100(plot_df$expr_raw)
      
      plot_df$is_selected <- plot_df$cell_type == input$cell_type
      # Draw unselected cells first (behind selected)
      plot_df <- plot_df[order(plot_df$is_selected), ]
      
      ggplot(plot_df, aes(x = UMAP_1, y = UMAP_2)) +
        # Unselected cells: grey, semi-transparent
        geom_point(
          data   = filter(plot_df, !is_selected),
          colour = t_col("grey60", percent = 40),
          size   = 1.8
        ) +
        # Selected cells: colored by scaled marker expression
        geom_point(
          data  = filter(plot_df, is_selected),
          aes(colour = expr_scaled),
          size  = 2.5,
          alpha = 0.9
        ) +
        scale_colour_gradient(
          low  = ct_colors_light[input$cell_type],
          high = ct_colors[input$cell_type],
          name = paste0(mg, "\n(scaled 0-100)")
        ) +
        labs(
          title    = paste0("Cell type: ", input$cell_type),
          subtitle = paste0("Marker gene: ", mg,
                            "  |  diff = ", round(marker_diff(), 4)),
          x = "UMAP 1", y = "UMAP 2"
        ) +
        theme_bw(base_size = 13) +
        theme(
          plot.title       = element_text(face = "bold", size = 14),
          plot.subtitle    = element_text(colour = "grey50", size = 11),
          legend.position  = "right",
          panel.grid.minor = element_blank(),
          aspect.ratio     = 0.7
        )
    }
  })
  
  # Summary Table Output: Summary table section (visible only when "All" is selected)
  output$summary_table_section <- renderUI({
    if (input$cell_type != "All") return(NULL)
    tagList(
      div(class = "section-title", "Cell Type Overview"),
      tableOutput("summary_table"),
      tags$hr(style = "border-color:#dde3ea; margin-top:20px;")
    )
  })
  
  output$summary_table <- renderTable({
    summary_rows <- lapply(c("T_cell", "B_cell", "NK_cell", "Monocyte"), function(ct) {
      cells    <- meta_df$cell_id[meta_df$cell_type == ct]
      stats    <- compute_gene_stats(expr_mat, meta_df, ct)
      top_gene <- pick_marker_gene(stats)
      data.frame(
        cell_type = ct,
        n_cells   = length(cells),
        top_gene  = top_gene,
        mean_top  = round(stats$mean_in[stats$gene == top_gene], 3),
        diff_top  = round(stats$diff[stats$gene == top_gene],    3)
      )
    })
    do.call(rbind, summary_rows)
  }, striped = TRUE, hover = TRUE, bordered = TRUE, spacing = "s", width = "100%")
  
  # Gene Stats Table Output: update gene stats table accordingly
  output$gene_table <- renderDT({
    if (input$cell_type == "All") {
      # Show gene table with NAs when no cell type selected
      data.frame(
        gene     = colnames(expr_mat),
        det_in   = NA_real_,
        det_out  = round(colMeans(expr_mat > 0), 3),
        mean_in  = NA_real_,
        mean_out = round(colMeans(expr_mat), 3),
        diff     = NA_real_
      )
    } else {
      # Full per-gene stats for selected cell type
      stats          <- gene_stats()
      stats <- stats %>% arrange(desc(diff), desc(det_in))
      stats$det_in   <- round(stats$det_in,   3)
      stats$det_out  <- round(stats$det_out,  3)
      stats$mean_in  <- round(stats$mean_in,  3)
      stats$mean_out <- round(stats$mean_out, 3)
      stats$diff     <- round(stats$diff,     3)
      stats
    }
  },
  options  = list(pageLength = 10, scrollY = "300px"),
  rownames = FALSE
  )
}

# ==============================================================================
# STEP 10: Reproducibility - restart R and confirm same output
# ==============================================================================
shinyApp(ui = ui, server = server)