# !/usr/bin/bash

############################################################################################################################################
# Script: ~/crisprome/hmp/scripts/4.fastqc_after_filtering.sh
# This script is for quality control of all the sequencing data before filtering.
# Last modified: 23-10-23.
###########################################################################################################################################

# Set parameters.
BASE=~/crisprome/hmp
INPUT_DIR=${BASE}/intermediates/3.fastp/MVX
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-7.nonIBD_metadata.txt
OUTPUT_DIR=${BASE}/intermediates/4.fastqc_after_filtering/MVX_new
ADAPTOR_DIR=~/software/adaptor_sequences/adaptors.txt
mkdir -p ${OUTPUT_DIR}

# Divide all the files into multiple parallel tasks by individuals.
if [ -z "$1" ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | awk '{print $1}' | sort -n | uniq | wc -l`
else
	BEGIN=${1}
	END=${2}
fi

# Run fastqc.
sed '1d' ${INPUT_LIST} | awk '{print $1}' | sort -n | uniq | sed -n "${BEGIN}, ${END}p" | while read individual
do
	cd ${INPUT_DIR}
	#echo --------------------------------------------
	#echo ${individual}

	ls ${individual}*fastq | sed -e 's/_filtered.fastq//g' -e 's/_1//g' -e 's/_2//g' -e 's/_unpaired//g' | sort | uniq | while read sample
	do
		INPUT_FASTQ=`ls ${sample}*fastq`
		echo ${INPUT_FASTQ}
		fastqc ${INPUT_FASTQ} -o ${OUTPUT_DIR} -t 64 -a ${ADAPTOR_DIR} -q
	done

done

# Perform multiqc
OUTPUT_MULTIQC_DIR=${OUTPUT_DIR}/multiqc
#mkdir -p ${OUTPUT_MULTIQC_DIR}
#multiqc -o ${OUTPUT_MULTIQC_DIR} ${OUTPUT_DIR}
# The files were archived according to MGX/MTX/MVX/BP types into different folders in the OUTPUT_DIR, and multiqc were run manually for each type of data.
