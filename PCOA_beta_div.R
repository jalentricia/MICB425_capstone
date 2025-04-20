library(tidyverse)
library(vegan)
library(ggrepel)
library(ape)

# 1. Load KR distance matrix
kr_matrix <- read.csv("NirK_KR_distance_matrix.csv", row.names = 1, check.names = FALSE)
kr_dist <- as.dist(as.matrix(kr_matrix))

# 2. PCoA
pcoa_result <- pcoa(kr_dist)
pcoa_scores <- as.data.frame(pcoa_result$vectors[, 1:2])
colnames(pcoa_scores) <- c("PCoA1", "PCoA2")
pcoa_scores$Depth <- rownames(pcoa_scores)

# 3. Load classification files and build abundance matrix
folder_path <- "Classification_files"
files <- list.files(folder_path, pattern = "_classifications.tsv$", full.names = TRUE)

# Taxon extraction helpers
extract_taxon <- function(tax_string, rank) {
  pattern <- paste0(rank, "__[^;]+")
  str_extract(tax_string, pattern)
}
resolve_best_taxon <- function(tax_string) {
  ranks <- c("g", "f", "o", "c", "p", "d")
  for (r in ranks) {
    match <- extract_taxon(tax_string, r)
    if (!is.na(match)) return(match)
  }
  return(NA)
}

# Read and resolve taxa
all_classifications <- map_dfr(files, function(f) {
  depth <- str_extract(basename(f), "^[0-9]+m")
  read_tsv(f, show_col_types = FALSE) %>%
    mutate(
      Depth = depth,
      taxon = map_chr(Taxonomy, resolve_best_taxon),
      taxon = str_remove(taxon, "^[a-z]__")
    ) %>%
    filter(!is.na(taxon), !is.na(Abundance))
})

# Build average taxon-by-depth matrix
taxon_matrix <- all_classifications %>%
  group_by(Depth, taxon) %>%
  summarise(Abundance = mean(Abundance), .groups = "drop") %>%
  pivot_wider(names_from = Depth, values_from = Abundance, values_fill = 0) %>%
  arrange(taxon)

# Matrix setup
taxon_abund <- column_to_rownames(taxon_matrix, "taxon")
taxon_abund_t <- t(taxon_abund)  # Samples = rows, taxa = columns

# 4. Fit taxa vectors to PCoA
fit_taxa <- envfit(pcoa_scores[, 1:2], taxon_abund_t, permutations = 999)

# 5. Build vector df with r² and p-values
vectors_df <- as.data.frame(scores(fit_taxa, display = "vectors"))
vectors_df$taxon <- rownames(vectors_df)
vectors_df$r2 <- round(fit_taxa$vectors$r, 2)
vectors_df$pval <- fit_taxa$vectors$pvals

# 6. Filter for significance and top 10 by length
top_vectors <- vectors_df %>%
  filter(pval < 0.05) %>%
  slice_max(order_by = sqrt(PCoA1^2 + PCoA2^2), n = 10) %>%
  mutate(label = paste0(taxon, " (R²=", r2, ", p=", signif(pval, 2), ")"))

# 7. Plot

png("pcoa_taxa_kr.png", width = 2200, height = 2000, res = 300)  # res = 300 for publication quality

ggplot(pcoa_scores, aes(x = PCoA1, y = PCoA2, label = Depth)) +
  geom_point(size = 5, color = "orchid4") +
  geom_text(size = 4, vjust = -1.2) +
  
  geom_segment(data = top_vectors,
               aes(x = 0, y = 0, xend = PCoA1, yend = PCoA2),
               arrow = arrow(length = unit(0.3, "cm")),
               color = "black", linewidth = 1.0,
               inherit.aes = FALSE) +
  
  geom_text_repel(data = top_vectors,
                  aes(x = PCoA1, y = PCoA2, label = label),
                  color = "black", size = 2.6,
                  max.overlaps = 20,
                  inherit.aes = FALSE) +
  
  theme_minimal(base_size = 14) +
  labs(
    title = "PCoA (KR Distance) with Taxonomic Vectors (nirK Carriers)",
    x = "PCoA Axis 1", y = "PCoA Axis 2"
  )
dev.off()
