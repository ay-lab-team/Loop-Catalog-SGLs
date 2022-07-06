#PBS -l nodes=1:ppn=1
#PBS -l mem=4gb
#PBS -l walltime=100:00:00
#PBS -e results/main/coloc/logs/
#PBS -o results/main/coloc/logs/
#PBS -N raw_colocs_to_washu_refbed
#PBS -d .
#PBS -V

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

# load helper functions and paths
source workflow/qscripts/helper_functions.sh

# start message
echo "Start Job"

echo "Running script: $0" 

# extracting sample information
IFS=$'\t'
samplesheet="config/coloc_samplesheets/coloc.samplesheet.tsv"
run_info=( $(sed -n "${PBS_ARRAYID}p" $samplesheet) )
echo "Using samplesheet: ${samplesheet}"
gwas_source=${run_info[0]}
eqtl_source=${run_info[1]}
ge_source=${run_info[2]}
IFS=$'\n\t' # can go back to using \n\t

if [[ "$eqtl_source" == "ImmuNexUT" ]]
then
    eqtl_db="ImmuNexUT"
else
    eqtl_db="eQTL_Catalogue"
fi

# printing log information
echo "gwas_source: $gwas_source"
echo "eqtl_db: $eqtl_db"
echo "eqtl_source: $eqtl_source"
echo "ge_source: $ge_source"
echo

# setting the input paths
coloc="results/main/GRCh37/coloc/Results/${eqtl_db}/${gwas_source}/${eqtl_source}/${ge_source}/FINAL_Summary_Coloc_Gene_SNP_Pairs.bed"
gencode="results/refs/gencode/v30/gencode.v30.annotation.grch37.genes_only.bed"
echo "input.coloc: ${coloc} - $(path_exists $coloc)"
echo "input.gencode: ${gencode} - $(path_exists $gencode)"
echo

# setting the output paths
outfn="results/main/GRCh37/coloc/Results/${eqtl_db}/${gwas_source}/${eqtl_source}/${ge_source}/FINAL_Summary_Coloc_Gene_SNP_Pairs.gene_sorted.with_gene_meta.bed.gz"
echo "outfn: ${outfn} - $(path_exists $outfn)"
echo

# setting the params paths
coloc_geneid_col=10
gencode_geneid_col=6


# stop running if output exists
if [[ -e "${outfn}" ]]
then
    echo "output.outfn: ${outfn} already exists."
    echo "Not running the rest of this script."

    # end message
    #echo "End Job: Already Exists"
    #exit
fi


# make output directories that are not present 
mkdir -p $(dirname ${outfn})


# sort gencode by geneid before joining
# assuming there is a header
echo "# sort gencode by geneid before joining"
gencode_geneid_sorted="results/refs/gencode/v30/gencode.v30.annotation.grch37.genes_only.geneid_sorted.bed"
if [[ ! -e "$gencode_geneid_sorted" ]]
then
    cmd="sed '1d' $gencode | sort -k $gencode_geneid_col > $gencode_geneid_sorted"
    echo "Running: ${cmd}"
    echo
    eval $cmd
fi


# locating the SampleSize columns
if head -n 1 $coloc | grep "SampleSize";
then
    ss_col=$(head -n 1 $coloc | sed 's/\t/\n/g' | nl | grep SampleSize | cut -f 1 | sed 's/\s//g')
else
    ss_col=""
fi


# remove SampleSize column when present
echo "# remove SampleSize column when present"
fix_wgenes="results/main/GRCh37/coloc/Results/${eqtl_db}/${gwas_source}/${eqtl_source}/${ge_source}/FINAL_Summary_Coloc_Gene_SNP_Pairs.tmp.txt"
if [[ "$ss_col" != "" ]]
then
    echo "SampleSize is present, removing column $ss_col"
    cut -f $ss_col --complement $coloc > $fix_wgenes
else
    echo "SampleSize not present, nothing done."
    cp $coloc $fix_wgenes
    chmod 644 $fix_wgenes
fi 


# sort coloc by geneid before joining
# assuming there is a header
echo "# sort coloc by geneid before joining"
coloc_geneid_sorted="results/main/GRCh37/coloc/Results/${eqtl_db}/${gwas_source}/${eqtl_source}/${ge_source}/FINAL_Summary_Coloc_Gene_SNP_Pairs.gene_sorted.tsv"
read -r cmd << EOM
sed '1d' $fix_wgenes \
    | awk 'BEGIN{OFS="\t"}; {geneid=gensub(/(ENSG[0-9]*)\.[0-9]*/, "\\\\1", 1, \$$coloc_geneid_col); print geneid, \$0}' \
    | sort -k 1 \
    > $coloc_geneid_sorted
EOM
echo "Running: ${cmd}"
echo
eval $cmd


# add gencode gene data
echo "# add gencode gene data"
coloc_wgenes="results/main/GRCh37/coloc/Results/${eqtl_db}/${gwas_source}/${eqtl_source}/${ge_source}/FINAL_Summary_Coloc_Gene_SNP_Pairs.gene_sorted.with_gene_meta.tsv"
read -r cmd << EOM
join -1 1 -2 $gencode_geneid_col -t $'\t' $coloc_geneid_sorted $gencode_geneid_sorted \
    | cut -f 1 --complement \
    > $coloc_wgenes
EOM
echo "Running: ${cmd}"
echo
eval $cmd




# reorganize and get the columns for bedpe format
# feature will be the combination of chr, pos and geneid
echo "# reorganize and get the columns for bedpe format"
#{ID = \$1 ":" \$2 ":" \$31; \
coloc_refbed="results/main/GRCh37/coloc/Results/${eqtl_db}/${gwas_source}/${eqtl_source}/${ge_source}/FINAL_Summary_Coloc_Gene_SNP_Pairs.gene_sorted.with_gene_meta.bed"

read -r cmd << EOM
sed "s/chr//g" $coloc_wgenes \
    | awk 'BEGIN{OFS="\t"}; \
                {ID = \$1 ":" \$2 ":" \$31; \
                if (\$2 < \$27){ \
                     start = \$2 - 1; \
                     end = \$28; \
                     snp_exon_start = \$2 - 1; \
                     snp_exon_end = \$2 + 10; \
                     exon_starts = snp_exon_start "," \$27; \
                     exon_ends = snp_exon_end "," \$28; \
                     strand = "+"; \
                     extra = "PP4=" \$7 " rsID="  \$8 " dist=" \$11 " gwas_source=$gwas_source eqtl_source=$eqtl_source ge_source=$ge_source";} \
                 else if (\$2 > \$28){ \
                     start = \$27 - 1; \
                     end = \$2; \
                     snp_exon_start = \$2 - 10; \
                     snp_exon_end = \$2 - 1; \
                     exon_starts = \$27 "," snp_exon_start ; \
                     exon_ends = \$28 "," snp_exon_end ; \
                     strand = "-"; \
                     extra = "PP4=" \$7 " rsID="  \$8 " dist=" \$11 " gwas_source=$gwas_source eqtl_source=$eqtl_source ge_source=$ge_source";} \
                 else if (\$2 >= \$27 && \$2 <= \$28){ \
                     start = \$27 - 1; \
                     end = \$28 + 1; \
                     snp_exon_start = \$2 - 1; \
                     snp_exon_end = \$2; \
                     exon_starts = snp_exon_start; \
                     exon_ends = snp_exon_end; \
                     strand = "."; \
                     extra = "PP4=" \$7 " rsID="  \$8 " dist=" \$11 " gwas_source=$gwas_source eqtl_source=$eqtl_source ge_source=$ge_source";} \
                 print "chr" \$1, start, end, start, end, strand, ID, \$10, "Coloc", exon_starts, exon_ends, extra;}' \
    | sort -k1n -k2n -k3n \
    > $coloc_refbed
EOM
echo "Running: ${cmd}"
echo
eval $cmd


# bgzip + tabix
echo "# bgzip + tabix"
cmd="${bgzip} -f ${coloc_refbed}; $tabix ${coloc_refbed}.gz"
echo "Running: ${cmd}"
echo
eval $cmd

exit

# remove intermediate files
echo "# remove intermediate files"
cmd="rm $gencode_geneid_sorted $coloc_geneid_sorted $coloc_wgenes"
echo "Running: ${cmd}"
echo
eval $cmd


# end message
echo "End Job"
