# !/usr/bin/bash
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/15.gtdbtk.sh
# This script assigns taxonomy to the assembled bins from script 11-1 with gtdb-tk.
# Last modified: 23.11.13.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
if [ -z "$1" ]; then
	echo "Please provide the source of the input bins: metabat2 or maxbin2."
	exit
elif [ ${1} == "metabat2" ]||[ ${1} == "maxbin2" ]; then
	source=${1}
	INPUT_DIR=${BASE}/intermediates/11.DAS_tool_binning/${source}
	OUTPUT_DIR=${BASE}/intermediates/15.gtdb-tk/${source}_bin; mkdir -p ${OUTPUT_DIR}
else
	echo "Please provide an available source of input bins: metabat2 or maxbin2. "
	exit
fi

# Divide the tasks.
if [ -z ${2} ] || [ -z ${3} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | wc -l`
else
	BEGIN=${2}
	END=${3}
fi

source activate gtdbtk
sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do 
	echo -------------------------------------------------------------------------------------
	echo ${subject}
	genomes=${INPUT_DIR}/${subject}/bin
	output=${OUTPUT_DIR}/${subject}; mkdir -p ${output}
	output_file=${output}/${subject}_${source}_bins_stats.txt
	if [ ${source} == "metabat2" ]; then
		gtdbtk classify_wf --genome_dir ${genomes} --extension fa --out_dir ${output} --cpus 32 --pplacer_cpus 32 --prefix ${subject}_MGX_${source}_bins
	else
		gtdbtk classify_wf --genome_dir ${genomes} --extension fasta --out_dir ${output} --cpus 32 --pplacer_cpus 32 --prefix ${subject}_MGX_${source}_bins
	fi
done
conda deactivate
