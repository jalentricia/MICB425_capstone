#!/bin/bash

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
