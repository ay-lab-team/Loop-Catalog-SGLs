
fns=""
for gwas_source in $(cat config/gwas_samplesheets/gwas.samplesheet.tsv | sed '1d' | cut -f 1);
do
    fns+="$fn results/main/ldpairs/${gwas_source}/ld_analysis.txt"
    break
done

echo $fns

#snakemake --profile workflow/profiles/pbs-torque/ $fns
#snakemake --profile workflow/profiles/local/ $fns

