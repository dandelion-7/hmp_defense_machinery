# !/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script:~/crisprome/hmp/scripts/8.genomad_MGX_MVX.sh
# This script is for predicting and extracting the viral contigs from the total assembled contigs following script 6-1/6-2 with geNomad.
# Last modified: 23.10.30.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
# Determine input file
if [ -z "$1" ]; then
	echo "Please provide the input file type: MGX or MVX."
	exit
else
	object=${1}
	INPUT_DIR=${BASE}/intermediates/6.megahit/${1}
	OUTPUT_DIR=${BASE}/intermediates/8.genomad_MGX_MVX/${1}; mkdir -p ${OUTPUT_DIR}
fi

# Determine the running mode of geNomad.
if [ -z "$2" ]; then
	echo "Please provide the running mode of geNomad: total or without_nn."
	exit
else
	mode=${2}
fi

# Divide the task.
if [ -z ${3} ] || [ -z ${4} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${3}
	END=${4}
fi

source activate genomad
sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo -----------------------------------------------------------------------------------------
	cd ${INPUT_DIR}/${subject}
	echo ${subject}

	input=${subject}_${object}.contigs.fa
	output=${OUTPUT_DIR}/${subject}_${object}_${mode}

	if [ ${mode} == "total" ]; then
		genomad end-to-end --cleanup --splits 0 --threads 2 ${input} ${output} ~/software/genomad/genomad_db
	elif [ ${mode} == "without_nn" ]; then
		genomad end-to-end --disable-nn-classification --cleanup --splits 8 ${input} ${output} ~/software/genomad/genomad_db
	else 
		echo "Please provide an available running mode: total or without_nn"
	fi
done
conda deactivate
