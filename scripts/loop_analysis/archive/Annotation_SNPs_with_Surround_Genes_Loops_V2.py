#!/usr/bin/env python
# coding: utf-8

# # Make the master table

# In[1]:


import os 
import sys
import pybedtools as pbt
import pandas as pd
import numpy as np
import subprocess as sp
import json
os.chdir('/mnt/BioHome/jreyna/jreyna/projects/dchallenge/')
pbt.set_bedtools_path('/mnt/BioApps/bedtools/bin/')
bgzip = '/mnt/BioApps/tabix/tabix-0.2.6/bgzip'
tabix = '/mnt/BioApps/tabix/tabix-0.2.6/tabix'

bedpe_6cols = ['chrA', 'startA', 'endA', 'chrB', 'startB', 'endB']
bedpe_10cols = ['chrA', 'startA', 'endA', 'chrB', 'startB', 'endB', 'name', 'score', 'strand1', 'strand2']


# In[2]:


## default values for the command line
#sys.argv = [0] * 8
#sys.argv[1] =  'results/main/2021_Nikhil_eQTL/Results/Colocalization/T1D_34012112_Gaulton/'
#sys.argv[1] += 'DICE_eQTL_CD4_NAIVE/FINAL_Summary_Coloc_Gene_SNP_Pairs.bed'
#sys.argv[2] = 'results/refs/ensembl/gencode.v19.annotation.bed'
#sys.argv[3] = 'results/main/2021_Nikhil_eQTL/Data/FitHiChIP_Loops/CD4N/FitHiChIP_L/FitHiChIP.interactions_FitHiC_Q0.01.bed'
#sys.argv[4] = 'results/refs/spp/SPP_D-Challenge_networks.xlsx'
#sys.argv[5] = 'results/refs/hg19/hg19.chrom.sizes'
#sys.argv[6] = 'results/main/2021_Nikhil_eQTL/Data/eqtl_sqtl_summ_stats/DICE_eQTL/CD4_NAIVE.txt.gz'
#sys.argv[7] = 'results/main/loop_analysis/washU/'


# In[3]:


# parsing the commandline arguments
coloc_fn = sys.argv[1]
genes_fn = sys.argv[2]
loop_fn = sys.argv[3]
spp_fn = sys.argv[4]
gs_fn = sys.argv[5]
eqtl_fn = sys.argv[6]
outdir = sys.argv[7]

# setting the output file names
os.makedirs(outdir, exist_ok=True)


# ## Load the colocalization data

# In[18]:


# load the colocalization data
coloc = pd.read_table(coloc_fn)

# extract the most significant according the H4 
coloc_sig_df = coloc[coloc['pp_H4_Coloc_Summary'] > 0.75]
coloc_sig_full = coloc_sig_df.copy(deep=True)
coloc_sig_df.rename(columns={'pos': 'end'}, inplace=True)
coloc_sig_df.loc[:, 'start'] = coloc_sig_df.loc[:, 'end'] - 1

coloc_sig_df = coloc_sig_df[['chr', 'start', 'end', 'rs_id', 'variant_id']]
coloc_sig_df = coloc_sig_df.loc[~coloc_sig_df.duplicated(subset='rs_id'),]
coloc_sig_pbt = pbt.BedTool.from_dataframe(coloc_sig_df.iloc[:, 0:4]).sort()


# ## Load the gene data

# In[5]:


# load the gencode coords
cols = ['chrom', 'start', 'end', 'strand', 'type', 'gene_id', 'gname']
gencode = pd.read_table(genes_fn, header=None, names=cols)

# extract just the genes
genes_df = gencode.loc[gencode.type.isin(['gene'])]
genes_df = genes_df.loc[~genes_df.duplicated(subset='gene_id'), :]
genes_df.loc[:, 'chrom'] = genes_df['chrom'].astype(str)
genes_df = genes_df.iloc[:, [0,1,2,6,5]]
genes_pbt = pbt.BedTool.from_dataframe(genes_df).sort()


# ## Find all genes +/- 500kb

# In[6]:


# get a list of gene names within +- 500kb of the SNPs
fivekb_genes = coloc_sig_pbt.slop(b=500000, g=gs_fn)
fivekb_genes = fivekb_genes.intersect(genes_pbt, wa=True, wb=True)
fivekb_genes = fivekb_genes.to_dataframe().iloc[:, [0,1,2,4,5,6,3,7,8]]
fivekb_genes.columns = bedpe_6cols + ['rs_id', 'gname', 'gid']
fivekb_genes['startA'] += 500000
fivekb_genes['endA'] -= 500000


# In[7]:


fivekb_genes.head()


# ## Find the closest gene

# In[8]:


closest_gene = coloc_sig_pbt.closest(genes_pbt, d=True)
closest_gene = closest_gene.to_dataframe().iloc[:, [0,1,2,4,5,6,3,7,8,9]]
closest_gene.columns = bedpe_6cols + ['rs_id', 'gname', 'gid', 'dist']
closest_gene.set_index(['rs_id', 'gname'], inplace=True)

# get eQTL's
eqtls = pd.read_table(eqtl_fn)
eqtls.columns = ['eqtl_gname', 'nvar', 'shape1', 'shape2', 'dummy',
                 'sid', 'dist', 'npval', 'slope', 'ppval', 'bpval', 'qval']
#eqtls.set_index(['sid', 'eqtl_gname'], inplace=True)


# In[23]:


pd.read_table(eqtl_fn)


# ## Get the loops

# In[58]:


# load the loop data
loops = pd.read_table(loop_fn)
tmp_loops = loops[['chr1', 's1', 'e1', 'chr2', 's2', 'e2']]
tmp_loops.rename(columns={'p': 'score'}, inplace=True)
tmp_loops.loc[:, 'name'] = '.'
tmp_loops.loc[:, 'score'] = loops['p']
tmp_loops.loc[:, 'strand1'] = '.'
tmp_loops.loc[:, 'strand2'] = '.'
loops = pbt.BedTool.from_dataframe(tmp_loops)
print('FitHiChIP found {} significant loops.'.format(tmp_loops.shape[0]))


# #### Find out SNP - 5kb gene pairs with loops\
# re-arranging to fit bedpe format
fivekb_gloops = fivekb_genes.copy()
fivekb_gloops['dummy'] = 'drop'

# loading into pbt
fivekb_gloops = pbt.BedTool.from_dataframe(fivekb_gloops)
fivekb_gloops = fivekb_gloops.pair_to_pair(loops, type='both',  **{'is':True})
fivekb_gloops = fivekb_gloops.to_dataframe(disable_auto_names=True, header=None)
#fivekb_gloops = fivekb_gloops.iloc[:, [10, 11, 12, 13, 14, 15,6,7,8,17]]
#fivekb_gloops.columns = bedpe_6cols + ['rs_id', 'gname', 'gid', 'fithic_qval']


# In[67]:


fivekb_gloops_set = fivekb_gloops.iloc[:, [6,8]]
fivekb_gloops_uniq = set([tuple(x) for x in fivekb_gloops_set.values.tolist()])


# ## Construct master table

# In[128]:


# begin making the master
master = fivekb_genes.copy()
master['sid'] = master['chrA'].str.replace('chr', '') + ':' + master['endA'].astype(str)

# check for the closets gene
eqtl_check = [0] * master.shape[0]
closets_check = [0] * master.shape[0]
for i, sr in master.iterrows():

    # check closest gene
    rs_gene = (sr.rs_id, sr.gname)
    if rs_gene in closest_gene.index:
        closets_check[i] = 1

master['is_closest_gene'] = closets_check

# add eqtl results 
master = master.merge(eqtls, left_on=['sid', 'gname'], right_on=['sid', 'eqtl_gname'], how='left')

# add column to filter on eqtl snp status
master['is_eqtl_pair'] = (~master['ppval'].isna()).astype(int)


# In[129]:


# add colocalization data for SNP and is_coloc_snp columns
tmp_coloc = coloc_sig_full[[
 'pp_H0_Coloc_Summary',
 'pp_H1_Coloc_Summary',
 'pp_H2_Coloc_Summary',
 'pp_H3_Coloc_Summary',
 'pp_H4_Coloc_Summary',
 'rs_id',
 'geneName',
 'ref',
 'alt',
 'AC',
 'AF',
 'AN',
 'slope_gwas',
 'slope_se_gwas',
 'pval_nominal',
 'SampleSize']]
tmp_coloc.rename(columns={'slope_gwas': 'gwas_slope',
                          'slope_se_gwas': 'gwas_slope_se',
                          'pval_nominal': 'gwas_pval_nominal',
                          'geneName': 'gname'}, inplace=True)
master = master.merge(tmp_coloc, on=['rs_id', 'gname'], how='left')

# add column to filter on coloc snp status
master['is_coloc_pair'] = (~master['pp_H4_Coloc_Summary'].isna()).astype(int)


# In[130]:


# check for the loop gene
loop_check = [0] * master.shape[0]
for i, sr in master.iterrows():

    # check closest gene
    rs_gene = (sr.rs_id, sr.gid)
    if rs_gene in fivekb_gloops_uniq:
        loop_check[i] = 1

master['has_fithichip_loop'] = loop_check


# In[131]:


master = master[[
 'rs_id',
 'gname',
 'gid',
 'chrA',
 'endA',    
 'startB',
 'endB',
 'is_eqtl_pair',
 'is_coloc_pair',
 'is_closest_gene',
 'has_fithichip_loop',
 'sid',
 'nvar',
 'shape1',
 'shape2',
 'dist',
 'npval',
 'slope',
 'ppval',
 'bpval',
 'qval',
 'pp_H0_Coloc_Summary',
 'pp_H1_Coloc_Summary',
 'pp_H2_Coloc_Summary',
 'pp_H3_Coloc_Summary',
 'pp_H4_Coloc_Summary',
 'ref',
 'alt',
 'AC',
 'AF',
 'AN',
 'gwas_slope',
 'gwas_slope_se',
 'gwas_pval_nominal',
 'SampleSize']]


# In[132]:


master.rename(columns={'chrA':'chrom', 'endA': 'snp_pos', 
                       'startB': 'gene_start', 'endB': 'gene_end',
                       'gname': 'gene_name', 'gid': 'gene_id'}, inplace=True)


# In[133]:


master.sort_values(['chrom', 'snp_pos', 'gene_start', 'rs_id'], inplace=True)


# In[134]:


# write out the master data
fn = os.path.join(outdir, 'master.tsv')
master.to_csv(fn, sep='\t', header=True, index=False)

fn = os.path.join(outdir, 'master.xlsx')
excel_master = master.sort_values('rs_id').set_index('rs_id')
excel_master.to_excel(fn, na_rep='nan')

