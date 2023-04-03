#!/bin/bash
loopcatalog_select="config/sgl_samplesheets/loopcatalog.immune_select_samples.txt"
samplesheet="workflow/qscripts/finemap/lc.sgls_finemap_with_hichip.samplesheet.txt"

for sample in $(cat $loopcatalog_select);
do 
    fn="results/hg38/loops/hichip/chip-seq/macs2/stringent/${sample}.5000.interactions_FitHiC_Q0.01.bed"
    if [[ -f $fn ]];
    then
        echo $fn >> $samplesheet
    fi
done