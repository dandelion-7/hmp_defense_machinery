# !/usr/bin/bash
# --------------------------------------------------------------------------------------------------------------------
# Script: /home/zhanggaopu/crisprome/hmp/scripts/20-3.defense_system_coverage_calculation.sh
# This script is for calculating the coverage of defense systems by the MGX/MTX sequencing results with samtools.
# Last modified: 24.2.27.
# --------------------------------------------------------------------------------------------------------------------

# Determine the data type: MGX or MTX.
if [ -z "$1" ]; then
    echo "Please tell to convert the bam files from MGX or MTX data alignment."
    exit
elif [ ${1} == "MGX" ]||[ ${1} == "MTX" ]; then
    data_type=${1}
else
    echo "Please provide an available data type: MGX or MTX."
    exit
fi

BASE=/home/zhanggaopu/crisprome/hmp
INPUT_DIR=${BASE}/intermediates/9.bowtie2_contigs_MGX_MTX/${data_type}
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
DEFENSE_SYSTEMS_INPUT=${BASE}/intermediates/20.coverage_analysis/system_position_summary
OUTPUT_DIR=${BASE}/intermediates/20.coverage_analysis/coverge_depth/${data_type}; mkdir -p ${OUTPUT_DIR}

# Divide the task.
if [ -z ${2} ] || [ -z ${3} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq| wc -l`
else
	BEGIN=${2}
	END=${3}
fi

sed '1d' ${INPUT_LIST} | grep "${1}" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
    echo -----------------------------------------
    echo ${subject}
    defense_systems_list=${DEFENSE_SYSTEMS_INPUT}/${subject}_systems_coverage.txt
    total_line_num=`cat ${defense_systems_list} | wc -l`
    line_num=1
    mkdir -p ${OUTPUT_DIR}/${subject}

    cd ${INPUT_DIR}/bam
    bam_files=`ls ${subject}*_${data_type}_sorted.bam`
    # echo ${bam_files}
    output_head=`ls ${subject}*_${data_type}_sorted.bam | xargs | sed 's/ /\t/g'`
    # echo -e "contig\tposition\t${output_head}" # echo -e allows the "\t" translated as a tab note.

    cat ${defense_systems_list} | while read region file_name
    do
        echo -n -e ${file_name}";\t"; echo ${line_num}/${total_line_num}
        line_num=`expr ${line_num} + 1`

        output=${OUTPUT_DIR}/${subject}/${file_name}.txt
        cat /dev/null > ${output}
        echo -e "contig\tposition\t${output_head}" >> ${output}
        samtools depth -Q 10 -r ${region} -aa ${bam_files} >> ${output}
    done
done