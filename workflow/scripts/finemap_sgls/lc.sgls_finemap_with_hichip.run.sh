#!/bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l mem=8gb
#PBS -l walltime=100:00:00
#SBATCH -e results/hg38/finemapping/sgls/logs/
#SBATCH -o results/hg38/finemapping/sgls/logs/
#PBS -N lc.sgls_finemap_with_hichip
#PBS -d .
#PBS -V

# print start time message
start_time=$(date "+%Y.%m.%d.%H.%M")
echo "Start time: $start_time"

# print start message
echo "Started: lc.sgls_finemap_with_hichip"

# # run bash in strict mode
set -euo pipefail
IFS=$'\n\t'

# dummy value when not running with qsub
echo
if [[ -z ${PBS_ARRAYID+x} ]]
then
    echo "Running with bash, setting PBS_ARRAYID=\$1=$1"
    PBS_ARRAYID=$1
else
    echo "Running with qsub, PBS_ARRAYID=$PBS_ARRAYID"
fi
echo

# getting the loop file name
gwas_fn="results/hg38/external_studies/chiou_2021/processing/finemapping/hg38.finemapping.basic.bed"
loop_fn=$(sed -n "${PBS_ARRAYID}p" workflow/scripts/finemap_sgls/lc.sgls_finemap_with_hichip.samplesheet.txt)
sample_name=$(basename $loop_fn | cut -d. -f1,2,3,4,5,6)
gene_coords="results/hg38/refs/gencode/v30/gencode.v30.annotation.bed"
prefix="results/hg38/finemapping/sgls/${sample_name}/${sample_name}."
res=5000

# test="true"
# if [[ "$test" == "true" ]]
# then
#     echo "Running in test mode"

#     # Define the paths to the required input files
#     gwas_fn="results/hg38/external_studies/chiou_2021/processing/finemapping/hg38.finemapping.basic.bed"
#     loop_fn="results/hg38/loops/hichip/chip-seq/macs2/loose/Jurkat.GSE99519.Homo_Sapiens.YY1.b1.25000.interactions_FitHiC_Q0.01.bed"
#     gene_coords="results/hg38/refs/gencode/v30/gencode.v30.annotation.bed"
#     prefix="results/hg38/finemapping/sgls/Jurkat.GSE99519.Homo_Sapiens.YY1.b1/Jurkat.GSE99519.Homo_Sapiens.YY1.b1.25000."
#     res=5000
# fi

# load helper functions and paths
source workflow/scripts/helper_functions.sh

# Define the path to bedtools
bedtools_path=$(dirname $bedtools)

# Run the Python script with the specified arguments
$hichip_db_py workflow/scripts/finemap_sgls/lc.sgls_finemap_with_hichip.py \
    --gwas "$gwas_fn" \
    --loop "$loop_fn" \
    --gene-coords "$gene_coords" \
    --prefix "$prefix" \
    --res 5000 \
    --bedtools-path "$bedtools_path"