# Interpreting Type 1 Diabetes GWAS signals with HiChIP

This is an SGL pipeline for SNP to Gene linking between CausalDB SNPs and Loop Catalog samples 
for Psoriasis, Type 1 Diabetes, Rheumatoid Arthritis, and Atopic Dermatitis. To run this pipeline the steps are as follows:

## To Run:
The working directory for this pipeline is considered: `workflow/qscripts/finemap/causal_db`

In some cases you have to run scripts from the project directory: `/mnt/BioHome/jreyna/jreyna-temp/projects/t1d-loop-catalog`

### Setup the data 
The Loop Catalog has attempted to classify the organ of samples. All "Immune-associated" will be used. To extract these samples simple
go to: (https://loopcatalog.lji.org/loops/?genome=hg38)[https://loopcatalog.lji.org/loops/?genome=hg38]. In the search bar look for "Immune-associated" and click CSV to download a samplesheet. From there you can do more filtering if necessary, for now I just extracted the standard sample names and directly pasted them into:

```
results/samplesheets/sgls/loopcatalog.immune_select_samples.txt
```

2) Symlink the LJI-LCSD for Access to Loops # COMPLETED
```
ln -s /mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/lji_lcsd_hub/release-0.1/hub/hg38/loops results/hg38/
```

### Process the CAUSALdb fine-mapping studies

1) Convert the Fine-mapped SNPs to hg38 with: # COMPLETED
    ```
        lc.finemap_snps.hg38_conversion.ipynb (Jupyter)
    ```

2) Summarize the fine-mapping results with: # COMPLETED
    ```
        lc.finemap_snps.summary.ipynb (Jupyter)
    ```

### Intersect and determine the SGLs
1) Download the Fine-mapped SNPs metadata

2) Create the necessary samplesheet with: # COMPLETED
    ```
        bash workflow/qscripts/finemap/causal_db/lc.sgls_finemap_with_hichip.create.samplesheet.sh
    ```

    The samplesheet will be stored over at: `results/samplesheets/sgls/{batch}/lc.sgls_finemap_with_hichip.samplesheet.txt`

3) Intersect loops, SNPs and genes using SGE jobs with: # IN PROGRESS ********************************************
    ```
        bash workflow/qscripts/finemap/causal_db/lc.sgls_finemap_with_hichip.commander.sh 
    ```
    This script will call `./lc.sgls_finemap_with_hichip.qarray.qsh` for each line in 
    the samplesheet.

3) Summarize the fine-mapping SGL results with:
    ```
        lc.sgls_finemap_with_hichip.summary.ipynb (Jupyter)
    ```
