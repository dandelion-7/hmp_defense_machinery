# !/usr/bin/bash
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/7.bowtie2_rRNA_MTX.sh
# This script is for removing rRNA-derived reads in the metatranscriptome data, through mapping with bowtie2 onto SIVLA rRNA database.
# Last modified: 23.10.30.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_DIR=${BASE}/intermediates/5.bowtie2_dehost_MGX_MTX_MVX/MTX
OUTPUT_DIR=${BASE}/intermediates/7.bowtie2_rRNA_MTX_QQ
OUTPUT_BAM_DIR=${OUTPUT_DIR}/bam;mkdir -p ${OUTPUT_BAM_DIR}
OUTPUT_LOG_DIR=${OUTPUT_DIR}/log;mkdir -p ${OUTPUT_LOG_DIR}
BOWTIE2_REFERENCE=~/genome/SILVA/bowtie2_ref_from_QQ/rRNA/rRNA
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata

# Divide the task.
if [ -z ${1} ] || [ -z ${2} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MTX" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${1}
	END=${2}
fi

cd ${INPUT_DIR}
sed '1d' ${INPUT_LIST} | grep "MTX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo ----------------------------------------------------------
	echo ${subject}
	sed '1d' ${INPUT_LIST} | grep "MTX" | grep "${subject}" | awk '{print $6}' | sort | uniq | while read sample
	do
		file_num=`ls ${sample}* | wc -l` # few MTX files were sequenced with the single-end platform, so the bowtie2 command need to be specified.
		echo ${sample}

		if [ ${file_num} == 1 ]; then
			SE=${sample}_dehosted.fastq
                	SE_SAM=${OUTPUT_BAM_DIR}/${sample}_SE.sam
                	SE_BAM=${OUTPUT_BAM_DIR}/${sample}_SE.bam
                	SE_UN=${OUTPUT_DIR}/${sample}_rRNA_dep.fastq
                	SE_LOG=${OUTPUT_LOG_DIR}/${sample}_SE.log
                	bowtie2 -p 16 --no-unal --un ${SE_UN} -x ${BOWTIE2_REFERENCE} -U ${SE} -S ${SE_SAM} 2> ${SE_LOG}
                	samtools view -b -S ${SE_SAM} > ${SE_BAM}; rm ${SE_SAM}
		else
			PE1=${sample}_dehosted.1.fastq;PE2=${sample}_dehosted.2.fastq
			PE_SAM=${OUTPUT_BAM_DIR}/${sample}_PE.sam
			PE_BAM=${OUTPUT_BAM_DIR}/${sample}_PE.bam
			PE_UN=${OUTPUT_DIR}/${sample}_rRNA_dep.fastq
			PE_LOG=${OUTPUT_LOG_DIR}/${sample}_PE.log
			bowtie2 -p 16 --no-unal --un-conc ${PE_UN} -x ${BOWTIE2_REFERENCE} -1 ${PE1} -2 ${PE2} -S ${PE_SAM} 2> ${PE_LOG}
			samtools view -b -S ${PE_SAM} > ${PE_BAM}; rm ${PE_SAM}

			SE=${sample}_dehosted.fastq
			SE_SAM=${OUTPUT_BAM_DIR}/${sample}_SE.sam
			SE_BAM=${OUTPUT_BAM_DIR}/${sample}_SE.bam
			SE_UN=${OUTPUT_DIR}/${sample}_rRNA_dep.fastq
			SE_LOG=${OUTPUT_LOG_DIR}/${sample}_SE.log
			bowtie2 -p 16 --no-unal --un ${SE_UN} -x ${BOWTIE2_REFERENCE} -U ${SE} -S ${SE_SAM} 2> ${SE_LOG}
			samtools view -b -S ${SE_SAM} > ${SE_BAM}; rm ${SE_SAM}
		fi
	done
done
