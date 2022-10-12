library("qqman")
library("stringr")
library("data.table")
library(dplyr)

# We will use ggrepel for the annotation
library(ggrepel)

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
#gwasResults = read.table(gwas_res, nrows=1000000, header=T)

# sample the dataframe for testing
#print("# sample the dataframe for testing")
#gwasResults = gwasResults[sample(nrow(gwasResults), 10000), ]

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
png(figure_fn, width=800 * res_factor, height=400 * res_factor)

# Prepare the dataset
print("# Prepare the dataset")
don <- gwasResults %>% 
      
    # Compute chromosome size
    group_by(CHR) %>% 
    summarise(chr_len=max(POS)) %>% 

    # Calculate cumulative position of each chromosome
    mutate(tot=cumsum(as.numeric(chr_len))-chr_len) %>%
    select(-chr_len) %>%

    # Add this info to the initial dataset
    left_join(gwasResults, ., by=c("CHR"="CHR")) %>%

    # Add a cumulative position of each SNP
    arrange(CHR, POS) %>%
    mutate( POScum=POS+tot) %>%

    # Add highlight and annotation information
    mutate( is_highlight=ifelse(SNP %in% snpsOfInterest, "yes", "no"))
    #mutate( is_annotate=ifelse(SNP %in% snpsOfInterest, "yes", "no")) 

# Prepare X axis
print("# Prepare X axis")
axisdf <- don %>% group_by(CHR) %>% summarize(center=( max(POScum) + min(POScum) ) / 2 )

# Make the plot
print("# Make the plot")
ggplot(don, aes(x=POScum, y=-log10(P))) +

    # Show all points
    geom_point( aes(color=as.factor(CHR)), alpha=0.8, size=1.3) +
    scale_color_manual(values = rep(c("grey", "skyblue"), 22 )) +

    # custom X axis:
    scale_x_continuous( label = axisdf$CHR, breaks= axisdf$center ) +

    # Set the ylim to 0 and 12
    scale_y_continuous(expand = c(0, 0), limit=c(0,12)) +     # remove space between plot area and x axis
    #ylim(0, 12) + 

    # Add highlighted points
    geom_point(data=subset(don, is_highlight=="yes"), color="orange", size=2) +

    # Add label using ggrepel to avoid overlapping
    #geom_label_repel( data=subset(don, is_annotate=="yes"), aes(label=SNP), size=2) +
    #geom_label_repel( data=subset(don, is_highlight=="yes"), aes(label=SNP), size=2) +

    # Custom the theme:
    theme_bw() +
    theme( 
    legend.position="none",
    panel.border = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
    )

dev.off()

