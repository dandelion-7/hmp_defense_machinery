# !/usr/bin/bash
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/5.bowtie2_dehost_MGX_MTX_MVX.sh
# This script is for removing human-derived reads with bowtie2 from MGX/MTX/MVX datasets.
# Last modified: 23.10.26.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
if [ -z ${1} ]; then
	echo "Please provide the library type for dehosting: MGX, MTX, or MVX."
	exit
elif [ ${1} == "MGX" ]; then
	INPUT_DIR=${BASE}/intermediates/3.fastp/total_MGX
	OUTPUT_DIR=${BASE}/intermediates/5.bowtie2_dehost_MGX_MTX_MVX/MGX
elif [ ${1} == "MTX" ]; then
	INPUT_DIR=${BASE}/intermediates/3.fastp/total_MTX
	OUTPUT_DIR=${BASE}/intermediates/5.bowtie2_dehost_MGX_MTX_MVX/MTX
elif [ ${1} == "MVX" ]; then
	INPUT_DIR=${BASE}/intermediates/3.fastp/MVX
        OUTPUT_DIR=${BASE}/intermediates/5.bowtie2_dehost_MGX_MTX_MVX/MVX
else
	echo "Please provide a valid library type: MGX, MTX, or MVX/"
	exit
fi
mkdir -p ${OUTPUT_DIR}
OUTPUT_BAM_DIR=${OUTPUT_DIR}/bam;mkdir -p ${OUTPUT_BAM_DIR}
OUTPUT_LOG_DIR=${OUTPUT_DIR}/log;mkdir -p ${OUTPUT_LOG_DIR}
BOWTIE2_REFERENCE=~/genome/human/bowtie2_reference/human
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata

# Divide the task.
if [ -z ${2} ] || [ -z ${3} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${2}
	END=${3}
fi

cd ${INPUT_DIR}
sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo ----------------------------------------------------------
	echo ${subject}
	sed '1d' ${INPUT_LIST} | grep "${1}" | grep "${subject}" | awk '{print $6}' | sort | uniq | while read sample
	do
		file_num=`ls ${sample}* | wc -l` # few MTX files were sequence with the single-end platform, so the bowtie2 command need to be specified.
		echo ${sample}

		if [ ${file_num} == 1 ]; then
			SE=${sample}_filtered.fastq
                	SE_SAM=${OUTPUT_BAM_DIR}/${sample}_SE.sam
                	SE_BAM=${OUTPUT_BAM_DIR}/${sample}_SE.bam
                	SE_UN=${OUTPUT_DIR}/${sample}_dehosted.fastq
                	SE_LOG=${OUTPUT_LOG_DIR}/${sample}_SE.log
                	bowtie2 -p 16 --no-unal --un ${SE_UN} -x ${BOWTIE2_REFERENCE} -U ${SE} -S ${SE_SAM} 2> ${SE_LOG}
                	samtools view -b -S ${SE_SAM} > ${SE_BAM}; rm ${SE_SAM}
		else
			PE1=${sample}_1_filtered.fastq;PE2=${sample}_2_filtered.fastq
			PE_SAM=${OUTPUT_BAM_DIR}/${sample}_PE.sam
			PE_BAM=${OUTPUT_BAM_DIR}/${sample}_PE.bam
			PE_UN=${OUTPUT_DIR}/${sample}_dehosted.fastq
			PE_LOG=${OUTPUT_LOG_DIR}/${sample}_PE.log
			bowtie2 -p 16 --no-unal --un-conc ${PE_UN} -x ${BOWTIE2_REFERENCE} -1 ${PE1} -2 ${PE2} -S ${PE_SAM} 2> ${PE_LOG}
			samtools view -b -S ${PE_SAM} > ${PE_BAM}; rm ${PE_SAM}

			SE=${sample}_unpaired_filtered.fastq
			SE_SAM=${OUTPUT_BAM_DIR}/${sample}_SE.sam
			SE_BAM=${OUTPUT_BAM_DIR}/${sample}_SE.bam
			SE_UN=${OUTPUT_DIR}/${sample}_dehosted.fastq
			SE_LOG=${OUTPUT_LOG_DIR}/${sample}_SE.log
			bowtie2 -p 16 --no-unal --un ${SE_UN} -x ${BOWTIE2_REFERENCE} -U ${SE} -S ${SE_SAM} 2> ${SE_LOG}
			samtools view -b -S ${SE_SAM} > ${SE_BAM}; rm ${SE_SAM}
		fi
	done
done
