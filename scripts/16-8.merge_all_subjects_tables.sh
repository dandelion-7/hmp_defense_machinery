# !/usr/bin/bash
#---------------------------------------------------------------------------------------------------
# Script: ~/crisprome/hmp/scripts/16-8.merge_all_subjects_tables.sh
# This script is for merging all the summarized tables from 16-7 of each subject.
# Last modified: 23.12.13.
#---------------------------------------------------------------------------------------------------

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
INPUT_DIR=${BASE}/intermediates/16.antiphage_machinery_stats/all_subjects_stat

cd ${INPUT_DIR}
sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | while read subject
do
	echo ---------------------------------------------------------------------------
	echo ${subject}

	ls ${subject}*.txt | sed "s/${subject}_//g" | while read table
	do
		echo ${table}
		if [ ${subject} == "2039" ]; then
			cat /dev/null > total_${table} # if the script is run again, remove previous contents.
			head -n 1 ${subject}_${table} >> total_${table}
		fi
		sed '1d' ${subject}_${table} >> total_${table}
	done
done
