#!/bin/bash

# load helper functions and paths
source workflow/qscripts/helper_functions.sh

#####################################################################
# Unionize the loops
#####################################################################

# setting the path for the union file
union_fn="results/hg38/loops/immune.union.bed"

# cycle through loop
# loopcatalog_imm_select="config/sgl_samplesheets/loopcatalog.immune_select_samples.txt"
# for loop_sample in $(cat $loopcatalog_imm_select);
# do 
#     echo $loop_sample

#     loop_fn="results/hg38/loops/hichip/chip-seq/macs2/stringent/${loop_sample}.5000.raw.loops.bed"

#     if [[ -f $loop_fn ]];
#     then
#         sed '1d' $loop_fn >> $union_fn
#     fi
# done

#####################################################################
# Clean the file
#####################################################################

# echo "# Clean the file"
clean_fn="results/hg38/loops/immune.union.clean.bed"

# awk 'BEGIN{OFS="\t"};
# {
#     print $1, $2, $3, $4 ":" $5 "-" $6 ",1" ;
#     print $4, $5, $6, $1 ":" $2 "-" $3 ",1";
# }' $union_fn > $clean_fn

#####################################################################
# Sort the file
#####################################################################

echo "# Sort the file"
sorted_fn="results/hg38/loops/immune.union.sorted.bed"

sort -k1V -k2n -k3n -k4 -u $clean_fn | uniq > $sorted_fn

#####################################################################
# Compress and index the file
#####################################################################

echo "# Compress and index the file"

$bgzip -f $sorted_fn
$tabix -f "${sorted_fn}.gz"

#####################################################################
# Remove intermediate files
#####################################################################
echo "# Remove intermediate files"
rm $union_fn $clean_fn