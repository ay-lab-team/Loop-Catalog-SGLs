set -euo pipefail
IFS=$'\n\t'

cd /mnt/bioadhoc-temp/Groups/vd-ay/jreyna-temp/projects/dchallenge/

## making finemap manhattan plots
#mkdir -p results/main/finemapping/manhattan/
#
#for gwas_source in T1D_32005708 T1D_34012112_Gaulton T1D_34594039_GCST90018925;
#do
#    echo $gwas_source 
#
#    # get gwas results file
#    gwas_res="results/main/gwas/source/${gwas_source}/GRCh37/GWAS_input_colocalization.txt"
#
#    # create a SNP file
#    finemap_sgl_data="results/main/finemapping/sgl_intersect/finemap_sgls.${gwas_source}.tsv"
#    finemap_sgl_snps="results/main/finemapping/sgl_intersect/finemap_sgls.${gwas_source}.snps.txt"
#    awk '{print $1 "-" $4}' $finemap_sgl_data | sed '1d' | sort | uniq > $finemap_sgl_snps
#
#    # get the gwas results file
#    gwas_fig="results/main/finemapping/manhattan/gwas_and_finemap_sgl_snps.${gwas_source}.png"
#
#    if [[ ! -f $gwas_fig ]];
#    then
#        #Rscript workflow/qscripts/general/qqman_manhattan_plot.R $gwas_res $finemap_sgl_snps $gwas_fig
#        Rscript workflow/qscripts/general/ggplot2_manhattan_plot.R $gwas_res $finemap_sgl_snps $gwas_fig
#    fi
#    #Rscript workflow/qscripts/general/qqman_manhattan_plot.R $gwas_res $finemap_sgl_snps $gwas_fig
#    #Rscript workflow/qscripts/general/ggplot2_manhattan_plot.R $gwas_res $finemap_sgl_snps $gwas_fig
#
#    # remove snp file
#    rm $finemap_sgl_snps
#
#done


## making pieQTL manhattan plots
#mkdir -p results/main/pieqtls/manhattan/
#
#for gwas_source in T1D_32005708 T1D_34012112_Gaulton T1D_34594039_GCST90018925;
#do
#    echo $gwas_source 
#
#    # get gwas results file
#    gwas_res="results/main/gwas/source/${gwas_source}/GRCh37/GWAS_input_colocalization.txt"
#
#    # create a SNP file
#    pieqtl_sgl_data="results/main/pieqtls/sgl_intersect/pieqtls_sgls.${gwas_source}.tsv"
#    pieqtl_sgl_snps=$pieqtl_sgl_data # tsv is actually already in the right format
#
#    # get the gwas results file
#    gwas_fig="results/main/pieqtls/manhattan/gwas_and_pieqtl_sgl_snps.${gwas_source}.png"
#
#    echo "Generating: $gwas_fig"
#
#    if [[ ! -f $gwas_fig ]];
#    then
#        #Rscript workflow/qscripts/general/qqman_manhattan_plot.R $gwas_res $pieqtl_sgl_snps $gwas_fig
#        Rscript workflow/qscripts/general/ggplot2_manhattan_plot.R $gwas_res $pieqtl_sgl_snps $gwas_fig
#    fi
#    #Rscript workflow/qscripts/general/qqman_manhattan_plot.R $gwas_res $pieqtl_sgl_snps $gwas_fig
#    #Rscript workflow/qscripts/general/ggplot2_manhattan_plot.R $gwas_res $pieqtl_sgl_snps $gwas_fig
#
#done

# making coloc manhattan plots
mkdir -p results/main/coloc/manhattan/

for gwas_source in T1D_32005708 T1D_34594039_GCST90018925 T1D_34012112_Gaulton;
do
    echo $gwas_source 

    # get gwas results file
    gwas_res="results/main/gwas/source/${gwas_source}/GRCh37/GWAS_input_colocalization.txt"

    # create a SNP file
    coloc_sgl_data="results/main/coloc/summary/coloc_sgs.${gwas_source}.tsv"
    coloc_sgl_snps=$coloc_sgl_data # tsv is actually already in the right format

    # get the gwas results file
    gwas_fig="results/main/coloc/manhattan/coloc_sg_snps.${gwas_source}.png"


    echo "gwas_res: $gwas_res"
    echo "coloc_sgl_data: $coloc_sgl_data"

    echo "Generating: $gwas_fig"

    if [[ ! -f $gwas_fig ]];
    then
        #Rscript workflow/qscripts/general/qqman_manhattan_plot.R $gwas_res $coloc_sgl_snps $gwas_fig
        Rscript workflow/qscripts/general/ggplot2_manhattan_plot.R $gwas_res $coloc_sgl_snps $gwas_fig
    fi
    #Rscript workflow/qscripts/general/qqman_manhattan_plot.R $gwas_res $coloc_sgl_snps $gwas_fig
    #Rscript workflow/qscripts/general/ggplot2_manhattan_plot.R $gwas_res $coloc_sgl_snps $gwas_fig

done
