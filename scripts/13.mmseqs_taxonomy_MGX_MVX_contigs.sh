# !usr/bin/bash
#########################################################################################################################################################################
# Script: ~/crisprome/hmp/scripts/13.mmseqs_taxonomy_MGX_MVX_contigs.sh
# This script is for assigning taxonomy of megahit-assembled MGX/MVX contigs with mmseqs2, following script 6.
# Last modified: 23.11.6.
#########################################################################################################################################################################

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
INPUT_DIR=${BASE}/intermediates/6.megahit

if [ -z "$1" ]; then
	echo "Please provide the data type for analysis: MGX or MVX."
	exit
elif [ $1 == "MGX" ] || [ $1 == "MVX" ]; then
	object=${1}
	echo "Taxonomies of ${1} contigs will be assigned."
else
	echo "Please provide an available data type: MGX or MVX."
	exit
fi

INPUT_DIR=${BASE}/intermediates/6.megahit/${object}
OUTPUT_DIR=${BASE}/intermediates/13.mmseqs_taxonomy/${object}; mkdir -p ${OUTPUT_DIR}

# Divide the tasks.
if [ -z ${2} ] || [ -z ${3} ]; then
	BEGIN=1
	END=`sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | wc -l`
else
	BEGIN=${2}
	END=${3}
fi

source activate MMseqs2
sed '1d' ${INPUT_LIST} | grep "${object}" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
do
	echo -----------------------------------------------------------------------
	echo ${subject}
	echo "Constructing query database of ${subject}."
	query=${OUTPUT_DIR}/${subject}/query; mkdir -p ${query}
	taxon=${OUTPUT_DIR}/${subject}/taxon; mkdir -p ${taxon}
	contigs=${INPUT_DIR}/${subject}/${subject}_${object}.contigs.fa

	cd ${query}
	mmseqs createdb ${contigs} ${subject}_${object}_querydb # querydb can be removed after assigning taxonomies to save storage.

	QUERYDB=${query}/${subject}_${object}_querydb
	UNIREFDB=~/genome/uniref/mmseqs_uniref100/mmseqs_uniref100_db
	tmp=${taxon}/${subject}_${object}_tmp
	mkdir -p ${tmp}
	RESULT=${taxon}/${subject}_${object}
	TSV=${taxon}/${subject}_${object}.txt

	echo "Assigning taxonomies of ${subject}'s ${object} contigs."
	mmseqs taxonomy ${QUERYDB} ${UNIREFDB} ${RESULT} ${tmp} --lca-ranks species,genus,family,order,class,phylum,kingdom
	mmseqs createtsv ${QUERYDB} ${RESULT} ${TSV}
done
conda deactivate
