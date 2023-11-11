# !/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/12-2.defensefinder_MGX_ORFs.sh 
# This script is for predicting anti-phage related genes from CDSs of assembled contigs of each individual with DefenseFinder following script 12-1.
# Last modified: 23.11.4.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
INPUT_DIR=${BASE}/intermediates/12.defense_gene_prediction/prodigal
OUTPUT_DIR=${BASE}/intermediates/12.defense_gene_prediction/defenseFinder
mkdir -p ${OUTPUT_DIR}

# Divide the tasks.
if [ -z ${1} ] || [ -z ${2} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | wc -l`
else
	BEGIN=${1}
	END=${2}
fi

source activate defensefinder
sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo ------------------------------------------------------------------------------------------------------------------------------------------------------------
	echo ${subject}
	cd ${INPUT_DIR}/${subject}_splitted_contigs
	ls *_proteins.fasta | sed 's/_proteins.fasta//g' | while read sample
	do
		echo ${sample}
		contigs=${INPUT_DIR}/${subject}_splitted_contigs/${sample}_proteins.fasta
		defense-finder run --out-dir ${OUTPUT_DIR}/${subject}/${sample} --models-dir ~/software/defense-finder/models --preserve-raw ${contigs}
	done
done
conda deactivate
