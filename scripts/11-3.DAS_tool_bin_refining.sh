# !/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/11-3.DAS_tool_bin_refining.sh
# This script runs DAS_Tool to refine the bins returned by MetaBat2 and MaxBin2 following script 11-1.
# Last modified: 23.11.11.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
INPUT_CONTIGS_DIR=${BASE}/intermediates/6.megahit/MGX
INPUT_TSV_DIR=${BASE}/intermediates/11.DAS_tool_binning/contigs2bin
OUTPUT_DIR=${BASE}/intermediates/11.DAS_tool_binning/das_tool; mkdir -p ${OUTPUT_DIR}

# Divide the tasks.
if [ -z ${1} ] || [ -z ${2} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | wc -l`
else
	BEGIN=${1}
	END=${2}
fi

source activate das_tool
sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo ------------------------------------------------------------
	echo ${subject}
	contigs=${INPUT_CONTIGS_DIR}/${subject}/${subject}_MGX.contigs.fa
	grep "unbinned" -v ${INPUT_TSV_DIR}/metabat2/${subject}*.tsv > ${OUTPUT_DIR}/${subject}_MGX_metabat2_binned_contigs2bin.tsv
	grep "unbinned" -v ${INPUT_TSV_DIR}/maxbin2/${subject}*.tsv > ${OUTPUT_DIR}/${subject}_MGX_maxbin2_binned_contigs2bin.tsv
	input_tsv=`ls ${OUTPUT_DIR}/${subject}_MGX_*_binned_contigs2bin.tsv|xargs|sed 's/ /,/g'`
	echo ${input_tsv}
	output=${OUTPUT_DIR}/${subject}_MGX; mkdir -p ${output}
	~/software/DAS_Tool/DAS_Tool-1.1.6/DAS_Tool -i ${input_tsv} -l maxbin,metabat -c ${contigs} -o ${output}/${subject}_MGX -t 32 --debug
done
conda deactivate

# DAS_Tool returns error, so this script is not done. Binning results of metabat2 will be used.
