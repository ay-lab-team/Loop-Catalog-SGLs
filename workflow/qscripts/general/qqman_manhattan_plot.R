library("qqman")
library("stringr")
library("data.table")

# make sure not to create a default pdf
if(!interactive()) pdf(NULL)

# command line arguments
args = commandArgs(trailingOnly=TRUE)
gwas_res = args[1]
#gwas_res = "results/main/gwas/source/T1D_25751624/GRCh37/GWAS_input_colocalization_pval_lt_5eMinus8.txt"
#gwas_res = "results/main/gwas/source/T1D_25751624/GRCh37/GWAS_input_colocalization.txt"
target_snps = args[2]
figure_fn = args[3]


# loading snps of interest
print("# loading snps of interest")
snpsOfInterest = scan(target_snps, what=character())
print(snpsOfInterest)

# writing snps for debugging
fwrite(as.list(snpsOfInterest), 'test.snpsOfInterest.txt', sep='\n')

# loading and processing gwas data
print("# loading and processing data")
gwasResults = read.table(gwas_res, nrows=-1, header=T)
#gwasResults = read.table(gwas_res, nrows=1000, header=T)
gwasResults$CHR  = as.integer(str_replace(gwasResults$CHR, "chr", ""))
gwasResults$SNP = paste(gwasResults$CHR, gwasResults$POS, sep='-') 

# setting all p-values over a large value as 1 * 10^(-10)
# for visualization purposes
gwasResults[gwasResults$P < 1*10^(-10), "P"] = 1 * 10^(-10)

# writing table to debugging
write.table(gwasResults, 'test.gwasResults.tsv', sep='\t')

# filter snpsOfInterest for those in the gwas results
snpsOfInterest = snpsOfInterest[snpsOfInterest %in% gwasResults$SNP]

# plotting and saving
print("# plotting and saving")
par(mar=c(0.1,0.1,0.1,0.1))
res_factor = 2
png(figure_fn, width=800 * res_factor, height=400 * res_factor)

# Make the Manhattan plot on the gwasResults dataset
manhattan(gwasResults, chr="CHR", bp="POS",
               snp="SNP", p="P", highlight = snpsOfInterest, 
               annotatePval = 1 * 10^(-8),
               ylim = c(0, 12))
dev.off()
