
# run with bash
#samplesheet_part1="results/samplesheets/sgls/lc.sgls_finemap_with_hichip.samplesheet.part1.txt"
#bash workflow/qscripts/finemap/causal_db/lc.sgls_finemap_with_hichip.qarray.qsh $samplesheet_part1 1

###############################################################################
# run batch1 with parts
###############################################################################

# samplesheet_part1="results/samplesheets/finemap_sgls/batch1/lc.sgls_finemap_with_hichip.samplesheet.part1.txt"
# #sbatch --array=1-999 --export="samplesheet=$samplesheet_part1" workflow/scripts/finemap_sgls/causal_db/lc.sgls_finemap_with_hichip.qarray.qsh

samplesheet_part2="results/samplesheets/finemap_sgls/batch1/lc.sgls_finemap_with_hichip.samplesheet.part2.txt"
sbatch --array=1-45 --export="samplesheet=$samplesheet_part2" workflow/scripts/finemap_sgls/causal_db/lc.sgls_finemap_with_hichip.qarray.qsh

###############################################################################
# run batch2
###############################################################################
#samplesheet="results/samplesheets/finemap_sgls/batch2/lc.sgls_finemap_with_hichip.samplesheet.txt"
#sbatch --array=1-162 --export="samplesheet=$samplesheet" workflow/scripts/finemap_sgls/causal_db/lc.sgls_finemap_with_hichip.qarray.qsh

###############################################################################
# run biorep-merged
###############################################################################
#samplesheet="results/samplesheets/finemap_sgls/biorep_merged/lc.sgls_finemap_with_hichip.samplesheet.txt"
#sbatch --array=1-180 --export="samplesheet=$samplesheet" workflow/scripts/finemap_sgls/causal_db/lc.sgls_finemap_with_hichip.qarray.qsh

###############################################################################
# run mega-merged
###############################################################################
#samplesheet="results/samplesheets/finemap_sgls/mega-merged/lc.sgls_finemap_with_hichip.samplesheet.txt"
#sbatch --array=1 --export="samplesheet=$samplesheet" workflow/scripts/finemap_sgls/causal_db/lc.sgls_finemap_with_hichip.qarray.qsh
#sbatch --array=1-108 --export="samplesheet=$samplesheet" workflow/scripts/finemap_sgls/causal_db/lc.sgls_finemap_with_hichip.qarray.qsh

#bash workflow/scripts/finemap_sgls/causal_db/lc.sgls_finemap_with_hichip.qarray.qsh $samplesheet 23

