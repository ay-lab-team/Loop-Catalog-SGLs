# setting important paths
hichip_db_py="/mnt/BioAdHoc/Groups/vd-ay/jreyna/software/mambaforge/envs/hichip-db/bin/python"
hichip_db_R="/mnt/BioApps/R/3.6.1/bin/R"
hichip_db_Rscript="/mnt/BioApps/R/3.6.1/bin/Rscript"
bgzip="/mnt/BioApps/tabix/tabix-0.2.6/bgzip"
tabix="/mnt/BioApps/tabix/tabix-0.2.6/tabix"
bcftools="/mnt/BioAdHoc/Groups/vd-ay/jreyna/software/mambaforge/envs/hichip-db/bin/bcftools"
bedtools="/mnt/BioHome/jreyna/software/bedtools/bin/bedtools"

# defining a named array for the chromsize files
hg38_chromsize="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/hg38.chrom.sizes"
mm10_chromsize="/mnt/BioAdHoc/Groups/vd-ay/Database_HiChIP_eQTL_GWAS/Data/RefGenome/chrsize/mm10.chrom.sizes"
t2t_chromsize="/mnt/bioadhoc-temp/Groups/vd-ay/kfetter/hichip-db-loop-calling/ref_genome/chm13_refgenome/chrsize/chm13.chrom.sizes"
declare -A chromsizes=(
  ["hg38"]="$hg38_chromsize"
  ["mm10"]="$mm10_chromsize"
  ["t2t-chm13-v2.0"]="$t2t_chromsize"
)

#Setting helper functions
function path_exists(){
    if [[ -e "$1" ]]
    then
        echo "Is-Present"
    else
        echo "Not-Present"
    fi
}

function bedgraph_to_bigwig() {
    bedgraph=$1
    chrom_sizes=$2
    bigwig=$3
    $bedGraphToBigWig $bedgraph $chrom_sizes $bigwig
}
