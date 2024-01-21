#!/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/19-2.bowtie2_mapping_summary.sh
# This script is for evaluating the total taxonomic composition of metagenomic data by summarizing the mapping counts of each contig reference with Bowtie2.
# Last modified: 24.1.15.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
INPUT_DIR=${BASE}/intermediates/9.bowtie2_contigs_MGX_MTX/MGX/bam
OUTPUT_DIR=${BASE}/intermediates/19.total_taxonomy/bowtie2_contig_mapping; mkdir -p ${OUTPUT_DIR}

# Divide the task.
if [ -z ${1} ] || [ -z ${2} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${1}
	END=${2}
fi

sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo ---------------------------------------------------
	echo ${subject}
	subject_stats=${OUTPUT_DIR}/${subject}_stats.txt; cat /dev/null > ${subject_stats}

	sed '1d' ${INPUT_LIST} | grep "MGX" | grep "${subject}" | awk '{print $6}' | sort | uniq | while read sample
	do
		echo ${sample}
		sorted_bam=${INPUT_DIR}/${sample}_sorted.bam
		sample_stat=${OUTPUT_DIR}/${sample}_stat.txt
		#samtools view --threads 32 ${sorted_bam} | awk '{if ($5 > 10) print}' | awk '{print $3}' | uniq -c | sed "s/$/&\t${sample}/g" > ${sample_stat}
		sed -i -e "s/${subject}/\t${subject}/g" ${sample_stat}; sed -i 's/ //g' ${sample_stat}
		awk '{print $1"\t"$2"\t"$3}' ${sample_stat} >> ${subject_stats}
	done
done
