# Performing LD Pair analysis for finemapped data
rule gwas_ss_ldpairs:
    input:
        snp_file = 'results/main/coloc/Data/T1D_GWAS/{gwas_source}/GRCh37/GWAS_input_colocalization_pval_lt_5eMinus8.txt',
        onekg_dir = '/mnt/BioAdHoc/Groups/vd-vijay/Ariel/R24_new/LD-snps-1000G/DupsRemoved/',
        population_dir = '/mnt/BioAdHoc/Groups/vd-vijay/Ariel/R24_new/LD-snps/lists-pops/',
        snpinfo_dir = '/mnt/BioAdHoc/Groups/vd-vijay/sourya/Projects/2020_IQTL_HiChIP/Data/SNPInfo/SNPInfo_merged_tables/'
    params:
        workdir = 'results/main/ldpairs/{gwas_source}/',
        chr_col = 1,
        pos_col = 2 
    resources:
        mem_mb = 20000
    output:
        ld = 'results/main/ldpairs/{gwas_source}/ld_analysis.txt'
    log:
        'results/main/ldpairs/{gwas_source}/finemapping_ld_snps.log'
    shell:
        r"""
            Rscript workflow/scripts/ldpairs/ldpair_with_plink.R \
                        --snp-file {input.snp_file} \
                        --onekg-dir {input.onekg_dir}/ \
                        --population-dir {input.population_dir}/ \
                        --snpinfo-dir {input.snpinfo_dir}/ \
                        --header \
                        --chr-col {params.chr_col} \
                        --pos-col {params.pos_col} \
                        --workdir {params.workdir}/
            #old_fn="{params.workdir}/Out_Merge_LD.txt"
            #mv $old_fn {output}
        """
