# On branch main
# Your branch is ahead of 'origin/main' by 1 commit.
#   (use "git push" to publish your local commits)
#
# Changes not staged for commit:
#   (use "git add/rm <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#	modified:   ../../../.run/processing_eqtl_catalog_with_complete_fields.sh
#	modified:   ../../../.run/run_colocalization_eqtl_catalog.sh
#	modified:   ../../../config/coloc_samplesheets/coloc.samplesheet.tsv
#	modified:   ../../../config/eqtl_samplesheets/eqtl.t1d_only.txt
#	modified:   ../../../config/hichip_samplesheets/hichip.samplesheet.tsv


#	deleted:    ../finemap/Intersect_Finemap_with_HiChIP.ipynb
#	deleted:    ../finemap/git.sh
#	deleted:    ../pieqtls/Intersect_PieQTLs_with_GWAS.ipynb
#	modified:   ../../rules/coloc.smk
#


git rm ../../notebooks/reports/Combine_Master_Tables.py.ipynb ../../notebooks/reports/Gene_List_Comparison.2022-May.ipynb ../../notebooks/reports/Gene_List_Comparison.ipynb ../../notebooks/reports/Gene_List_Comparison_V2.with_old_coloc_data.ipynb ../../notebooks/reports/HiChIP_Sample_Summary.ipynb ../../notebooks/reports/Intersect_Colocs_with_pieQTLs.ipynb ../../notebooks/reports/PieQTLs_From_Chandra_Et_Al.ipynb ../../notebooks/reports/Summarize_SGLs_with_LD.ipynb

git add	./



# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#	../../../gmon.out
#	../finemap/SGLs_Finemap_with_HiChIP.ipynb
#	../pieqtls/SGLs_PieQTLs_with_GWAS.ipynb
#	../sgls/SGLs_Coloc_With_HiChIP.ipynb

git commit
