screen -S 
mamba activate treesapp_cenv

#create a jplace_files folder
mkdir ~/Metatranscriptome_output_folder/jplace_files

#move all jplace files to one folder called jplace_files
mv NirK_10m_RNA_output_group2_AN/iTOL_output/NirK/NirK_complete_profile.jplace ~/Metatranscriptome_output_folder/jplace_files
mv NirK_100m_RNA_output_group2_AN/iTOL_output/NirK/NirK_100m_complete_profile.jplace ~/Metatranscriptome_output_folder/jplace_files
mv NirK_120m_RNA_output_group2_AN/iTOL_output/NirK/NirK_120m_complete_profile.jplace ~/Metatranscriptome_output_folder/jplace_files
mv NirK_135m_RNA_output_group2_AN/iTOL_output/NirK/NirK_135m_complete_profile.jplace ~/Metatranscriptome_output_folder/jplace_files
mv NirK_150m_RNA_output_group2_AN/iTOL_output/NirK/NirK_150m_complete_profile.jplace ~/Metatranscriptome_output_folder/jplace_files
mv NirK_165m_RNA_output_group2_AN/iTOL_output/NirK/NirK_165m_complete_profile.jplace ~/Metatranscriptome_output_folder/jplace_files
mv NirK_200m_RNA_output_group2_AN/iTOL_output/NirK/NirK_200m_complete_profile.jplace ~/Metatranscriptome_output_folder/jplace_files


guppy kr -o SI072_NirK_beta_diversity.txt --list-out jplace_files/NirK_*

# Now we need to modify the output table so it's clean for importing into R.
awk '{$1=$1; print}' SI072_NirK_beta_diversity.txt | tr ' ' ',' > SI072_NirK_beta_diversity.csv
