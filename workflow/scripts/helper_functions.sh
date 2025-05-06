# setting important paths
hichip_db_py="<software-dir>/python"
hichip_db_R="<software-dir>/R"
hichip_db_Rscript="<software-dir>/Rscript"
bgzip="<software-dir>/tabix/tabix-0.2.6/bgzip"
tabix="<software-dir>/tabix/tabix-0.2.6/tabix"
bcftools="<software-dir>/hichip-db/bin/bcftools"
bedtools="<software-dir>/bedtools/bin/bedtools"

# defining a named array for the chromsize files
hg38_chromsize="<path-dir>/hg38.chrom.sizes"
mm10_chromsize="<path-dir>/mm10.chrom.sizes"
t2t_chromsize="<path-dir>/chm13.chrom.sizes"
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
