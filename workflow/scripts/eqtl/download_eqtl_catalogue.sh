# download the metadata that links eQTL study ids to the name
metadata_fn="results/hg38/eqtl/eqtl_catalogue/dataset_metadata.tsv"
if [ ! -e $metadata_fn ];
then
    wget -O $metadata_fn https://raw.githubusercontent.com/eQTL-Catalogue/eQTL-Catalogue-resources/master/data_tables/dataset_metadata.tsv
fi

# extract the immune subsets manually using excel
# convert the previous file into an excel, add lc-selection with Yes, No, Later values
# and lc-celltype with relevant cell types and save the corresponding table with the name
# below.
metadata_select_fn="results/hg38/eqtl/eqtl_catalogue/dataset_metadata.immune_subset.tsv"
if [ ! -e $metadata_select_fn ];
then
    printf "# extract the immune subsets manually using excel\n"
fi

# download the metadata with ftp links
metadata_links_fn="results/hg38/eqtl/eqtl_catalogue/dataset_metadata.with-links.tsv"
if [ ! -e $metadata_links_fn ];
then
    wget -O $metadata_links_fn https://raw.githubusercontent.com/eQTL-Catalogue/eQTL-Catalogue-resources/master/tabix/tabix_ftp_paths.tsv
fi

# # download the selected immune data
while IFS= read -r line;
do 

    # get the dataset_id
    dataset_id=$(echo "$line" | awk -F'\t' '{print $4}')

    # get the URL
    link_info=$(grep "${dataset_id}" $metadata_links_fn)
    credible_set_url=$(printf "$link_info" | cut -f 11)

    # download the data
    bn=$(basename $credible_set_url)
    cs_fn="results/hg38/eqtl/eqtl_catalogue/${bn}"
    if [ ! -e $cs_fn ];
    then
        printf "Downloading: ${cs_fn}"
        wget -O $cs_fn $credible_set_url
    else
        printf "Previously downloaded: ${cs_fn}"
    fi

done < <(sed 1d "$metadata_select_fn")
