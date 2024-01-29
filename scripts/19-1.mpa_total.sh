#!/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/19-1.mpa_total.sh
# This script is for evaluating the total taxonomic composition of metagenomic samples.
# Last modified: 24.1.15.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
INPUT_DIR=${BASE}/intermediates/5.bowtie2_dehost_MGX_MTX_MVX/MGX
OUTPUT_DIR=${BASE}/intermediates/19.total_taxonomy/metaphlan; mkdir -p ${OUTPUT_DIR}
OUTPUT_BOWTIE2_DIR=${OUTPUT_DIR}/bowtie2; mkdir -p ${OUTPUT_BOWTIE2_DIR}
OUTPUT_MPA_DIR=${OUTPUT_DIR}/mpa; mkdir -p ${OUTPUT_MPA_DIR}
BOWTIE2_DB=~/software/metaphlan/bowtie2db

# Divide the task.
if [ -z ${1} ] || [ -z ${2} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${1}
	END=${2}
fi

source activate mpa
sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo ---------------------------------------------------
	echo ${subject}

	sed '1d' ${INPUT_LIST} | grep "MGX" | grep "${subject}" | awk '{print $6}' | sort | uniq | while read sample
	do
		echo ${sample}
		pe1=${INPUT_DIR}/${sample}_dehosted.1.fastq; pe2=${INPUT_DIR}/${sample}_dehosted.2.fastq; se=${INPUT_DIR}/${sample}_dehosted.fastq
		mpa_out=${OUTPUT_MPA_DIR}/${sample}_mpa_out.txt
		bowtie2_out=${OUTPUT_BOWTIE2_DIR}/${sample}_bowtie2_out.txt

		cd ${OUTPUT_MPA_DIR}
		#metaphlan ${pe1},${pe2} --input_type fastq --bowtie2out ${bowtie2_out} -o ${mpa_out} --bowtie2db ${BOWTIE2_DB} --nproc 32
		# If multiple files are input for metaphlan, they need to be sparated with ",", otherwise the following file will be re-written as the output.
		cat ${mpa_out} | sed '1,5d' | awk '{print $1"\t"$2"\t"$3}' | sed -e 's/|/,/g' -e 's/ //g' | sed "s/$/&\t${sample}/g" >> ${OUTPUT_MPA_DIR}/total_output.txt

	done
done
conda deactivate
