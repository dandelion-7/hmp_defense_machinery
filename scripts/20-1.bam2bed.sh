# !/usr/bin/bash
# --------------------------------------------------------------------------------------------------------------------
# Script: /home/zhanggaopu/crisprome/hmp/scripts/20-1.bam2bed.sh
# This script is for converting the bam files from script 9 by mapping the MGX/MTX fastq to contigs, into .bed files.
# Last modified: 24.2.27.
# --------------------------------------------------------------------------------------------------------------------

# Determine the data type: MGX or MTX.
if [ -z "$1" ]; then
    echo "Please tell to convert the bam files from MGX or MTX data alignment."
    exit
elif [ ${1} == "MGX" ]||[ ${1} == "MTX" ]; then
    data_type=${1}
else
    echo "Please provide an available data type: MGX or MTX."
    exit
fi

BASE=/home/zhanggaopu/crisprome/hmp
INPUT_DIR=${BASE}/intermediates/9.bowtie2_contigs_MGX_MTX/${data_type}
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
OUTPUT_DIR=${BASE}/intermediates/20.coverage_analysis/bed/${data_type}; mkdir -p ${OUTPUT_DIR}

# Divide the task.
if [ -z ${2} ] || [ -z ${3} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${2}
	END=${3}
fi

sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
    echo ----------------------------------------------------
    echo ${subject}

    sed '1d' ${INPUT_LIST} | grep "${1}" | grep "${subject}" | awk '{print $6}' | while read sample
    do
        echo ${sample}
        sorted_bam=${INPUT_DIR}/bam/${sample}_sorted.bam
        bed=${OUTPUT_DIR}/${sample}_total_reads.bed
        # echo ${bed}
        bedtools bamtobed -i ${sorted_bam} > ${bed}
    done
done