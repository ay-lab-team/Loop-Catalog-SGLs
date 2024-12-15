## Beforehand
Run steps from the `causal_db_sgls/README.md`

## Intersect and determine the SGLs
1) Download the Fine-mapped SNPs metadata and create the necessary samplesheet with:
    ```
        bash workflow/scripts/causal_db_sgls/create_sgl_samplesheet.sh
    ```

    The samplesheet will be stored over at: `results/samplesheets/causal_db_sgls/sgls_finemap_with_hichip.m_loops.samplesheet.txt`
    
2) Intersect loops, SNPs and genes using SGE jobs with:
    ```
        bash workflow/scripts/causal_db_sgls/sgls_finemap_with_hichip.commander.sh
    ```
    This script will call `workflow/scripts/causal_db_sgls/sgls_finemap_with_hichip.qarray.qsh` for each line in the samplesheet `results/samplesheets/causal_db_sgls/sgls_finemap_with_hichip.samplesheet.txt`


3) Summarize the fine-mapping SGL results with:
    ```
        sgls_finemap_with_hichip.summary.ipynb (Jupyter)
    ```
