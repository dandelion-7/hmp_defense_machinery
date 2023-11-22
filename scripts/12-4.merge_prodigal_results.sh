# !/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/12-4.merge_prodigal_results.sh
# This script is for merging the results of prodigal (predicted proteins and gens) for annotating the contigs following script 12-1.
# Last modified: 23.11.13.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_DIR=${BASE}/intermediates/12.defense_gene_prediction/prodigal
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata

cat /dev/null > ${INPUT_DIR}/total_CDS.txt

sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | while read subject
do
	echo ------------------------------------------------------------------------------------------------------------------------------------------------------------
	echo ${subject}
	cd ${INPUT_DIR}/${subject}_splitted_contigs
	ls *_proteins.fasta | sed 's/_proteins.fasta//g' | while read sample
	do
		echo ${sample}
		grep ">" ${INPUT_DIR}/${subject}_splitted_contigs/${sample}_proteins.fasta | sed -e 's/ //g' -e 's/#/;/g' -e 's/>//g' >> ${INPUT_DIR}/total_CDS.txt
	done
done
