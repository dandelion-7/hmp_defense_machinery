# !/usr/bin/bash

############################################################################################################################################
# Script: ~/crisprome/hmp/scripts/3.fastp_MGX.sh
# This script is for filtering low-quality reads and trimming adaptors with fastp.
# Last modified: 23-10-20.
###########################################################################################################################################

# Set parameters.
BASE=~/crisprome/hmp
INPUT_DIR=~/public_raw_data/hmp2/IBDMDB/nonIBD/nat_microbiol_MGX
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-7.Nat_Microbiol_nonIBD_metadata.txt
OUTPUT_DIR=${BASE}/intermediates/3.fastp/nat_microbiol_MGX
ADAPTOR_DIR=~/software/adaptor_sequences/adaptors.txt
mkdir -p ${OUTPUT_DIR}

# Divide all the files into multiple parallel tasks by individuals.
if [ -z "$1" ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | awk '{print $1}' | sort -n | uniq | wc -l`
else
	BEGIN=${1}
	END=${2}
fi

# Run fastp.
source activate fastp
sed '1d' ${INPUT_LIST} | awk '{print $1}' | sort -n | uniq | sed -n "${BEGIN}, ${END}p" | while read individual
do
	cd ${INPUT_DIR}
	echo --------------------------------------------
	echo ${individual}

	ls ${individual}* | sed -e 's/_1.fastq//g' -e 's/_2.fastq//g' -e 's/.fastq//g' | sort | uniq | while read sample
	do
		file_number=`ls ${sample}*| wc -l`
		echo ${sample}
		
		json=${OUTPUT_DIR}/${sample}.json
                html=${OUTPUT_DIR}/${sample}.html
		if [ ${file_number} = 1 ]; then
			in=${INPUT_DIR}/${sample}.fastq
			out=${OUTPUT_DIR}/${sample}_filtered.fastq
			fastp -i ${in} -o ${out} --trim_poly_g --thread 32 -j ${json} -h ${html}
		else
			in1=${INPUT_DIR}/${sample}_1.fastq
			in2=${INPUT_DIR}/${sample}_2.fastq
			out1=${OUTPUT_DIR}/${sample}_1_filtered.fastq
			out2=${OUTPUT_DIR}/${sample}_2_filtered.fastq
			unpaired=${OUTPUT_DIR}/${sample}_unpaired_filtered.fastq
			fastp -i ${in1} -I ${in2} -o ${out1} -O ${out2} --unpaired1 ${unpaired} --unpaired2 ${unpaired} -j ${json} -h ${html} --correction --trim_poly_g --detect_adapter_for_pe --thread 16 --trim_front1 15 --trim_front2 15
		fi
	done

done
conda deactivate

# Perform multiqc
OUTPUT_MULTIQC_DIR=${OUTPUT_DIR}/multiqc
#mkdir -p ${OUTPUT_MULTIQC_DIR}
#multiqc -o ${OUTPUT_MULTIQC_DIR} ${OUTPUT_DIR}
