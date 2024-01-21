# !/usr/bin/bash
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script:~/crisprome/hmp/scripts/18-2.taxonkit.sh
# This script is for converting the taxids assigned by MMseqs2 to each contig into the taxonomic names with taxonkit. It is part of the script 18-1 for summarzing the taxonomic annotations of contigs.
# Last modified: 24.1.20.
# child running.
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#taxonkit lineage 2039_taxids.txt --threads 64 | taxonkit reformat -f "{k}\t{p}\t{c}\t{o}\t{f}\t{g}\t{s}" -F -P --out-file 2039_taxons.txt

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
INPUT_OUTPUT_DIR=${BASE}/intermediates/18.taxonomy_annotation/summarized_mmseqs2_results

source activate taxonkit
sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | while read subject
do
	echo --------------------------------------
	echo ${subject}
	taxid=${INPUT_OUTPUT_DIR}/${subject}_taxids.txt
	taxon=${INPUT_OUTPUT_DIR}/${subject}_taxons.txt
	taxonkit lineage ${taxid} --threads 8 | taxonkit reformat -f "{k}\t{p}\t{c}\t{o}\t{f}\t{g}\t{s}" -F -P --out-file ${taxon}
done
