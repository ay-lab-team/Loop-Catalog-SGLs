# #!/bin/bash

#################################################
# get causal db data
#################################################

# download the causal_db samplesheet
gwas_samplesheet_url="https://loopcatalog.lji.org/storage/release-0.1/database/hg38/gwas_study/init.gwas_study.causal_db.tsv"
gwas_samplesheet="workflow/qscripts/finemap/causal_db/init.gwas_study.causal_db.tsv"
if [[ ! -f "$gwas_samplesheet" ]];
then 
    curl -o $gwas_samplesheet $gwas_samplesheet_url 
fi

# extract the 5 main diseases
gwas_imm_samplesheet="workflow/qscripts/finemap/causal_db/init.gwas_study.causal_db.immune_select_samples.tsv"
awk 'BEGIN{
        t1d = "Diabetes Mellitus, Type 1";
        ps = "Psoriasis";
        ra = "Arthritis, Rheumatoid";
        ms = "None"
        ad = "Dermatitis, Atopic"

        list[1] = t1d;
        list[2] = ps;
        list[3] = ra;
        list[4] = ad;

        FS = "\t";
        OFS = "\t";
    }
    {
        if ($3 == list[1] || $3 == list[2] || $3 == list[3] || $3 == list[4]) {
            print $0;
        }
    }' $gwas_samplesheet > $gwas_imm_samplesheet

#################################################
# Make the FM SGL samplesheet
#################################################
loopcatalog_imm_select="config/sgl_samplesheets/loopcatalog.immune_select_samples.txt"
sgl_samplesheet="workflow/qscripts/finemap/causal_db/lc.sgls_finemap_with_hichip.samplesheet.txt"

# create an empty file
truncate -s 0 $sgl_samplesheet

# cycle through gwas
lji_causaldb_dir="/mnt/bioadhoc-temp/Groups/vd-ay/sourya/Projects/2020_IQTL_HiChIP/Data/CausalDB/"
sgl_dir="results/hg38/finemapping/sgls/"
while IFS= read -r gwas_sample
do
    # get the gwas file path
    gwas_id=$(echo "$gwas_sample" | awk 'BEGIN{FS="\t";} {print $19}' | tr -d '\r')
    gwas_fn="${lji_causaldb_dir}/credible_set/${gwas_id}_total_credible_set.txt"

    # get the sgl dir
    sgl_gwas_dir="${sgl_dir}/${gwas_id}/"

    # cycle through loop
    for loop_sample in $(cat $loopcatalog_imm_select);
    do 
        loop_fn="results/hg38/loops/hichip/chip-seq/macs2/stringent/${loop_sample}.5000.raw.loops.bed"
        output_fn="${sgl_gwas_dir}/${loop_sample}.5000.finemap_sgls.tsv"

        if [[ -f $loop_fn ]];
        then
            echo -e "${gwas_fn}\t${loop_fn}\t${output_fn}" >> $sgl_samplesheet
        fi
    done

done < "$gwas_imm_samplesheet"






#mkdir -P $sgl_gwas_dir
