# !/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/9.bowtie2_contigs_MGX_MTX.sh
# This script aligns filtered MGX/MTX reads (following script 5 for MGX, script 7 for MTX) to the assembled contigs with bowtie2. The bowtie2 references are constructed with the >=500bp contigs from mixed assembly with megahit following script 6.
# Last modified: 23.10.31.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
CONTIGS_DIR=${BASE}/intermediates/6.megahit/MGX

# Determine data type.
if [ -z "$1" ]; then
	echo "Please provide the data type to be analyzed: MGX or MTX."
	exit
elif [ ${1} == "MGX" ]; then
	INPUT_DIR=${BASE}/intermediates/5.bowtie2_dehost_MGX_MTX_MVX/MGX
elif [ ${1} == "MTX" ]; then
	INPUT_DIR=${BASE}/intermediates/7.bowtie2_rRNA_MTX_QQ
else
	echo "Please provide the available data type: MGX or MTX."
        exit
fi

# Determine the running mode: bowtie2-build or bowtie2.
if [ -z "$2" ]; then
	echo "Please tell the command to run: bowtie2-build or bowtie2."
	exit
elif [ ${2} == "bowtie2-build" ]; then
	command=${2}
	OUTPUT_DIR=${BASE}/intermediates/9.bowtie2_contigs_MGX_MTX/bowtie2_reference; mkdir -p ${OUTPUT_DIR}
	echo "bowtie2-build will be executed to construct the reference for the assigned subjects."
elif [ ${2} == "bowtie2" ]; then
	command=${2}
	OUTPUT_DIR=${BASE}/intermediates/9.bowtie2_contigs_MGX_MTX/${1}; mkdir -p ${OUTPUT_DIR}
	OUTPUT_BAM_DIR=${BASE}/intermediates/9.bowtie2_contigs_MGX_MTX/${1}/bam; mkdir -p ${OUTPUT_BAM_DIR}
	OUTPUT_LOG_DIR=${BASE}/intermediates/9.bowtie2_contigs_MGX_MTX/${1}/log; mkdir -p ${OUTPUT_LOG_DIR}
	echo "bowtie2 will be executed for aligning the ${1} reads onto contigs."
else
	echo "Please provide the available command: bowtie2-build or bowtie2."
	exit
fi

# Divide the task.
if [ -z ${3} ] || [ -z ${4} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${3}
	END=${4}
fi

if [ ${command} == "bowtie2-build" ]; then
	sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
	do
		echo ---------------------------------------------------------
		echo ${subject}

		input_contigs=${CONTIGS_DIR}/${subject}/${subject}_MGX.contigs.fa
		long_contigs=${OUTPUT_DIR}/${subject}_MGX_long_contigs.fa
		short_contigs=${OUTPUT_DIR}/${subject}_MGX_short_contigs.fa
		ref=${OUTPUT_DIR}/${subject}

		source activate seqkit
		seqkit seq -g -m 500 ${input_contigs} > ${long_contigs}
		seqkit seq -g -M 499 ${input_contigs} > ${short_contigs}
		conda deactivate

		bowtie2-build -f ${long_contigs} ${ref}
	done
else
	sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
	do
		ref=${BASE}/intermediates/9.bowtie2_contigs_MGX_MTX/bowtie2_reference/${subject}
		echo ---------------------------------------------------------
		echo ${subject}
		sed '1d' ${INPUT_LIST} | grep "${1}" | grep "${subject}" | awk '{print $6}' | while read sample
		do
			echo ${sample}
			cd ${INPUT_DIR}
			file_num=`ls ${sample}* | wc -l`
			if [ ${1} == "MTX" ] && [ ${file_num} == 1 ]; then
				SE=${sample}_rRNA_dep.fastq
				SAM=${OUTPUT_BAM_DIR}/${sample}.sam
				BAM=${OUTPUT_BAM_DIR}/${sample}.bam
				SORTED_BAM=${OUTPUT_BAM_DIR}/${sample}_sorted.bam
				BAI=${OUTPUT_BAM_DIR}/${sample}_sorted.bai
				LOG=${OUTPUT_LOG_DIR}/${sample}.log
				#bowtie2 -p 32 -x ${ref} -U ${SE} -S ${SAM} 2> ${LOG}
				#samtools view -b -S ${SAM} > ${BAM}; rm ${SAM}
				samtools sort --threads 32 -o ${SORTED_BAM} ${BAM}; rm ${BAM}
				samtools index -b ${SORTED_BAM} ${BAI}
				# some MTX files are single-ended, so this condition need to be specified.
			elif [ ${1} == "MTX" ]; then
				PE1=${sample}_rRNA_dep.1.fastq
				PE2=${sample}_rRNA_dep.2.fastq
				SAM=${OUTPUT_BAM_DIR}/${sample}.sam
				BAM=${OUTPUT_BAM_DIR}/${sample}.bam
				SORTED_BAM=${OUTPUT_BAM_DIR}/${sample}_sorted.bam
				BAI=${OUTPUT_BAM_DIR}/${sample}_sorted.bai
                                LOG=${OUTPUT_LOG_DIR}/${sample}.log
				#bowtie2 -p 32 -x ${ref} -1 ${PE1} -2 ${PE2} -S ${SAM} 2> ${LOG}
				#samtools view -b -S ${SAM} > ${BAM}; rm ${SAM}
				samtools sort --threads 32 -o ${SORTED_BAM} ${BAM}; rm ${BAM}
				samtools index -b ${SORTED_BAM} ${BAI}

				SE=${sample}_rRNA_dep.fastq
				SE_SAM=${OUTPUT_BAM_DIR}/${sample}_SE.sam
                                SE_BAM=${OUTPUT_BAM_DIR}/${sample}_SE.bam
				SE_SORTED_BAM=${OUTPUT_BAM_DIR}/${sample}_SE_sorted.bam
				SE_BAI=${OUTPUT_BAM_DIR}/${sample}_SE_sorted.bai
                                SE_LOG=${OUTPUT_LOG_DIR}/${sample}_SE.log
                                #bowtie2 -p 32 -x ${ref} -U ${SE} -S ${SE_SAM} 2> ${SE_LOG}
                                #samtools view -b -S ${SE_SAM} > ${SE_BAM}; rm ${SE_SAM}
				samtools sort --threads 32 -o ${SE_SORTED_BAM} ${SE_BAM}; rm ${SE_BAM}
				samtools index -b ${SE_SORTED_BAM} ${SE_BAI}
			else
				PE1=${sample}_dehosted.1.fastq
                                PE2=${sample}_dehosted.2.fastq
                                SAM=${OUTPUT_BAM_DIR}/${sample}.sam
                                BAM=${OUTPUT_BAM_DIR}/${sample}.bam
				SORTED_BAM=${OUTPUT_BAM_DIR}/${sample}_sorted.bam
				BAI=${OUTPUT_BAM_DIR}/${sample}_sorted.bai
                                LOG=${OUTPUT_LOG_DIR}/${sample}.log
                                #bowtie2 -p 32 -x ${ref} -1 ${PE1} -2 ${PE2} -S ${SAM} 2> ${LOG}
                                #samtools view -b -S ${SAM} > ${BAM}; rm ${SAM}
				samtools sort --threads 32 -o ${SORTED_BAM} ${BAM}; rm ${BAM}
				samtools index -b ${SORTED_BAM} ${BAI}

                                SE=${sample}_dehosted.fastq
                                SE_SAM=${OUTPUT_BAM_DIR}/${sample}_SE.sam
                                SE_BAM=${OUTPUT_BAM_DIR}/${sample}_SE.bam
				SE_SORTED_BAM=${OUTPUT_BAM_DIR}/${sample}_SE_sorted.bam
				SE_BAI=${OUTPUT_BAM_DIR}/${sample}_SE_sorted.bai
                                SE_LOG=${OUTPUT_LOG_DIR}/${sample}_SE.log
                                #bowtie2 -p 32 -x ${ref} -U ${SE} -S ${SE_SAM} 2> ${SE_LOG}
                                #samtools view -b -S ${SE_SAM} > ${SE_BAM}; rm ${SE_SAM}
				samtools sort --threads 32 -o ${SE_SORTED_BAM} ${SE_BAM}; rm ${SE_BAM}
				samtools index -b ${SE_SORTED_BAM} ${SE_BAI}
			fi
		done
	done
fi
