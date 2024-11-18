
# make the sample sheet
make_samplesheet.sh


# run and generate sgls
eqtl_sgls.eqtl_catalogue.py # performs the intersections
eqtl_sgls.eqtl_catalogue.qarray.qsh # qsub script
eqtl_sgls.eqtl_catalogue.commander.sh # submits the qsub jobs


# extra
eqtl_sgls.eqtl_catalogue.ipynb - helper for `eqtl_sgls.eqtl_catalogue.py`
