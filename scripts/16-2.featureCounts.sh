# !/usr/bin/bash
#---------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/16-2.featureCounts.sh 
# This script is for counting alignment over predicted defense-related genes with featureCounts following script 9 and 16-1.
# Last modified: 23.11.15.
#---------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
if [ -z "$1" ]; then
	echo "Please provide the sequencing data type for analysis: MGX or MTX."
	exit
elif [ ${1} == "MGX" ]||[ ${1} == "MTX" ]; then
	type=${1}
else
	echo "Please provide an available sequencing data type for analysis: MGX or MTX."
	exit
fi
BAM_INPUT=${BASE}/intermediates/9.bowtie2_contigs_MGX_MTX/${type}/bam
GFF_INPUT=${BASE}/intermediates/16.antiphage_machinery_stats/gff
OUTPUT_DIR=${BASE}/intermediates/16.antiphage_machinery_stats/featureCounts/${type}; mkdir -p ${OUTPUT_DIR}

# Divide the tasks.
if [ -z ${2} ] || [ -z ${3} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | wc -l`
else
	BEGIN=${2}
	END=${3}
fi

sed '1d' ${INPUT_LIST} | grep "${type}" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo -----------------------------------------------------------------------------------------------------
	echo ${subject}_${type}
	gff=${GFF_INPUT}/${subject}_MGX.gff
	
	cd ${BAM_INPUT}
	samples=`ls ${subject}_*_${type}*sorted.bam`
	tmp=${OUTPUT_DIR}/${subject}_${type}_tmp; mkdir ${tmp}
	#echo ${samples}
	featureCounts -a ${gff} -t CDS -g gene_name --tmpDir ${tmp} -O -M -T 32 -p ${samples} -o ${OUTPUT_DIR}/${subject}_${type}_featureCounts.txt
	rm -r ${tmp}
done
