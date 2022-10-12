foo <- function(){
    print('test')
}

#' #' make bins for the current col
#' add_bins_to_df <- function(df, col, 
#'  merge_df <- dplyr::group_by(df, LDgrp = cut(merge_df$LD, bins))
#'  merge_df <-as.data.frame(merge_df)
#'  merge_df$LDgrp <- addNA(merge_df$LDgrp)


plotGenes(
    chrom,
    chromstart = NULL,
    chromend = NULL,
    assembly = "hg38",
    fontsize = 8,
    fontcolor = c("#669fd9", "#abcc8e"),
    fill = c("#669fd9", "#abcc8e"),
    geneOrder = NULL,
    geneHighlights = NULL,
    geneBackground = "grey",
    strandLabels = TRUE,
    stroke = 0.1,
    bg = NA,
    x = NULL,
    y = NULL,
    width = NULL,
    height = unit(0.6, "inches"),
    just = c("left", "top"),
    default.units = "inches",
    draw = TRUE,
    params = NULL
)



plotGenes(
    geneBackground = "grey",
    x = NULL,
    y = NULL,
    width = NULL,
    height = unit(0.6, "inches"),
    just = c("left", "top"),
    params = params
)