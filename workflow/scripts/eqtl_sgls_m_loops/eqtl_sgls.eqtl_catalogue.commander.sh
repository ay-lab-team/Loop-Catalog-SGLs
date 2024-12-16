###############################################################################
# running SGLs for ALL
###############################################################################
samplesheet="results/samplesheets/eqtl_sgls/hichip_to_eqtl.m_loops.samplesheet.tsv"
#sbatch --array=1 --export="samplesheet=${samplesheet}" workflow/scripts/eqtl_sgls_m_loops/eqtl_sgls.eqtl_catalogue.qarray.qsh
sbatch --array=1-243 --export="samplesheet=${samplesheet}" workflow/scripts/eqtl_sgls_m_loops/eqtl_sgls.eqtl_catalogue.qarray.qsh