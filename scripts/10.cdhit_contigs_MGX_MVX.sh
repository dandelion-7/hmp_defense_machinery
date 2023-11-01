# !/usr/bin/bash

######################################################################################################################################
# Script: ~/crisprome/hmp/scripts/9.cdhit_contigs_MGX_MVX.sh
# This script is for clustering and dereplicating assembled MGX/MVX contigs with cdhit.
# Last modified: 23.11.1.
######################################################################################################################################

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
if [ -z "$1" ]; then
	echo "Please provide the data type for clustering: MGX or MVX."
	exit
else
	object=${1}
	INPUT_DIR=${BASE}/intermediates/6.megahit/${1}
	OUTPUT_DIR=${BASE}/intermediates/10.cdhit_contigs_MGX_MVX/${1}; mkdir -p ${OUTPUT_DIR}
fi

# Divide the task.
if [ -z ${2} ] || [ -z ${3} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${2}
	END=${3}
fi

source activate cdhit
sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo -----------------------------------------------------------------------------------------
	cd ${INPUT_DIR}/${subject}
	#echo ${subject}

	input=${subject}_${object}.contigs.fa
	output=${OUTPUT_DIR}/${subject}_${object}_clustered.contigs.fa
	summary=${OUTPUT_DIR}/${subject}_${object}_clustered_contigs_summary.txt

	echo ${input}
	cd-hit -i ${input} -o ${output} -c 0.95 -d 200 -aS 0.9 -T 16 -M 16000 
done
conda deactivate


#echo "id	clstr	clstr_size	length	clstr_rep	clstr_iden	clstr_cov" > ${OUTPUT_DIR}/"repeats_clustered_summary.txt"
#echo "id	clstr	clstr_size	length	clstr_rep	clstr_iden	clstr_cov" > ${OUTPUT_DIR}/"spacers_clustered_summary.txt"

#source activate cdhit
#seq 10 | while read i
#do
	#echo ${i}
	MERGED_REPEATS=${OUTPUT_DIR}/${i}"_repeats.fasta"
	MERGED_SPACERS=${OUTPUT_DIR}/${i}"_spacers.fasta"
	
	OUTPUT_REPEATS=${OUTPUT_DIR}/${i}"_repeats_clustered.fasta"
	OUTPUT_SPACERS=${OUTPUT_DIR}/${i}"_spacers_clustered.fasta"

	REPEATS_SUMMARY=${OUTPUT_DIR}/"repeats_clustered_summary.txt"
	SPACERS_SUMMARY=${OUTPUT_DIR}/"spacers_clustered_summary.txt"


	#cat ${INPUT_DIR}/${i}"_"*"repeats.fa" > ${MERGED_REPEATS}
	#cat ${INPUT_DIR}/${i}"_"*"spacers.fa" > ${MERGED_SPACERS}
	
	#cd-hit -i ${MERGED_REPEATS} -o ${OUTPUT_REPEATS} -aL 0.95 -d 200 -c 0.95 -T 16 -M 16000
	#cd-hit -i ${MERGED_SPACERS} -o ${OUTPUT_SPACERS} -aL 0.95 -d 200 -c 0.95 -T 16 -M 16000

	#clstr2txt.pl ${OUTPUT_REPEATS}".clstr" | sed '/clstr_size/d' >> ${REPEATS_SUMMARY}
	#clstr2txt.pl ${OUTPUT_SPACERS}".clstr" | sed '/clstr_size/d' >> ${SPACERS_SUMMARY}

#done
#conda deactivate
