## Directory structure
The working directory for this readme is considered:
```
workflow/scripts/causal_db_sgls
```

In some cases you have to run scripts from the project directory:
```
/mnt/BioHome/jreyna/jreyna/projects/Loop-Catalog-SGLs
```


<br>


## Setup the loop data 
For the analysis we are focused on "Immune-associated" samples only. To extract these samples simple
go to: (DONE)
```
https://loopcatalog.lji.org/loops/?genome=hg38
```

In the search bar look for "Immune-associated" and filter for samples that have at least one 5kb interaction. Click CSV to download a samplesheet into: (DONE)

```
results/samplesheets/finemap_sgls/
```

<br>

Symlink the loopcatalog storage drive for access to loop data: (DONE)
```
ln -s /mnt/BioAdHoc/Groups/vd-ay/hichip-db-loop-calling/results/loopcatalog/release-0.1/hub/hg38/loops results/hg38/
```


<br>


## Process the CAUSALdb fine-mapping studies

1) Convert the Fine-mapped SNPs to hg38 with: (DONE)
    ```
        finemap_snps.hg38_conversion.ipynb (Jupyter)
    ```

2) Summarize the fine-mapping results with: (DONE)
    ```
        finemap_snps.summary.with_rgbpeaks.ipynb (Jupyter)
    ```

<br>


## Intersect and determine the SGLs
1) Download the Fine-mapped SNPs metadata and create the necessary samplesheet with:
    ```
        bash workflow/scripts/causal_db_sgls/create_samplesheet.sh
    ```

    The samplesheet will be stored over at: `results/samplesheets/causal_db_sgls/sgls_finemap_with_hichip.samplesheet.txt`
    
2) Intersect loops, SNPs and genes using SGE jobs with:
    ```
        bash workflow/scripts/causal_db_sgls/sgls_finemap_with_hichip.commander.sh
    ```
    This script will call `workflow/scripts/causal_db_sgls/sgls_finemap_with_hichip.qarray.qsh` for each line in the samplesheet `results/samplesheets/causal_db_sgls/sgls_finemap_with_hichip.samplesheet.txt`




3) Summarize the fine-mapping SGL results with:
    ```
        lc.sgls_finemap_with_hichip.summary.ipynb (Jupyter)
    ```
