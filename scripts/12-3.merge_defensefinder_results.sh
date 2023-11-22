# !/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/12-3.merge_defensefinder_results.sh
# This script is for merging each subject's predicted anti-phage defense related genes following script 12-2.
# Last modified: 23.11.13.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_DIR=${BASE}/intermediates/12.defense_gene_prediction/defenseFinder
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata

cat /dev/null > ${INPUT_DIR}/merged_defensefinder_hmmer.tsv
cat /dev/null > ${INPUT_DIR}/merged_defensefinder_genes.tsv
cat /dev/null > ${INPUT_DIR}/merged_defensefinder_systems.tsv

head -n 1 ${INPUT_DIR}/2039/2039_MGX_long.contigs.part_001/2039_MGX_long.contigs.part_001_proteins_defense_finder_hmmer.tsv > ${INPUT_DIR}/merged_defensefinder_hmmer.tsv
head -n 1 ${INPUT_DIR}/2039/2039_MGX_long.contigs.part_001/2039_MGX_long.contigs.part_001_proteins_defense_finder_genes.tsv > ${INPUT_DIR}/merged_defensefinder_genes.tsv
head -n 1 ${INPUT_DIR}/2039/2039_MGX_long.contigs.part_001/2039_MGX_long.contigs.part_001_proteins_defense_finder_systems.tsv > ${INPUT_DIR}/merged_defensefinder_systems.tsv

sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | while read subject
do
	echo ------------------------------------------------------------------------------------------------------------------------------------------------------------
	echo ${subject}
	cd ${INPUT_DIR}/${subject}
	ls | while read sample
	do
		echo ${sample}
		sed '1d' ${INPUT_DIR}/${subject}/${sample}/*_hmmer.tsv >> ${INPUT_DIR}/merged_defensefinder_hmmer.tsv
		sed '1d' ${INPUT_DIR}/${subject}/${sample}/*_genes.tsv >> ${INPUT_DIR}/merged_defensefinder_genes.tsv
		sed '1d' ${INPUT_DIR}/${subject}/${sample}/*_systems.tsv >> ${INPUT_DIR}/merged_defensefinder_systems.tsv
	done
done
