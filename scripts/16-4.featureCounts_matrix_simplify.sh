# !/usr/bin/bash
#---------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/16-4.merge_featureCounts_results.sh
# This script is for merging the featureCount output matrix after rectifying, folowing script 16-3.
# Last modified: 23.11.15.
#---------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
INPUT_MGX_DIR=${BASE}/intermediates/16.antiphage_machinery_stats/featureCounts/MGX
INPUT_MTX_DIR=${BASE}/intermediates/16.antiphage_machinery_stats/featureCounts/MTX
OUTPUT_MGX_DIR=${BASE}/intermediates/16.antiphage_machinery_stats/simplified_counts/MGX; mkdir -p ${OUTPUT_MGX_DIR}
OUTPUT_MTX_DIR=${BASE}/intermediates/16.antiphage_machinery_stats/simplified_counts/MTX; mkdir -p ${OUTPUT_MTX_DIR}

cd ${INPUT_MGX_DIR}
sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | while read subject
do
	echo ${subject}
	matrix=${INPUT_MGX_DIR}/${subject}_MGX_tidy_featureCounts.txt
	output=${OUTPUT_MGX_DIR}/${subject}_MGX_simplified_featureCounts.txt
	sed '1d' ${matrix} | awk -F "\t" '{print $1,$7,$8,'"${subject}"'}' | grep "SE_sorted.bam" -v | sed -e 's/+/\t/g' -e 's/:/=/g' -e "s/X${subject}/${subject}/g" -e "s/ /\t/g" >> ${output}
done

cd ${INPUT_MTX_DIR}
sed '1d' ${INPUT_LIST} | grep "MTX" | awk '{print $1}' | sort | uniq | while read subject
do
        echo ${subject}
        matrix=${INPUT_MTX_DIR}/${subject}_MTX_tidy_featureCounts.txt
	output=${OUTPUT_MTX_DIR}/${subject}_MTX_simplified_featureCounts.txt
        sed '1d' ${matrix} | awk -F "\t" '{print $1,$7,$8,'"${subject}"'}' | grep "SE_sorted.bam" -v | sed -e 's/+/\t/g' -e 's/:/=/g' -e "s/X${subject}/${subject}/g" -e "s/ /\t/g" >> ${output}
done
