# !/usr/bin/bash

#########################################################################################################################################################################
# Script: ~/crisprome/hmp/scripts/11.DAS_tool_binning.sh
# This script is for binning the assembled MGX contigs from each individual with the bam files through bowtie2 mapping, following script 6&9. metabat2 and maxbin2 will be used separatedly for binning.
# Last modified: 23.11.3.
#########################################################################################################################################################################

BASE=~/crisprome/hmp
INPUT_LIST=~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata
INPUT_CONTIGS_DIR=${BASE}/intermediates/6.megahit/MGX
INPUT_BAM_DIR=${BASE}/intermediates/9.bowtie2_contigs_MGX_MTX/MGX/bam

# Determine the command: metabat2 or maxbin2
if [ -z "$1" ]; then
	echo "please provide the command you want to use for binning: metabat2 or maxbin2."
	exit
elif [ ${1} == "metabat2" ] || [ ${1} == "maxbin2" ]; then
	command=${1}
	OUTPUT_DIR=${BASE}/intermediates/11.DAS_tool_binning/${command}; mkdir -p ${OUTPUT_DIR}
else
	echo "please provide an available command: metabat2 or maxbin2."
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


if [ ${command} == "metabat2" ]; then
	source activate metabat2
	sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
	do
		echo ---------------------------------------------
                echo ${subject}

		subject_depth_dir=${OUTPUT_DIR}/${subject}/depth; mkdir -p ${subject_depth_dir}
		subject_bin_dir=${OUTPUT_DIR}/${subject}/bin; mkdir -p ${subject_bin_dir}
		depth=${subject_depth_dir}/${subject}_depth.txt
		bam=`ls ${INPUT_BAM_DIR}/${subject}*_MGX_sorted.bam | xargs`
		contigs=${INPUT_CONTIGS_DIR}/${subject}/${subject}_MGX.contigs.fa

		jgi_summarize_bam_contig_depths --minContigLength 1500 --outputDepth ${depth} ${bam}
		metabat2 -m 1500 -i ${contigs} -o ${subject_bin_dir}/${subject} -a ${depth} -t 32 --unbinned --verbose > ${subject_bin_dir}/${subject}_metabat2.log

	done
	conda deactivate
else
	sed '1d' ${INPUT_LIST} | grep "MGX" | awk '{print $1}' | sort | uniq | sed -n "${BEGIN}, ${END}p" | while read subject
        do
                echo ---------------------------------------------
                echo ${subject}

                subject_counts_dir=${OUTPUT_DIR}/${subject}/counts; mkdir -p ${subject_counts_dir}
                subject_bin_dir=${OUTPUT_DIR}/${subject}/bin; mkdir -p ${subject_bin_dir}

		cd ${INPUT_BAM_DIR}
		sed '1d' ${INPUT_LIST} | grep "MGX" | grep "${subject}" | awk '{print $6}'| sort | while read sample
		do
			bam=${sample}_sorted.bam
			idxstats=${subject_counts_dir}/${sample}.idxstats
			counts=${subject_counts_dir}/${sample}.counts
			samtools idxstats ${bam} > ${idxstats}
			cut -f1,3 ${idxstats} > ${counts}
		done

		source activate maxbin2
		counts_list=${subject_counts_dir}/${subject}_counts.list; ls ${subject_counts_dir}/${subject}*.counts > ${counts_list}
                contigs=${INPUT_CONTIGS_DIR}/${subject}/${subject}_MGX.contigs.fa
		run_MaxBin.pl -contig ${contigs} -abund_list ${counts_list} -out ${subject_bin_dir}/${subject} -min_contig_length 500 -thread 32 -verbose > ${subject_bin_dir}/${subject}_maxbin2.log
		conda deactivate

        done
fi


#source activate metabat2
#seq ${BEGIN} ${END} | while read i
#do
	depth=${OUTPUT_DIR_BAM_DEPTH}/${i}"_depth.txt"
	contig=${INPUT_CONTIGS_DIR}/${i}/${i}".contigs.fa"
	bin=${OUTPUT_DIR_BIN}/${i}
#	mkdir -p ${bin}

#	bam=`ls ${INPUT_BAM_DIR}/${i}_*_TD*.sorted.bam | sed 's/\n/ /g'`
#	echo ${bam}
#	echo ----------------------------------------------
	
#	jgi_summarize_bam_contig_depths --minContigLength 500 --outputDepth ${depth} ${bam}
#	metabat2 -m 1500 -i ${contig} -o ${bin}/${i} -a ${depth}
#done

#conda deactivate
