# !/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/11-2.DAS_tool_Contigs2Bin_assigning.sh
# This script runs DAS_Tool to refine the bins returned by MetaBat2 and MaxBin2 following script 11-1.
# Last modified: 23.11.11.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
if [ -z "$1" ]; then
	echo "Please provide the source of bins: metabat2 or maxbin2."
	exit
elif [ ${1} == "metabat2" ]||[ ${1} == "maxbin2" ]; then
	binning_tool=${1}
	echo "The table assigning contigs to bins from ${1} will be generated."
else
	echo "Please provide an available source of bins: metabat2 or maxbin2."
	exit
fi
INPUT_DIR=${BASE}/intermediates/11.DAS_tool_binning/${binning_tool}
OUTPUT_DIR=${BASE}/intermediates/11.DAS_tool_binning/contigs2bin/${binning_tool}; mkdir -p ${OUTPUT_DIR}
#INPUT_CONTIGS_DIR=${BASE}/intermediates/6.megahit/MGX

# Divide the tasks.
if [ -z ${2} ] || [ -z ${3} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | wc -l`
else
	BEGIN=${2}
	END=${3}
fi

source activate das_tool
sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo ------------------------------------------------------------
	echo "Contigs of ${subject} will be assigned to bins from ${binning_tool}"
	#contigs=${INPUT_CONTIGS_DIR}/${subject}/${subject}_MGX.contigs.fa
	output_tsv=${OUTPUT_DIR}/${subject}_MGX_${binning_tool}_contigs2bin.tsv
	input_bins=${INPUT_DIR}/${subject}/bin

	if [ ${binning_tool} == "metabat2" ]; then
		~/software/DAS_Tool/DAS_Tool-1.1.6/src/Fasta_to_Contig2Bin.sh -e fa -i ${input_bins} > ${output_tsv}
	else
		~/software/DAS_Tool/DAS_Tool-1.1.6/src/Fasta_to_Contig2Bin.sh -e fasta -i ${input_bins} > ${output_tsv}
	fi
done
conda deactivate
