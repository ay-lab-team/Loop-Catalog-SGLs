
## Intersect and determine the SGLs

1) Create the necessary samplesheet with:
```
(jupyter) workflow/scripts/eqtl_sgls/create_samplesheet.ipynb
```

2) Run and generate sgls
```
bash eqtl_sgls.eqtl_catalogue.commander.sh # submits the qsub jobs
```

The following scripts contain the undering code:
```
eqtl_sgls.eqtl_catalogue.py # performs the intersections
eqtl_sgls.eqtl_catalogue.qarray.qsh # qsub script
```

# extra
eqtl_sgls.eqtl_catalogue.ipynb - helper for `eqtl_sgls.eqtl_catalogue.py`
