library(plotgardener)

## Load paired ranges data in BEDPE format
library(plotgardenerData)
data("IMR90_DNAloops_pairs")

## Set the coordinates
params <- pgParams(
    chrom = "chr21",
    chromstart = 27900000, chromend = 30700000,
    assembly = "hg19",
    width = 7
)

## Create a page
pageCreate(width = 7.5, height = 2.1, default.units = "inches")

## Add a length column to color by
IMR90_DNAloops_pairs$length <- 
    (IMR90_DNAloops_pairs$start2 - IMR90_DNAloops_pairs$start1) / 1000

## Translate lengths into heights
IMR90_DNAloops_pairs$h <- 
    IMR90_DNAloops_pairs$length / max(IMR90_DNAloops_pairs$length)

## Plot the data
archPlot <- plotPairsArches(
    data = IMR90_DNAloops_pairs,
    params = params,
    fill = colorby("length", palette = 
                   colorRampPalette(c("dodgerblue2", "firebrick2"))),
    linecolor = "fill",
    style = '3D', 
    archHeight = "h",
    alpha = 1,
    x = 0.25,
    y = 0.25,
    height = 1.5,
    just = c("left", "top"),
    default.units = "inches"
)

## Annotate genome label
annoGenomeLabel(plot = archPlot, x = 0.25, y = 1.78, scale = "Mb")

## Annotate heatmap legend
annoHeatmapLegend(
    plot = archPlot, fontcolor = "black",
    x = 7.0, y = 0.25,
    width = 0.10, height = 1, fontsize = 10
)

## Add the heatmap legend title
plotText(
    label = "Kb", rot = 90, x = 6.9, y = 0.75,
    just = c("center", "center"),
    fontsize = 10
)



## Hide page guides
pageGuideHide()

