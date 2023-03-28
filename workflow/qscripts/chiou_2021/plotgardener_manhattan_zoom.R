library(plotgardener)
library(stringr)
library(plyr)

# Collecting command line arguments
# 1. GWAS summary statistics (TSV format)
# 2. Output path for SVG
#args = commandArgs(trailingOnly=TRUE)
#ss = 'results/main/chiou_2021/processing/finemapping/finemapping.gaulton.tsv'
ss = 'results/main/chiou_2021/processing/finemapping/finemapping.gaulton.tsv'
ld = 'results/main/ldpairs/T1D_34012112_Gaulton/ld_analysis.txt'
outdir = 'results/main/chiou_2021/local_manhattan/'
args = c(ss, ld, outdir)

dir.create(args[3], recursive = TRUE, showWarnings = FALSE)

## Load GWAS data
gwas_ss <- read.table(args[1], sep='\t', header = TRUE)

## Load LD data
ld_data <- read.table(args[2], sep='\t', header = TRUE)

##### Process LD information
### Plot GWAS data zooming in on chromosome 11
### highlighting a lead SNP, and coloring by LD score
#gwas_ss$LD <- as.numeric(gwas_ss$LD)
### Group LD column into LD ranges
#gwas_ss <- as.data.frame(dplyr::group_by(gwas_ss,
#                                                   LDgrp = cut(
#                                                       gwas_ss$LD,
#                                                       c(0, 0.2, 0.4, 0.6, 0.8, 1))))
#gwas_ss$LDgrp <- addNA(gwas_ss$LDgrp)


plot_gwas_ss <- function(chrom, start, end, ss){

    return
}

colnames(gwas_ss) <- c("chrom", "pos", "snp", "p",
                       "Signal.name", "Major.allele",
                       "Minor.allele", "Unique.ID..hg38.",
                       "Position..hg38.")
gwas_ss["chrom"] <- as.character(gwas_ss[,"chrom"])

# adding chr for visualization
if (sum(c("chr", "Chr") %in% gwas_ss["chrom"]) == 0){
    gwas_ss[,"chrom"] <- paste0("chr",  gwas_ss[,"chrom"])
}

# setting the color palette 
indigo =  "#1f4297"
teal = "#37a7db"
green = "green"
white = "yellow"
orange = "orange"
red = "red"
grey = "grey"
fill_palette = c(teal, green, white, orange, red, grey)
names(fill_palette) <- c("0", "0.2", "0.4", "0.6", "0.8", "1")
legend_palette = c(indigo, red, orange, white, green, teal, grey)


plot_specs = list(xlim=c())

# loopingn through different signals
uniq_signals <- unlist(unique(gwas_ss["Signal.name"]))
for (signal_name in uniq_signals){
    
    signal_name = 'PTPN22_1:114377568:A:G'
    signal_name = 'NEURL4_17:7240391:C:T'
    
    print(signal_name)
    
    ## Open an SVG device
    tmp_fn = paste0(signal_name, '.svg')
    tmp_fn = str_replace_all(tmp_fn, ':', '_')
    tmp_fn = file.path(args[3], tmp_fn)
    
    ## Extract the SNPs from the current signal
    curr_idxs = which(gwas_ss["Signal.name"] == signal_name)
    
    offset = 0
    if (length(curr_idxs) == 1){
        next
        #offset = 1000
    }
    curr_df = gwas_ss[curr_idxs,]
    example = curr_df[1,]
    
    ## Create an SVG
    #svg(tmp_fn, width = 8.0, height = 3)
    
    ## Create a page
    pageCreate(width = 7.5, height = 2, default.units = "inches")

    ## Extract the lead SNP
    leadSNP_pp <- max(curr_df$p)
    leadSNP <- gwas_ss[which(gwas_ss$p == leadSNP_pp),]$snp
    
    ## Get the left and right bounds
    print("## Get the left and right bounds")
    left_pos = min(curr_df$pos) - offset
    left_pos = plyr::round_any(left_pos, 1000, floor) 
    
    right_pos = max(curr_df$pos) + offset
    right_pos = plyr::round_any(right_pos, 1000, ceiling)
    
    # add current LD information
    print("# add current LD information")
    curr_ld = ld_data[which(ld_data$rsID == leadSNP),]
    merge_df = merge.data.frame(curr_df, curr_ld,
                     by.x="snp", by.y="ld_rsID", all.x=TRUE)
    
    merge_df <- as.data.frame(dplyr::group_by(merge_df,
                                               LDgrp = cut(
                                                       merge_df$LD,
                                                       c(0, 0.2, 0.4, 0.6, 0.8, 1))))

    merge_df$LDgrp <- addNA(merge_df$LDgrp)
    
    merge_df <- dplyr::rename(merge_df, pos="pos.x")
    
    # get the uniq ld groups
    # uniq_ld_grps = as.vector(unique((merge_df[["LDgrp"]])))
    # uniq_ld_grps = str_split(uniq_ld_grps, ',')
    # uniq_ld_grps = lapply(uniq_ld_grps, function(x){x[[2]]})
    # uniq_ld_grps = str_replace(uniq_ld_grps, ']', '')
    # 
    # curr_colors = sapply(uniq_ld_grps, function(x){fill_palette[x]})
    
    ## Plot the manhattan plot
    print("## Plot the manhattan plot")
    chr11_manhattanPlot <- plotManhattanGeneral(
        data = merge_df,
        chrom = example[1,"chrom"],
        chromstart = left_pos,
        chromend = right_pos,
        assembly = "hg19",
        fill = colorby("LDgrp",
                   palette = colorRampPalette(fill_palette)),
        sigLine = FALSE,
        col = "grey",
        lty = 2,
        range = c(0, 1),
        leadSNP = list(
            snp = leadSNP,
            pch = 18,
            cex = 0.75,
            fill = "#7ecdbb",
            fontsize = 8
        ),
        x = 0.5, y = 0, width = 5,
        height = 1.5,
        just = c("left", "top"),
        default.units = "inches"
    )
    
    ## Plot legend for LD scores
    print("## Plot legend for LD scores")
    plotLegend(
        legend = c(
            "LD Ref Var",
            paste("1", ">", "r^2", "", ">=", "0.8"),
            paste("0.8", ">", "r^2", "", ">=", "0.6"),
            paste("0.6", ">", "r^2", "", ">=", "0.4"),
            paste("0.4", ">", "r^2", "", ">=", "0.2"),
            paste("0.2", ">", "r^2", "", ">=", "0"),
            "no LD data"
        ),
        fill = legend_palette, cex = 0.75,
        pch = c(18, 19, 19, 19, 19, 19, 19),
        border = FALSE, x = 7, y = 0.5,
        width = 1.5, height = 0.8,
        just = c("right", "top"),
        default.units = "inches"
    )
    
    
    ## Annotate genome label
    annoGenomeLabel(
        plot = chr11_manhattanPlot, x = 0.5, y = 1.5,
        fontsize = 8, scale = "Kb", 
        just = c("left", "top"), default.units = "inches",
        commas = TRUE
    )
    
    ## Annotate y-axis
    annoYaxis(
        plot = chr11_manhattanPlot,
        at = c(0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1),
        axisLine = TRUE, fontsize = 8
    )

    ## Plot y-axis label
    plotText(
        label = "PPA", x = 0.1, y = 0.75, rot = 90,
        fontsize = 8, fontface = "bold", just = "center",
        default.units = "inches"
    )
    
    ## Add title label
    plotText(label = signal_name, x=3.75, y=0,
             fontsize = 14, just = "center",
             default.units = "inches")
    
    ## Add distance
    dist_label = (right_pos - left_pos) / 1000
    dist_label = paste0("Dist: ", dist_label, "Kb")
    
    ## Add num SNPs label
    nsnps_label = length(curr_df)
    nsnps_label = paste0("No. SNPs: ", nsnps_label)
    
    ## Add num SNPs with PPA > 0.10
    nppa10_label = sum(curr_df["p"] > 0.1)
    nppa10_label = paste0("No. SNPs PPA > 0.1: ", nppa10_label)
    
    info_label = paste(dist_label, nsnps_label, nppa10_label, sep="\n")
    plotText(label = info_label, x=6.375, y=0.15,
             fontsize = 8, just = "center",
             default.units = "inches")

    ## Hide page guides
    pageGuideHide()
    
    #dev.off()
    
    break
    
}




