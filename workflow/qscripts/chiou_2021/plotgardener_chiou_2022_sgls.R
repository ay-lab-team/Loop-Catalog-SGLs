library(plotgardener)
library(stringr)
library(dplyr)
source('workflow/qscripts/chromoloopR/chromoloopR.R')
## Load hg19 genomic annotation packages
library("TxDb.Hsapiens.UCSC.hg19.knownGene")
library("org.Hs.eg.db")

## Set colors
cols <- c("#41B6C4", "#225EA8")

# Collecting command line arguments
# 1. GWAS summary statistics (TSV format)
# 2. Output path for SVG
#args = commandArgs(trailingOnly=TRUE)
#ss = 'results/main/chiou_2021/processing/finemapping/finemapping.gaulton.tsv'
ss = 'results/main/chiou_2021/processing/finemapping/finemapping.gaulton.tsv'
ld = 'results/main/ldpairs/T1D_34012112_Gaulton/ld_analysis.txt'
sgls = 'results/main/chiou_2021/analysis/intersect_cs_with_loops/sgls.tsv'
genes = 'results/refs/gencode/v30/gencode.v30.annotation.grch37.genes_only.bed'
outdir = 'results/main/chiou_2021/analysis/intersect_cs_with_loops/'
args = c(ss, ld, sgls, genes, outdir)

dir.create(args[5], recursive = TRUE, showWarnings = FALSE)


## Load GWAS data
gwas_ss <- read.table(args[1], sep='\t', header = TRUE)

## Load LD data
ld_data <- read.table(args[2], sep='\t', header = TRUE)

## Load SGL data
sgls <- read.table(args[3], sep='\t', header = TRUE)

## Load gene data
genes <- read.table(args[4], sep='\t', header=TRUE)

## Set colors
cols <- c("#41B6C4", "#225EA8")

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
ld_colors = list(indigo =  "#1f4297",
                    teal = "#37a7db",
                    green = "green",
                    white = "yellow",
                    orange = "orange",
                    red = "red",
                    grey = "grey")
fill_palette = c(ld_colors$teal, ld_colors$green, ld_colors$white,
                 ld_colors$orange, ld_colors$red, ld_colors$grey)
legend_palette = c(ld_colors$indigo, ld_colors$red, ld_colors$orange,
                   ld_colors$white, ld_colors$green, ld_colors$teal,
                   ld_colors$grey)


db_symbols <- select(org.Hs.eg.db, keys = keys(org.Hs.eg.db),
                     columns = c('SYMBOL'), keytype = 'ENTREZID')
db_symbols <- db_symbols$SYMBOL
# looping through different signals
uniq_snp_signals <- unlist(unique(gwas_ss["Signal.name"]))
uniq_loop_signals <- unlist(unique(sgls["snp_Signal.name"]))

for (signal_name in uniq_loop_signals){

    # signal_name = 'PTPN22_1:114377568:A:G'
    # print(signal_name)
    
    #############################################
    ## Extract the manhattan data
    #############################################
    
    ## Extract the SNPs from the current signal
    curr_idxs = which(gwas_ss["Signal.name"] == signal_name)
    offset = 5000
    if (length(curr_idxs) == 1){
        next
        #offset = 1000
    }
    curr_df = gwas_ss[curr_idxs,]
    
    ## extract an example for meta-data
    example = curr_df[1,]

    ## Extract the lead SNP
    leadSNP_pp <- max(curr_df$p)
    leadSNP <- gwas_ss[which(gwas_ss$p == leadSNP_pp),]$snp
    
    # add current LD information
    curr_ld = ld_data[which(ld_data$rsID == leadSNP),]
    merge_df = merge.data.frame(curr_df, curr_ld,
                     by.x="snp", by.y="ld_rsID", all.x=TRUE)
    
    # convert LD to bin information
    bins = c(0, 0.2, 0.4, 0.6, 0.8, 1)
    merge_df <- dplyr::group_by(merge_df, LDgrp = cut(merge_df$LD, bins))
    merge_df <-as.data.frame(merge_df)
    merge_df$LDgrp <- addNA(merge_df$LDgrp)
    merge_df <- dplyr::rename(merge_df, pos="pos.x")
    
    #############################################
    ## Extract the loop data
    #############################################
    
    ## Translate dist/lengths into heights
    curr_sgls = sgls[which(sgls$snp_Signal.name == signal_name),]
    curr_sgls$h <- curr_sgls$loop_dist / max(curr_sgls$loop_dist)
    
    #############################################
    ## Set the coordinates using loop info
    #############################################
    
    ## Get the left and right bounds
    print("## Get the left and right bounds")
    left_pos = min(curr_sgls$startA) - offset
    left_pos = plyr::round_any(left_pos, 1000, floor) 
    
    right_pos = max(curr_sgls$endB) + offset
    right_pos = plyr::round_any(right_pos, 1000, ceiling)
    
    # set params to plot in plotgardener 
    params <- pgParams(
        chrom =  example[1,"chrom"],
        chromstart = left_pos,
        chromend = right_pos,
        assembly = 'hg19',
        width = 6.5)
    
    #############################################
    ## Prepare plotting devices
    #############################################
    
    ## Open an SVG device
    tmp_fn = paste0(signal_name, '.svg')
    tmp_fn = str_replace_all(tmp_fn, ':', '_')
    tmp_fn = file.path(args[5], tmp_fn)
    
    shared_height = 5.25
    svg(tmp_fn, width = 8.0, height = shared_height)
    
    ## Create a page
    pageCreate(width = 8, height = shared_height, default.units = "inches")
    
    #############################################
    ## Plot the manhattan plot
    #############################################
    print('## Plot the manhattan plot')
    skip = FALSE   
    tryCatch(expr={
        manhattan_y = 0.1
        print("## Plot the manhattan plot")
        chr11_manhattanPlot <- plotManhattanGeneral(
            data = merge_df,
            params = params, 
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
            x = 0.5, y = manhattan_y,
            height = 1.5,
            just = c("left", "top"),
            default.units = "inches")
        
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
            border = FALSE, x = 7, y = 0.6,
            width = 1.5, height = 0.8,
            just = c("right", "top"),
            default.units = "inches"
        )
        
        ## Annotate genome label
        annoGenomeLabel(
            plot = chr11_manhattanPlot,
            x = 0.5,
            y = 1.6,
            fontsize = 8,
            scale = "Kb", 
            just = c("left", "top"),
            default.units = "inches",
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
            label = "PPA", x = 0.1, y = 0.85, rot = 90,
            fontsize = 8, fontface = "bold", just = "center",
            default.units = "inches"
        )
        
        ## Add title label
        plotText(label = signal_name, x=3.75, y=0.3,
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
        plotText(label = info_label, x=6.375, y=0.3,
                 fontsize = 8, just = "center",
                 default.units = "inches")
        
        #############################################
        ## Plot genes 
        #############################################
        curr_ugenes = unique(curr_sgls$gene_name)
        curr_symbols = db_symbols[which(db_symbols %in% curr_ugenes)]
        highlights = data.frame(gene=curr_symbols, rep('red', length(curr_symbols)))
        genesPlot <- plotGenes(
            params = params,
            fill = cols,
            assembly='hg19', 
            fontcolor = cols,
            geneHighlights = highlights,
            x = 0.5, y = 1.7, height = 0.75,
            just = c("left", "top"),
            default.units = "inches"
        )
        
        #############################################
        ## Plot the loop data
        #############################################
        archPlot <- plotPairsArches(
            data = curr_sgls,
            params = params,
            fill = colorby("score", palette = 
                               colorRampPalette(c("dodgerblue2", "firebrick2"))),
            linecolor = "fill",
            style = '2D', 
            archHeight = "h",
            alpha = 1,
            x = 0.5,
            y = 2.45,
            height = 2,
            just = c("left", "top"),
            default.units = "inches", 
            flip = TRUE
        )
    
        
        ## Annotate heatmap legend
        annoHeatmapLegend(
            plot = archPlot, fontcolor = "black",
            x = 7.5, y = 2.425,
            width = 0.10,
            height = 1.25,
            fontsize = 10
        )
        
        ## Add the heatmap legend title
        plotText(
            label = "-log10(score)", rot = 90, x=7.4, y = 3.05,
            just = c("center", "center"),
            fontsize = 10
        )
        
        ## Hide page guides
        pageGuideHide()
        
        dev.off()
    
    },
    error = function(x){
        print(paste0('Problem with ', signal_name, ' ', x))
        dev.off()
        file.remove(tmp_fn)
        skip=TRUE},
    finally = {print('done')}
    )
    
    print(skip)
    if (skip == TRUE){
        print('skipped')
        next
    }
}




