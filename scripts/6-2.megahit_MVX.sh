# !/usr/bin/bash
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/6.megahit_MGX.sh
# This script is for assembling each subject's viromic datasets into contigs.
# Last modified: 23.10.28.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_DIR=${BASE}/intermediates/5.bowtie2_dehost_MGX_MTX_MVX/MVX
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
OUTPUT_DIR=${BASE}/intermediates/6.megahit/MVX
mkdir -p ${OUTPUT_DIR}

# Divide the task.
if [ -z ${1} ] || [ -z ${2} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MVX" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${1}
	END=${2}
fi

source activate megahit
cd ${INPUT_DIR}
sed '1d' ${INPUT_LIST} | grep "MVX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo -------------------------------------------
	echo ${subject}
	pe1=`ls ${subject}_*_dehosted.1.fastq | xargs | sed 's/ /,/g'` # use xargs to convert multi-line output into single-line output, and then sed " " with comma, which is required by megahit input.
	pe2=`ls ${subject}_*_dehosted.2.fastq | xargs | sed 's/ /,/g'`
	se=`ls ${subject}*_dehosted.fastq | xargs | sed 's/ /,/g'`
	#echo ${pe1}
	#echo ${pe2}
	#echo ${se}
	megahit --out-dir ${OUTPUT_DIR}/${subject} --out-prefix ${subject}_MVX --num-cpu-threads 36 --memory 0.3 --presets meta-sensitive -1 ${pe1} -2 ${pe2} -r ${se}
	sed -i -e "s/>/>${subject}_MVX_/g" -e "s/ /_/g" ${OUTPUT_DIR}/${subject}/${subject}_MVX.contigs.fa

	#sed '1d' ${INPUT_LIST} | grep "MGX" | grep "${subject}" | awk '{print $6}' | while read sample
	#do
		#echo ${sample}
		#pe1=`ls ${sample}*_dehosted.1.fastq`
		#pe2=`ls ${sample}*_dehosted.2.fastq`
		#se=`ls ${sample}*_dehosted.fastq`
		#echo ${pe1}
		#echo ${pe2}
		#echo ${se}
	#done
done
conda deactivate
