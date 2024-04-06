import os 
import pandas as pd
import numpy as np
import pybedtools as pbt 
import argparse

############# Create a commmand line interface #############
# gwas file must include: 
# loop file must include:
# gene coords file must include: 

# Create an argument parser
parser = argparse.ArgumentParser(description='Perform an analysis of fine mapped GWAS and HiChIP loops.')

# Define the arguments
parser.add_argument('--gwas', dest='gwas_fn', type=str, required=True, help='File path of the fine mapped GWAS file.')
parser.add_argument('--loop', dest='loop_fn', type=str, required=True, help='File path of the HiChIP loop file.')
parser.add_argument('--gene-coords', type=str, required=True, help='File path of the gene coordinates.')
parser.add_argument('--output', type=str, required=True, help='Output save the results, including the output directory.')
parser.add_argument('--res', type=int, required=False, default=5000, help='Resolution of the HiChIP loops.')
parser.add_argument('--bedtools-path', type=str,
                                        required=True,
                                        help='File path of the HiChIP loop file.')

# Parse the arguments
args = parser.parse_args()

# set bedtools path
pbt.set_bedtools_path(args.bedtools_path)

# make the directory to save our data
bedpe_cols = ['chrA', 'startA', 'endA', 'chrB', 'startB', 'endB']

############# Load Fine Mapped GWAS #############

# get the bin coordinates
gwas_df = pd.read_table(args.gwas_fn)
gwas_df['start'] = gwas_df['BP'] - 1
gwas_df.rename(columns={'CHR': 'chrom', 'BP': 'end'}, inplace=True)
gwas_df = gwas_df[['chrom', 'start', 'end']]

# create a pybedtools for finemap data
gwas_pbt = pbt.BedTool.from_dataframe(gwas_df)

############# Load HiChIP Loops #############
loop_df = pd.read_table(args.loop_fn)
loop_df['-log10_qval'] =  loop_df['Q-Value_Bias'].apply(lambda x: -np.log(x))
loop_df['chr1'] = loop_df['chr1'].str.replace('chr', '') 
loop_df['chr2'] = loop_df['chr2'].str.replace('chr', '') 

# create a dataframe in bed format which filters for significant
# SNPs only p-val < 0.05 (or -log10(p-val) > 1.3)
loop_bed = loop_df.iloc[:, [0,1,2,3,4,5,-1]]

# create a pybedtools for the looping data
loop_pbt = pbt.BedTool.from_dataframe(loop_bed)

############# Intersect Fine Mapped GWAS and loops #############

# #### Perform the intersection

# intersecting the GWAS SNPs with loops 
# loop anchor doesn't matter therefore type='either'
intersect_pbt = loop_pbt.pair_to_bed(gwas_pbt, type='either')

# # convert the intersection into a dataframe and rename columns 
gwas_hichip = intersect_pbt.to_dataframe(header=None, disable_auto_names=True)

if len(gwas_hichip) == 0:
    print('No overlap between GWAS and HiChIP loops. Exiting.')
    exit()
    
gwas_hichip.columns = ['chrA_loop', 'startA_loop', 'endA_loop',
                       'chrB_loop', 'startB_loop', 'endB_loop', 
                       '-log10_qval_loop', 'chr_snp', 'start_snp', 'end_snp']


############# Integrate genes and located SGLs #############
# For the types of SGLs through this approach we have to find identify loops where one anchor overlaps a SNP and the other one overlaps a gene promoter. As such, we used the previously intersected data to find loop anchors without a SNP overlap and we will intersect these anchors with gene promoters next. 

# ### Load the gene data and build promoter based pybedtool

print('# Load the gene data')

# load the gencode coords
cols = ['chrom', 'start', 'end', 'strand', 'type', 'gene_id', 'gname']
gencode = pd.read_table(args.gene_coords, header=None, names=cols)

# extract just the genes
genes_df = gencode.loc[gencode['type'].isin(['gene'])]
genes_df = genes_df.loc[~genes_df.duplicated(subset='gene_id'), :]
genes_df.loc[:, 'chrom'] = genes_df['chrom'].astype(str)
genes_df = genes_df.iloc[:, [0,1,2,6,5,3]]

# create a copy of the original gene bed before coordinate shrinking
orig_genes_df = genes_df.copy()

# convert the start/end position into start/end for the TSS
# if the gene is + then the start is uses as the tss otherwise
# the end is used as the tss
genes_df.loc[(genes_df.strand == '+'), 'end'] = genes_df.loc[(genes_df.strand == '+'), 'start']
genes_df.loc[(genes_df.strand == '+'), 'start'] = genes_df.loc[(genes_df.strand == '+'), 'start'] - 1
genes_df.loc[(genes_df.strand == '-'), 'end'] = genes_df.loc[(genes_df.strand == '-'), 'end']
genes_df.loc[(genes_df.strand == '-'), 'start'] = genes_df.loc[(genes_df.strand == '-'), 'end'] - 1
genes_df.loc[:, 'chrom'] = genes_df.loc[:, 'chrom'].str.replace('chr', '')
genes_df.loc[:, 'bin_start'] = (np.floor(genes_df.loc[:, 'start'] / args.res) * args.res).astype(int)
genes_df.loc[:, 'bin_end'] = genes_df.loc[:, 'bin_start'] + args.res

# make a genes pbt for intersection
print("# make a genes pbt for intersection")
print(genes_df.head())
genes_pbt = pbt.BedTool.from_dataframe(genes_df).sort()

print('There are {} genes in this GTF-derived file.'.format(genes_df.shape[0]))

# ### Determine which anchor the SNP falls into
snp_anchor = []
for i, sr in gwas_hichip.iterrows():
    if (sr.startA_loop <= sr.end_snp) & (sr.end_snp <= sr.endA_loop):
        snp_anchor.append('AnchorA')
    elif (sr.startB_loop <= sr.end_snp) & (sr.end_snp <= sr.endB_loop):
        snp_anchor.append('AnchorB')
    else:
        snp_anchor.append('bug')
        print('bug')
        break
gwas_hichip.loc[:, 'snp_anchor'] = snp_anchor

print('SNP anchor designation:', gwas_hichip['snp_anchor'].unique().tolist())

# ### Extract anchors opposite of a SNP anchor
# using a basic serial id for merging post bedtools intersection
gwas_hichip['gh_id'] = range(gwas_hichip.shape[0])

anchor_cols = ['chrB_loop', 'startB_loop', 'endB_loop', 'gh_id']
nonsnp_anchorsA = gwas_hichip.loc[gwas_hichip['snp_anchor'] == 'AnchorA', anchor_cols]
anchor_cols =  ['chrA_loop', 'startA_loop', 'endA_loop', 'gh_id']
nonsnp_anchorsB = gwas_hichip.loc[gwas_hichip['snp_anchor'] == 'AnchorB', anchor_cols]

nonsnp_anchorsA.columns = ['chr', 'start', 'end', 'gh_id']
nonsnp_anchorsB.columns = ['chr', 'start', 'end', 'gh_id']
nonsnp_anchors = pd.concat([nonsnp_anchorsA, nonsnp_anchorsB], axis=0)
nonsnp_anchors_pbt = pbt.BedTool.from_dataframe(nonsnp_anchors)

# ### Intersecting genes on anchors opposing a SNP anchor
gene_overlaps = nonsnp_anchors_pbt.intersect(genes_pbt, wa=True, wb=True)
gene_overlaps = gene_overlaps.to_dataframe(header=None, disable_auto_names=True)

print('The number of anchor gene overlaps is:', gene_overlaps.shape)
# gene_overlaps.head()

# ### Add gene overlaps to SNP-Loop Pairs
gene_overlaps.columns = ['chr_anchor', 'start_anchor', 'end_anchor', 'gh_id',
                         'chr_gene', 'start_gene', 'end_gene',
                         'genename', 'geneid', 'strand', 'bin_start', 'bin_end']
#gwas_hichip_genes = gwas_hichip.merge(gene_overlaps.drop(['', '', ''], axis=1), on=['gh_id'], how='inner')
gwas_hichip_genes = gwas_hichip.merge(gene_overlaps, on=['gh_id'], how='inner')
gwas_hichip_genes.drop(['gh_id', 'chr_anchor', 'start_anchor',
                        'end_anchor', 'bin_start', 'bin_end'], axis=1, inplace=True)

print('There are {} SGLs.'.format(len(gwas_hichip_genes)))
#print('There are {} unique SNPs within an SGL'.format(gwas_hichip_genes['rsid'].nunique()))
# gwas_hichip_genes

############# Save SGLs for Further Analyses #############
gwas_hichip_genes.to_csv(args.output,  sep='\t', index=False)