
# run with bash
#samplesheet_part1="results/samplesheets/sgls/lc.sgls_finemap_with_hichip.samplesheet.part1.txt"
#bash workflow/qscripts/finemap/causal_db/lc.sgls_finemap_with_hichip.qarray.qsh $samplesheet_part1 1

###############################################################################
# run with sbatch
###############################################################################

samplesheet="results/samplesheets/causal_db_sgls/sgls_finemap_with_hichip.m_loops.samplesheet.txt"
#sbatch --array=1 --export="samplesheet=$samplesheet,offset=0" workflow/scripts/causal_db_sgls_m_loops/sgls_finemap_with_hichip.qarray.qsh
sbatch --array=1-1000 --export="samplesheet=$samplesheet,offset=0" workflow/scripts/causal_db_sgls_m_loops/sgls_finemap_with_hichip.qarray.qsh
sbatch --array=1-422 --export="samplesheet=$samplesheet,offset=1000" workflow/scripts/causal_db_sgls_m_loops/sgls_finemap_with_hichip.qarray.qsh