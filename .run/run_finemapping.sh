
fns=""
ref_genome="GRCh37"
offset=1000000
#for gwas in $(cut -f 1 config/gwas_samplesheets/gwas.samplesheet.tsv | sed '1d' | grep -v "^#" | sed -n '1,3p');
for gwas in $(cut -f 1 config/gwas_samplesheets/gwas.samplesheet.tsv | sed '1d' | grep -v "^#" | sed -n '2p');
do
    fn="results/main/finemapping/${gwas}/${ref_genome}/offset_${offset}/Summary/sss/FINAL_top_snp_credible_set.txt"
    fns+="$fn "
done

#echo $fns | sed 's/ /\n/g'
snakemake --profile workflow/profiles/local $@ $fns
# snakemake --profile workflow/profiles/pbs-torque/ $@ $fns
