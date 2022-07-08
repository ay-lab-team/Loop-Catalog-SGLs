#########################################################################################
# Running all ImmuNexUT datasets
#########################################################################################
fns=""
while IFN= read -r line;
do
    # extracting run information
    run_info=($line)
    gwas_source="${run_info[0]}"
    eqtl_source="${run_info[1]}"
    ge_source="${run_info[2]}"
    fn="results/main/coloc/Results/ImmuNexUT/${gwas_source}/${eqtl_source}/${ge_source}/FINAL_Summary_Coloc_Gene_SNP_Pairs.bed"
    fns+="$fn "
done < <(sed '1d' config/coloc_samplesheets/coloc.samplesheet.tsv | grep -v "^#" | grep ImmuNexUT | head -n 1000)
echo $fns

# FULL Run
snakemake --profile workflow/profiles/pbs-torque/ $@ $fns
#snakemake --profile workflow/profiles/local/ $@ $fns
