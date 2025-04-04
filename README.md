# multiomics--microbe-metabolite-gene-disease--integration
A multi-omics integration pipeline in R to connect gut microbiome, metabolome, gene expression, and disease associations into a unified network for systems-level insights.


# 🧬 Multiomics Integration: Microbe–Metabolite–Gene–Disease Network

This project presents an R-based pipeline for building a multi-layered biological network that connects gut microbes, metabolites, genes, and diseases. The integration enables insights into how the gut microbiome may influence human health through molecular interactions.

---

## 📁 Input Files

### 1. **Microbiome Data**
**File:** `processed_species_microbiome.csv`  
- Derived from Kraken2 taxonomic classification.
- Filtered to include only species-level taxa and their relative abundance.

### 2. **Metabolomics Data**
**File:** `metabolomics_data.xlsx`  
- Raw metabolomics data mapped from mass spectrometry peaks to metabolite names.

### 3. **Microbe–Metabolite Mapping**
**File:** `microbe_metabolite_mapping.csv`  
- Sourced from the [gutMgene](https://bio-annotation.cn/gutmgene/) database.
- Contains mappings of gut microbes to the metabolites they produce.
- Includes interaction type: whether the metabolite is activated or inhibited by the microbe.

### 4. **Metabolite–Gene Mapping**
**File:** `metabolite_gene_mapping.csv`  
- Also sourced from the **gutMgene** database.
- Contains information on which metabolites activate or inhibit which genes.

### 5. **Gene–Disease Associations**
**Files:**
- `nutrition all.xlsx`
- `endo crine all.xlsx`
- `digestive all.xlsx`
- `cvd all.xlsx`

- Each file includes curated gene–disease associations across different systems (nutrition, endocrine, digestive, cardiovascular).
- Compiled and standardized for integration with other omics layers.

---

## 🔗 Workflow Summary

1. **Cleaning** of taxonomic, metabolite, and gene identifiers.
2. **Integration** of:
   - Microbes to metabolites
   - Metabolites to genes
   - Genes to diseases
3. **Network Construction** using `igraph` and `ggraph` to visualize:
   - Nodes: Microbes, Metabolites, Genes, Diseases
   - Edges: Biological interactions (activation/inhibition)

---

## 📊 Output

- Final combined network: **Microbe → Metabolite → Gene → Disease**
- Exported as Excel files at each integration step for reproducibility.
- Interactive visualization generated using `ggraph`.

---

## 📌 Future Directions

- Incorporate expression data for genes or metabolites.
- Add filtering for condition-specific associations.
- Extend network into a dynamic dashboard using Shiny or Streamlit.
