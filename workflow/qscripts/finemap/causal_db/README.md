To Run:

1) Create the necessary samplesheet with:
    ```bash workflow/qscripts/finemap/causal_db/lc.sgls_finemap_with_hichip.create.samplesheet.sh```

2) Submit SGL jobs with:
    ```squeue workflow/qscripts/finemap/causal_db/lc.sgls_finemap_with_hichip.run.sh```
    This script will call `./lc.sgls_finemap_with_hichip.run.sh` for each line in 
    the samplesheet `./lc.sgls_finemap_with_hichip.samplesheet`