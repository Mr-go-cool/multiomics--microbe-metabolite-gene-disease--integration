# 📦 Load required libraries
library(readr)
library(readxl)
library(dplyr)
library(stringr)
library(writexl)
library(igraph)
library(ggraph)
library(tidyverse)

# 📂 1. Load Input Files
microbiome_data <- read_csv("C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/processed_species_microbiome.csv")
metabolomics_data <- read_excel("C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/metabolomics_data.xlsx")
microbe_metabolite <- read_csv("C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/microbe_metabolite_mapping.csv")
metabolite_gene <- read_csv("C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/metabolite_gene_mapping.csv")

# 🧼 2. Clean the Data
microbiome_data <- microbiome_data %>%
  mutate(Taxon_name_Cleaned = str_trim(str_remove(Taxon_name, "\\[|\\]")))

microbe_metabolite <- microbe_metabolite %>%
  mutate(
    Microbe_Cleaned = str_trim(str_remove(`Gut Microbe (ID)`, "\\(.*\\)")),
    Metabolite_Cleaned = str_trim(str_remove(`Metabolite (ID)`, "\\(.*\\)"))
  )

metabolite_gene <- metabolite_gene %>%
  mutate(
    Metabolite_Cleaned = str_trim(str_remove(`Metabolite (ID)`, "\\(.*\\)")),
    Gene_Symbol = str_trim(str_remove(`Gene (ID)`, "\\(.*\\)"))
  )

metabolomics_data <- metabolomics_data %>%
  mutate(Metabolite_Cleaned = str_trim(METABOLITES))

# 🔗 3. Microbe → Metabolite Mapping
microbe_metabolite_matched <- inner_join(
  microbiome_data,
  microbe_metabolite,
  by = c("Taxon_name_Cleaned" = "Microbe_Cleaned")
)

microbe_metabolite_links <- microbe_metabolite_matched %>%
  select(Microbe = Taxon_name_Cleaned, Abundance = Percentage, Metabolite = Metabolite_Cleaned) %>%
  distinct()

write_xlsx(microbe_metabolite_links,
           "C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/microbe_metabolite_links.xlsx")

# 🔗 4. Metabolite → Gene Mapping
metabolite_gene_matched <- inner_join(
  microbe_metabolite_links,
  metabolite_gene,
  by = c("Metabolite" = "Metabolite_Cleaned")
)

write_xlsx(
  metabolite_gene_matched,
  "C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/metabolite_gene_links.xlsx"
)

# 🔗 5. Create Microbe → Metabolite → Gene Mapping
microbe_metabolite_gene <- microbe_metabolite_links %>%
  inner_join(metabolite_gene, by = c("Metabolite" = "Metabolite_Cleaned")) %>%
  select(Microbe, Abundance, Metabolite, Gene_Symbol, Alteration, Evidence, `Evidence Number`) %>%
  distinct()

write_xlsx(
  microbe_metabolite_gene,
  "C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/microbe_metabolite_gene_links.xlsx"
)

# 📁 6. Merge Multiple Disease–Gene Files
files <- c(
  "C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/diseases/nutrition all.xlsx",
  "C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/diseases/endo crine all.xlsx",
  "C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/diseases/digestive all.xlsx",
  "C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/diseases/cvd all.xlsx"
)

combined_data <- files %>%
  lapply(read_excel) %>%
  bind_rows() %>%
  select(gene, disease)

write_xlsx(combined_data,
           "C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/diseases/all_disease_gene_association.xlsx")

# 🔗 7. Combine Gene–Disease Mapping
disease_gene_data <- read_excel("C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/diseases/all_disease_gene_association.xlsx") %>%
  rename(Gene_Symbol = gene)

microbe_gene_disease_mapping <- microbe_metabolite_gene %>%
  inner_join(disease_gene_data, by = "Gene_Symbol")

write_xlsx(
  microbe_gene_disease_mapping,
  "C:/Users/Nama Gokul/Downloads/microbiome_pro/try 4/microbe_metabolite_gene_disease_links_try2.xlsx"
)

# 🌐 8. Network Construction & Visualization
data <- microbe_gene_disease_mapping %>%
  mutate(across(everything(), as.character))

nodes <- tibble(
  id = unique(c(data$Microbe, data$Metabolite, data$Gene_Symbol, data$disease)),
  type = case_when(
    id %in% data$Microbe ~ "Microbe",
    id %in% data$Metabolite ~ "Metabolite",
    id %in% data$Gene_Symbol ~ "Gene",
    id %in% data$disease ~ "Disease",
    TRUE ~ NA_character_
  )
) %>% drop_na()

edges <- data %>%
  select(Microbe, Metabolite, Gene_Symbol, disease, Alteration) %>%
  pivot_longer(cols = c(Microbe, Metabolite, Gene_Symbol, disease),
               names_to = "type", values_to = "from") %>%
  group_by(from) %>%
  mutate(to = lead(from)) %>%
  filter(!is.na(to)) %>%
  mutate(color = ifelse(Alteration == "activation", "green", "red")) %>%
  ungroup() %>%
  select(from, to, color) %>%
  drop_na()

network <- graph_from_data_frame(d = edges, vertices = nodes, directed = TRUE)
nodes <- as.data.frame(nodes)
V(network)$label <- nodes$id

ggraph(network, layout = "fr") +
  geom_edge_link(aes(color = color), arrow = arrow(length = unit(3, "mm")), alpha = 0.8) +
  geom_node_point(aes(color = type), size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, size = 3) +
  scale_edge_color_manual(values = c("green" = "green", "red" = "red")) +
  scale_color_manual(values = c("Microbe" = "blue", "Metabolite" = "orange", "Gene" = "purple", "Disease" = "red")) +
  theme_void() +
  ggtitle("Microbe–Metabolite–Gene–Disease Network")
