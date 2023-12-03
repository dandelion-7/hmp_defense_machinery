# !/usr/bin/bash
#########################################################################################################################################################################
# Script: ~/crisprome/hmp/scripts/17-1.crass.sh
# This script is for identifying CRISPR sequences from reads and MAGs (binned with metabat2) following script 5 and 14.
# Last modified: 23.11.28.
#########################################################################################################################################################################

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
# set the input data type
if [ -z "$1" ]; then
	echo "Please provide the input data type for recovering CRISPR loci: reads or MAGs."
	exit
elif [ ${1} == "MAGs" ] || [ ${1} == "reads" ]; then
	echo "Input data type: ${1}"
	type=${1}
else
	echo "Please provide an available input data type: reads or MAGs."
	exit
fi

# set the software
if [ -z "$2" ]; then
        echo "Please provide the command for recovering CRISPR loci: crass, pilercr, crt."
        exit
elif [ ${1} == "reads" -a ${2} != "crass" ]; then    
        echo "For unassembled reads, only crass can be used to recover CRISPR loci."
        exit
elif [ ${2} == "crass" ] || [ ${2} == "pilercr" ] || [ ${2} == "crt" ]; then
	echo "${2} will be used to recover CRISPR loci from ${1}."
	command=${2}
else
	echo "Please provide an available command for recovering CRISPR loci: crass, pilercr, crt."
	exit
fi

# Divide the task.
if [ -z ${3} ] || [ -z ${4} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${3}
	END=${4}
fi

# set the input directory
if [ ${type} == "MAGs" ]; then
	INPUT_DIR=${BASE}/intermediates/11.DAS_tool_binning/metabat2
elif [ ${type} == "reads" ]; then
	INPUT_DIR=${BASE}/intermediates/5.bowtie2_dehost_MGX_MTX_MVX/MGX
fi

OUTPUT_DIR=${BASE}/intermediates/17.crispr_recovery/${type}/${command}; mkdir -p ${OUTPUT_DIR}

if [ ${type} == "reads" ]; then
	source activate crass
	cd ${INPUT_DIR}
	sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
	do
		echo --------------------------------------------------------------------
		echo ${subject}
		subject_dir=${OUTPUT_DIR}/${subject}_${type}_crass; mkdir -p ${subject_dir}
		
		sed '1d' ${INPUT_LIST} | grep "MGX" | grep "${subject}" | awk '{print $6}' | while read sample
		do
			echo ${sample}
			PE_1=${sample}_dehosted.1.fastq
			PE_2=${sample}_dehosted.2.fastq
			SE=${sample}_dehosted.fastq
			sample_dir=${subject_dir}/${sample}
			crass --windowLength 6 --covCutoff 2 --kmerCount 6 --minSpacer 16 --maxSpacer 100 --outDir ${sample_dir} ${PE_1} ${PE_2} ${SE} -c red-blue --logLevel 4 -G -L
		done
	done
	conda deactivate
fi

if [ ${type} == "MAGs" -a ${command} == "crass" ]; then
	source activate crass
	sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
	do
		echo --------------------------------------------------------------------
		echo ${subject}
		subject_dir=${OUTPUT_DIR}/${subject}_${type}_crass; mkdir -p ${subject_dir}
		
		cd ${INPUT_DIR}/${subject}/bin
		ls *.fa | sed 's/.fa//g' | while read sample
		do
			echo ${sample}
			MAG=${INPUT_DIR}/${subject}/bin/${sample}.fa
			MAG_dir=${subject_dir}/${sample}
			crass --windowLength 6 --covCutoff 2 --kmerCount 6 --minSpacer 16 --maxSpacer 100 --outDir ${MAG_dir} ${MAG} -c red-blue --logLevel 4 -G -L
		done
	done
	conda deactivate
elif [ ${type} == "MAGs" -a ${command} == "pilercr" ]; then
	source activate crispr-softwares
	sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
	do
		echo --------------------------------------------------------------------
		echo ${subject}
		subject_dir=${OUTPUT_DIR}/${subject}_${type}_pilercr; mkdir -p ${subject_dir}
		
		cd ${INPUT_DIR}/${subject}/bin
                ls *.fa | sed 's/.fa//g' | while read sample
                do
			echo ${sample}
                        MAG=${INPUT_DIR}/${subject}/bin/${sample}.fa
			MAG_pilercr=${subject_dir}/${sample}_pilercr.out
        		MAG_pilercr_repeat=${subject_dir}/${sample}_pilercr_repeats.fasta
			pilercr -minrepeat 23 -maxrepeat 47 -minspacer 16 -maxspacer 100 -in ${MAG} -out ${MAG_pilercr} -seq ${MAG_pilercr_repeat} -quiet
                done
	done
	conda deactivate
elif [ ${type} == "MAGs" -a ${command} == "crt" ]; then
	source activate crispr-softwares
        sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
        do
		echo --------------------------------------------------------------------
		echo ${subject}
                subject_dir=${OUTPUT_DIR}/${subject}_${type}_crt; mkdir -p ${subject_dir}

                cd ${INPUT_DIR}/${subject}/bin
                ls *.fa | sed 's/.fa//g' | while read sample
                do
			echo ${sample}
                        MAG=${INPUT_DIR}/${subject}/bin/${sample}.fa
                        MAG_crt=${subject_dir}/${sample}_crt.out
			java -cp ~/software/CRISPR_Recognition_Tool/CRT1.2-CLI.jar crt -minRL 23 -maxRL 47 -minSL 16 -maxSL 100 ${MAG} ${MAG_crt} > /dev/null
                done
        done
        conda deactivate
fi
