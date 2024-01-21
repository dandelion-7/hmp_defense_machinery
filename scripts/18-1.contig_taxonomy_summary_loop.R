# R
# ------------------------------------------------------------------------------
# Script: /media/atm1/user10/crisprome/scripts/18-1.contig_taxonomy_summary_loop.R
# This script is for summarizing the taxonomy annotations of all subjects in a loop.
# boyfriend running.
# ------------------------------------------------------------------------------

# set paths
getwd()
setwd("/media/atm1/user10/crisprome/scripts")

# Load libraries
library(ggplot2)
library(tidyr)
library(stringr)
library(dplyr)
library(utils)

# Set basic parameters: input_list and subjects
input_list <- read.table("/media/atm1/user10/crisprome/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata.txt", header = T, sep = "\t")
subjects <- as.array(as.character(unique(input_list[,1])))
base <- "/media/atm1/user10/crisprome/"

## Test the loop for setting paths of input/output files.
for (subject in subjects){
  mmseqs2_matrix_input <- paste(base, "intermediates/13.mmseqs_taxonomy_temp/", subject, "_MGX.txt", sep = "")
  # originally from ~/crisprome/hmp/intermediates/13.mmseqs_taxonomy/MGX/2039/taxon/2039_MGX.txt in medcluster.
  mmseqs2_matrix_temp <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_mmseqs_matrix_temp.txt", sep = "")
  taxid_output <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_taxids.txt", sep = "")
  taxon_input <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_taxons.txt", sep = "")
  contig_taxon_matrix_output <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_summarized_contig_taxon_matrix.txt", sep = "")
  
  print(subject)
  print(mmseqs2_matrix_input)
  print(mmseqs2_matrix_temp)
  print(taxid_output)
  print(taxon_input)
  print(contig_taxon_matrix_output)
}

## Summarize the taxonomy annotation table from mmseqs2.
for (subject in subjects){
  print(subject)
  mmseqs2_matrix_input <- paste("/media/atm1/user10/crisprome/intermediates/13.mmseqs_taxonomy_temp/", subject, "_MGX.txt", sep = "")
  mmseqs2_matrix_temp <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_mmseqs_matrix_temp.txt", sep = "")
  taxid_output <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_taxids.txt", sep = "")
  taxon_input <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_taxons.txt", sep = "")
  contig_taxon_matrix_output <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_summarized_contig_taxon_matrix.txt", sep = "")
  
  
  mmseqs2_matrix <- read.delim(file = mmseqs2_matrix_input, sep = "\t", header = F)
  contigs <- as.data.frame(mmseqs2_matrix$V1)
  contigs <- separate(contigs, `mmseqs2_matrix$V1`, sep = "_", into = c("subject", "data_type", "kmer", "id", "flag", "multi", "len"))
  mmseqs2_matrix$subject <- as.numeric(contigs$subject)
  mmseqs2_matrix$contig_len <- as.numeric(str_remove_all(contigs$len, "len="))
  colnames(mmseqs2_matrix)[1:8] <- c("contig", "taxid", "rank", "taxon", "total_orf", "assigned_orf", "corresponding_orf", "-logE")
  mmseqs2_matrix <- mmseqs2_matrix[, -c(3, 4, 9)]
  mmseqs2_matrix %>% write.table(file = mmseqs2_matrix_temp, col.names = T, row.names = F, quote = F)
  
  taxid <- mmseqs2_matrix$taxid
  taxid %>% write.table(file = taxid_output, col.names = F, row.names = F, quote = F)
}

## Convert taxids into taxonomic names with Taxonkit.
### bash 18-2.taxonkit.sh on child.

## Integrate the taxonomy annotations with the contig table.
for (subject in subjects){
  mmseqs2_matrix_input <- paste("/media/atm1/user10/crisprome/intermediates/13.mmseqs_taxonomy_temp/", subject, "_MGX.txt", sep = "")
  mmseqs2_matrix_temp <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_mmseqs_matrix_temp.txt", sep = "")
  taxid_output <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_taxids.txt", sep = "")
  taxon_input <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_taxons.txt", sep = "")
  contig_taxon_matrix_output <- paste(base, "intermediates/18.taxonomy_annotation/summarized_mmseqs2_results/", subject, "_summarized_contig_taxon_matrix.txt", sep = "")
  
  mmseqs2_matrix <- read.delim(file = mmseqs2_matrix_temp, header = T, sep = "\t")
  taxon <- read.delim(file = taxon_input, sep = "\t", header = F)
  colnames(taxon) <- c("taxid", "mmseqs2_taxon", "mmseqs2_kingdom", "mmseqs2_phylum", "mmseqs2_class", "mmseqs2_order", "mmseqs2_family", "mmseqs2_genus", "mmseqs2_species")
  contig_taxon_matrix <- cbind(mmseqs2_matrix[, -2], taxon[, -c(1, 2)])
  colnames(contig_taxon_matrix)[1] <- "contig_id"
  contig_taxon_matrix %>% write.table(file = contig_taxon_matrix_output, sep = "\t", col.names = T, row.names = F, quote = F)
}

### all the mmseqs2_matrix_temp files are deleted after running.