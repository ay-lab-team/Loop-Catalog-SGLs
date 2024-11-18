# samplesheet="results/samplesheets/eqtl_sgls/hichip_to_eqtl.samplesheet.tsv"
# sample_idx="1"

###############################################################################
# test running SGLs with Schmiedel_2018.CD4_T-cell_naive.CD4+-T-cell.naive
###############################################################################
# samplesheet="results/samplesheets/eqtl_sgls/QTD000479.Schmiedel_2018.CD4_T-cell_naive.CD4+-T-cell.naive.samplesheet.tsv"
# sample_idx="1"
# bash workflow/scripts/eqtl_sgls/eqtl_sgls.eqtl_catalogue.qarray.qsh $samplesheet $sample_idx

###############################################################################
# running SGLs for Schmiedel_2018.CD4_T-cell_naive.CD4+-T-cell.naive
###############################################################################
# samplesheet="results/samplesheets/eqtl_sgls/QTD000479.Schmiedel_2018.CD4_T-cell_naive.CD4+-T-cell.naive.samplesheet.tsv"
# num_lines=$(wc -l $samplesheet | cut -f 1 -d " ")
# sbatch --array="1-$num_lines" --export="samplesheet=${samplesheet}" workflow/scripts/eqtl_sgls/eqtl_sgls.eqtl_catalogue.qarray.qsh

###############################################################################
# running SGLs for QTD000489.Schmiedel_2018.CD8_T-cell_naive.CD8+-T-cell.naive
###############################################################################
# samplesheet="results/samplesheets/eqtl_sgls/QTD000489.Schmiedel_2018.CD8_T-cell_naive.CD8+-T-cell.naive.samplesheet.tsv"
# num_lines=$(wc -l $samplesheet | cut -f 1 -d " ")
# sbatch --array="1-$num_lines" --export="samplesheet=${samplesheet}" workflow/scripts/eqtl_sgls/eqtl_sgls.eqtl_catalogue.qarray.qsh

###############################################################################
# running SGLs for QTD000474.Schmiedel_2018.B-cell_naive.B-cell.naive
###############################################################################
# samplesheet="results/samplesheets/eqtl_sgls/QTD000474.Schmiedel_2018.B-cell_naive.B-cell.naive.samplesheet.tsv"
# num_lines=$(wc -l $samplesheet | cut -f 1 -d " ")
# sbatch --array="1-$num_lines" --export="samplesheet=${samplesheet}" workflow/scripts/eqtl_sgls/eqtl_sgls.eqtl_catalogue.qarray.qsh

###############################################################################
# running SGLs for QTD000504.Schmiedel_2018.monocyte_naive.monocyte.naive
###############################################################################
# samplesheet="results/samplesheets/eqtl_sgls/QTD000504.Schmiedel_2018.monocyte_naive.monocyte.naive.samplesheet.tsv"
# num_lines=$(wc -l $samplesheet | cut -f 1 -d " ")
# sbatch --array="1-$num_lines" --export="samplesheet=${samplesheet}" workflow/scripts/eqtl_sgls/eqtl_sgls.eqtl_catalogue.qarray.qsh

###############################################################################
# running SGLs for QTD000509.Schmiedel_2018.NK-cell_naive.NK-cell.naive
###############################################################################
# samplesheet="results/samplesheets/eqtl_sgls/QTD000509.Schmiedel_2018.NK-cell_naive.NK-cell.naive.samplesheet.tsv"
# num_lines=$(wc -l $samplesheet | cut -f 1 -d " ")
# sbatch --array="1-$num_lines" --export="samplesheet=${samplesheet}" workflow/scripts/eqtl_sgls/eqtl_sgls.eqtl_catalogue.qarray.qsh


###############################################################################
# running SGLs for QTD000499.Schmiedel_2018.monocyte_CD16_naive.CD16+-monocyte.naive
###############################################################################
# samplesheet="results/samplesheets/eqtl_sgls/QTD000499.Schmiedel_2018.monocyte_CD16_naive.CD16+-monocyte.naive.samplesheet.tsv"
# num_lines=$(wc -l $samplesheet | cut -f 1 -d " ")
# sbatch --array="1-$num_lines" --export="samplesheet=${samplesheet}" workflow/scripts/eqtl_sgls/eqtl_sgls.eqtl_catalogue.qarray.qsh













