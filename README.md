# Data and Code Availability – DDLPS Epidemiology and Survival Study (France)

This repository contains the analysis code used for the manuscript:

**“Descriptive analysis of epidemiology, demographic characteristics, and survival of dedifferentiated liposarcoma in France.”**

The repository provides a transparent overview of the analytical workflow used to generate:
- descriptive tables,
- survival analyses (OS, PFS1, PFS2),
- and supplementary material.

No individual‑level clinical data are shared, in accordance with French data protection regulations (CNIL) and institutional policies.

---

## Repository structure
01_data_preparation.sas 
02_tables.sas 
03_survival_figures.sas 
output/ (empty folder for user generated outputs) 
README.md

### **01_data_preparation.sas**
Template illustrating how analysis datasets were constructed from raw clinical sources.  
This script:
- imports raw datasets (placeholders only),
- harmonizes variable names,
- derives analysis covariates (age category, tumour size, ECOG, grade, site, MDM2 testing…),
- constructs analysis datasets:
  - `dataset_main`
  - `dataset_PFS1`
  - `dataset_PFS2`
  - `dataset_metastasis`
  - `dataset_local_relapse`
  - `dataset_relapse_comb`
  - `dataset_L1_flags`, `dataset_L2_flags`, `dataset_L3_flags`

No patient‑specific logic, corrections, or institution‑specific code is included.

### **02_tables.sas**
Generates all descriptive and clinical tables reported in the manuscript, using the `%Table1` macro from the AdClin library.

Tables include:
- Population characteristics  
- Local/systemic treatments  
- Metastatic disease description  
- Local relapse  
- Systemic treatments by line  
- Cox models (PFS1 and PFS2)

### **03_survival_figures.sas**
Generates all Kaplan–Meier survival curves using the `%NEWSURV` macro:
- OS (overall and stratified)
- PFS1 (overall and stratified)
- PFS2 (overall, stratified, and treatment‑specific)

---

## Software and dependencies

- **SAS 9.4**
- **AdClin macros**: `%Table1` and `%NEWSURV`
- Standard SAS procedures (`PROC PHREG`, `PROC SORT`, etc.)

No external R or Python dependencies.

---

## Data availability

The raw clinical datasets used in this study contain identifiable health information and **cannot be shared publicly** due to:
- CNIL regulations,
- institutional data protection policies,
- patient confidentiality requirements.

However:
- **all variable names used in the analyses are documented** in the scripts,
- **all analysis datasets are reconstructed in template form**, allowing readers to understand the analytical workflow,
- **all statistical procedures are fully reproducible** when applied to the original secured datasets.

---

##  Reproducibility statement

This repository provides:
- the full analysis code,
- the complete structure of all datasets used,
- the exact scripts used to generate tables and figures.

While the raw data cannot be shared, the analytical workflow is fully transparent and can be reproduced by authorized researchers with access to the original datasets.

---

## Citation

If you use or adapt this code, please cite:

> *Descriptive analysis of epidemiology, demographic characteristics, and survival of dedifferentiated liposarcoma in France.*  
Julien Bollard, Nicolas Penel, Thibaud Valentin, Robin Tranchant, Marie Najean,  
Christophe Maritaz, Maud Toulmonde, Matthieu Faron, Axel Le Cesne, Florence Duffaud,  
Alice Hervieu, Nelly Firmin, Emmanuelle Bompas, Sixtine de Percin, Christophe Perrin,  
Pascale Dubray Longeras, Thomas Ryckewaert, Françoise Ducimetière, Claire Chemin,  
Christophe Bouvier, Magali Morelle, Jean Yves Blay, Mehdi Brahmi, Sarah Watson.

Manuscript submitted, 2026.

---

## Contact

For questions regarding the analysis code, please contact the corresponding author of the manuscript.
