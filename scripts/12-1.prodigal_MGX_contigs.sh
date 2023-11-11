# !/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/12-1.prodigal_MGX_contigs.sh
# This script is for predicting all the CDS from assembled contigs following script 6, which will be the input for defense-finder.
# Last modified: 23.11.3.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
INPUT_DIR=${BASE}/intermediates/6.megahit/MGX
OUTPUT_DIR=${BASE}/intermediates/12.defense_gene_prediction/prodigal
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
	echo -----------------------------------------------------------------------------------------------
	echo ${subject}
	cd ${OUTPUT_DIR}
	contigs=${INPUT_DIR}/${subject}/${subject}_MGX.contigs.fa
	long_contigs=${OUTPUT_DIR}/${subject}_MGX_long.contigs.fa
	
	echo "Extracting >500bp contigs with seqkit seq."
	seqkit seq -g -m 500 ${contigs} > ${long_contigs}

	echo "Split all the long contigs with seqkit split2."
	seqkit split2 ${long_contigs} --by-part 500 --out-dir ${OUTPUT_DIR}/${subject}_splitted_contigs -f -w 0 -j 16 --quiet

	echo "Predict CDSs with prodigal."
	cd ${OUTPUT_DIR}/${subject}_splitted_contigs
	ls *.fa | sed 's/.fa//g' | while read sample
	do
		echo ${sample}
		prodigal -i ${sample}.fa -a ${sample}_proteins.fasta -d ${sample}_genes.fasta -o ${sample}_output.txt -s ${sample}_potential_genes.txt -p meta -q
	done

done
conda deactivate
