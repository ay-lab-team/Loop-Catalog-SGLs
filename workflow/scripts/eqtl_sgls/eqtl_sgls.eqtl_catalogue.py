import os 
import pandas as pd
import numpy as np
import pybedtools as pbt 
import argparse
from collections import namedtuple

############# Create a commmand line interface #############
# gwas file must include: 
# loop file must include:
# gene coords file must include: 

# Create an argument parser
parser = argparse.ArgumentParser(description='Perform an analysis of fine mapped GWAS and HiChIP loops.')

# Define the arguments
parser.add_argument('--eqtl', dest='eqtl_fn', type=str, required=True, help='File path of the fine mapped GWAS file.')
parser.add_argument('--loop', dest='loop_fn', type=str, required=True, help='File path of the HiChIP loop file.')
parser.add_argument('--gene-coords', type=str, required=True, help='File path of the gene coordinates.')
parser.add_argument('--output', type=str, required=True, help='Output save the results, including the output directory.')
parser.add_argument('--bedtools-path', type=str,
                                        required=True,
                                        help='File path of the HiChIP loop file.')

# Parse the arguments
args = parser.parse_args()

# set bedtools path
pbt.set_bedtools_path(args.bedtools_path)

############# Load GENCODE Data #############
gencode = pd.read_table(args.gene_coords, header=None)
gencode.columns = ['gene_chrom', 'gene_start', 'gene_end', 'gene_strand', 'gene_type', 'gene_id', 'gene_name']
gencode = gencode.loc[gencode.gene_type == 'gene']
gencode.reset_index(inplace=True)

# add tss coordinates
def get_tss(sr):
    if sr.gene_strand == '+':
        return([sr.gene_start, sr.gene_start + 1])
    else:
        return([sr.gene_end - 1, sr.gene_end])
tss_df = pd.DataFrame(gencode.apply(get_tss, axis=1).tolist())
tss_df.columns = ['tss_start', 'tss_end']
gencode = pd.concat([gencode, tss_df], axis=1)

############# Load eQTL Data #############
eqtl_df = pd.read_table(args.eqtl_fn)

# extract variant coordinates
variant_df = pd.DataFrame(eqtl_df.variant.apply(lambda x: x.split('_')[0:2]).tolist())
variant_df.columns = ['snp_chrom', 'snp_end']
variant_df.loc[:, 'snp_end'] = variant_df.loc[:, 'snp_end'].astype(int)
variant_df.loc[:, 'snp_start'] = variant_df.loc[:, 'snp_end'] - 1  
eqtl_df = pd.concat([eqtl_df, variant_df], axis=1)


############# Merge eQTL with GENCODE Data #############
# merge eqtls with gencode coordinates
eqtl_df = eqtl_df.merge(gencode, on='gene_id', how='left', indicator=True)

# extract the complete and lost eqtls
#lost_eqtls = eqtl_df.loc[eqtl_df['_merge'] != 'both']
complete_eqtls = eqtl_df.loc[eqtl_df['_merge'] == 'both']

# remove chr
complete_eqtls.loc[:, 'snp_chrom'] = complete_eqtls.loc[:, 'snp_chrom'].str.replace('chr', '')
complete_eqtls.loc[:, 'gene_chrom'] = complete_eqtls.loc[:, 'gene_chrom'].str.replace('chr', '')

# reorder the columns
complete_eqtls = complete_eqtls[['snp_chrom', 'snp_start', 'snp_end',
                                'gene_chrom', 'tss_start', 'tss_end',
                                'molecular_trait_id', 'gene_id', 'cs_id', 'variant', 'rsid',
                                'cs_size', 'pip', 'pvalue', 'beta', 'se', 'z', 'cs_min_r2', 
                                'region', 'gene_start', 'gene_end', 'gene_strand', 'gene_type', 'gene_name']]
complete_eqtls.sort_values(['snp_chrom', 'snp_start', 'snp_end', 'gene_chrom', 'gene_start', 'gene_end'], inplace=True)

# create a pybedtools for finemap data
eqtl_pbt = pbt.BedTool.from_dataframe(complete_eqtls)

############# Load HiChIP Loops #############
loop_df = pd.read_table(args.loop_fn)
loop_df.rename(columns={'chr1': 'loop_chrA', 
                        's1': 'loop_startA', 
                        'e1': 'loop_endA',
                        'chr2': 'loop_chrB', 
                        's2': 'loop_startB', 
                        'e2': 'loop_endB'}, inplace=True)

# calculating the -log10(q value)
loop_df['-log10_qval'] =  loop_df['Q-Value_Bias'].apply(lambda x: -np.log(x))

# removing chr
loop_df['loop_chrA'] = loop_df['loop_chrA'].str.replace('chr', '') 
loop_df['loop_chrB'] = loop_df['loop_chrB'].str.replace('chr', '') 

# create a dataframe in bed format which filters for significant
# SNPs only p-val < 0.05 (or -log10(p-val) > 1.3)
loop_bed = loop_df.iloc[:, [0,1,2,3,4,5,-1]]

# create a pybedtools for the looping data
loop_pbt = pbt.BedTool.from_dataframe(loop_bed)


############# Intersect Fine Mapped GWAS and loops #############

# #### Perform the intersection

# intersecting the eQTLs with loops 
# need to use **{} because is=True doesn't work so the workaround is to use
# dictionary expansions
intersect_pbt = loop_pbt.pair_to_pair(eqtl_pbt, **{'type': 'both', 'is': True})

# # convert the intersection into a dataframe and rename columns 
eqtl_hichip = intersect_pbt.to_dataframe(header=None, disable_auto_names=True)

if len(eqtl_hichip) == 0:
    print('No overlap between GWAS and HiChIP loops. Exiting.')
    #exit()
    
# adding the header columns
eqtl_hichip.columns = loop_bed.columns.tolist() + complete_eqtls.columns.tolist()


# saving the intersection
print('# saving the intersection')
eqtl_hichip.to_csv(args.output, sep='\t', index=False)