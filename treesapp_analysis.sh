#!/bin/bash

# activate tree_sapp 
mamba activate treesapp_cenv

### Metagenomic Analysis ###

# loop command to classify nirK for each depth and calculate abundance for metagenomic data
for depth in 10m 100m 120m 135m 150m 165m 200m; do treesapp assign -i ~/MICB425/assemblies/SI072_${depth}_contig.fa -r ~/MICB425/metagenomes/SI072_${depth}_pe.1.fq.gz -2 ~/MICB425/metagenomes/SI072_${depth}_pe.2.fq.gz -o ~/Group2_capstone_output_folder/NirK_${depth}_output_group2_AN/ -t NirK -n 2 --rel_abund; done

## Alpha diversity for metagenomic data ##

# 10m
guppy fpd -o NirK_10m_output_group2_AN/iTOL_output/NirK/alpha_diversity.cs
v --csv NirK_10m_output_group2_AN/iTOL_output/NirK/NirK_complete_profile.jplace

# 100m
guppy fpd -o NirK_100m_output_group2_AN/iTOL_output/NirK/alpha_diversity.cs
v --csv NirK_100m_output_group2_AN/iTOL_output/NirK/NirK_complete_profile.jplace

# 120m
guppy fpd -o NirK_120m_output_group2_AN/iTOL_output/NirK/alpha_diversity.cs
v --csv NirK_120m_output_group2_AN/iTOL_output/NirK/NirK_complete_profile.jplace

# 135m
guppy fpd -o NirK_135m_output_group2_AN/iTOL_output/NirK/alpha_diversity.cs
v --csv NirK_135m_output_group2_AN/iTOL_output/NirK/NirK_complete_profile.jplace

# 150m
guppy fpd -o NirK_150m_output_group2_AN/iTOL_output/NirK/alpha_diversity.cs
v --csv NirK_150m_output_group2_AN/iTOL_output/NirK/NirK_complete_profile.jplace

# 165m
guppy fpd -o NirK_165m_output_group2_AN/iTOL_output/NirK/alpha_diversity.cs
v --csv NirK_165m_output_group2_AN/iTOL_output/NirK/NirK_complete_profile.jplace

# 200m
guppy fpd -o NirK_200m_output_group2_AN/iTOL_output/NirK/alpha_diversity.cs
v --csv NirK_200m_output_group2_AN/iTOL_output/NirK/NirK_complete_profile.jplace

### Metatranscriptome Analysis ###

# TreeSAPP metatranscriptome loop for NirK
declare -A sample_sets=(
  [10m]=""
  [100m]="B"
  [120m]="B"
  [135m]="A"
  [150m]="B"
  [165m]="A"
  [200m]="B"
)

for depth in "${!sample_sets[@]}"; do
  set=${sample_sets[$depth]}

  r1_file=~/MICB425/metatranscriptomes/SI072_${depth}_${set}_1.fq.gz
  r2_file=~/MICB425/metatranscriptomes/SI072_${depth}_${set}_2.fq.gz

  if [[ -f $r1_file && -f $r2_file ]]; then
    echo "Running TreeSAPP for ${depth}m (set $set)..."
    treesapp assign \
      -i ~/MICB425/assemblies/SI072_${depth}_contig.fa \
      -r $r1_file -2 $r2_file \
      -o ~/Metatranscriptome_output_folder/NirK_${depth}_RNA_output_group2_AN/ \
      -t NirK -n 2 --rel_abund
  else
    echo "Skipping ${depth}m (set $set): FASTQ files not found."
  fi
done

## Beta Diversity ##

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

