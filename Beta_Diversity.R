#Beta Diversity
library(tidyverse)
library(pheatmap)
beta_data <- read_csv("SI072_NirK_beta_diversity.csv")
head(beta_data)

# Split 'sample_1' and 'sample_2' into their components (optional but useful for clarity)
beta_data <- beta_data %>%
  mutate(
    sample_1 = gsub("_NirK_complete_profile", "", sample_1),
    sample_2 = gsub("_NirK_complete_profile", "", sample_2)
  ) %>%
  mutate(
    sample_1 = gsub("SI072_", "", sample_1),
    sample_2 = gsub("SI072_", "", sample_2)
  )%>%
  mutate(
    sample_1 = as.numeric(gsub("m", "", sample_1)),
    sample_2 = as.numeric(gsub("m", "", sample_2))
  )

# Generate a list of all unique samples from both columns
all_samples <- sort(unique(c(beta_data$sample_1, beta_data$sample_2)))

# Create an empty matrix filled with NA
beta_matrix_complete <- matrix(NA,
                               nrow = length(all_samples),
                               ncol = length(all_samples),
                               dimnames = list(all_samples, all_samples))

# Fill in the matrix symmetrically
for (i in seq_len(nrow(beta_data))) {
  row_name <- as.character(beta_data$sample_1[i])
  col_name <- as.character(beta_data$sample_2[i])
  value <- beta_data$Z_1[i]
  
  # Assign value to both [row, col] and [col, row] to make it symmetrical
  beta_matrix_complete[row_name, col_name] <- value
  beta_matrix_complete[col_name, row_name] <- value
}

# Replace NA with 0 if desired (or leave as NA for missing values)
beta_matrix_complete[is.na(beta_matrix_complete)] <- 0  

# Convert to a data frame for compatibility with pheatmap
beta_matrix_clean <- as.data.frame(beta_matrix_complete)

# View the completed matrix
print(beta_matrix_clean)

# Sort rows by their names or a specific column
sorted_matrix <- beta_matrix_clean[order(rownames(beta_matrix_clean)), , drop = FALSE]

# Cluster columns
col_clust <- hclust(dist(t(sorted_matrix)))  # Create column dendrogram
# Flip dendrogram branches if desired
col_clust$order <- order(rownames(beta_matrix_clean))

# Plot the heatmap
pheatmap(as.matrix(sorted_matrix),
         cluster_rows = FALSE,
         cluster_cols = col_clust,
         scale = "none",
         color = colorRampPalette(c("black", "grey", "white"))(100),
         border_color = NA,
         main = "KR Distance Heatmap with Dendrogram - Metagenome")
