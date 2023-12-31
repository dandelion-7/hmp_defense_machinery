library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)

getwd()
setwd('~/crisprome/hmp/scripts/')

# ==============================================================================
# summarize info of all predicted CDS.
total_cds <- read.csv('~/crisprome/hmp/intermediates/12.defense_gene_prediction/prodigal/total_CDS.txt', 
                      header = F, sep = ';')
colnames(total_cds) <- c('CDS', 'start', 'end', 'strand', 'ID', 'partial', 
                         'start_type', 'rbs_motif', 'rbs_spacer', 'gc_cont')
total_cds <- total_cds %>% mutate(attributes = paste(ID, partial, start_type, rbs_motif, rbs_spacer, gc_cont, 
                                                               sep = ';'))
total_cds <- total_cds[, -c(5:10)]

cds <- as.data.frame(total_cds$CDS)
cds <- separate(data = cds, col = `total_cds$CDS`, sep = '_', 
                into = c('subject','object', 'kmer', 'contig',
                         'flag', 'multi', 'contig_len', 'cds_id'))
cds$contig_id <- paste(cds$subject, cds$object, cds$kmer, cds$contig, 
                       cds$flag, cds$multi, cds$contig_len, sep = '_')
total_cds <- cbind(total_cds, cds[, c(1, 9, 7, 8)])
total_cds %>% write.table('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/gene_annotation/16-1-1.total_cds_summary.txt', 
                          sep = '\t', row.names = F, col.names = T, quote = F) # generate table
# ==============================================================================

# ==============================================================================
# summarize info of all predicted anti-phage related genes/systems.
total_defense_systems <- read.delim('~/crisprome/hmp/intermediates/12.defense_gene_prediction/defenseFinder/merged_defensefinder_systems.tsv',
                                    sep = '\t', header = T)
system_size <- total_defense_systems[, c('sys_id', 'genes_count')]
total_defense_genes <- read.delim('~/crisprome/hmp/intermediates/12.defense_gene_prediction/defenseFinder/merged_defensefinder_genes.tsv', 
                                  sep = '\t', header = T)
colnames(total_defense_genes)[2] <- 'CDS'

total_defense_CDS <- str_split_fixed(string = total_defense_systems$protein_in_syst, pattern = ',', n = 11)
total_defense_systems <- cbind(total_defense_systems, total_defense_CDS)
total_defense_systems[total_defense_systems == ""] <- NA
total_defense_systems <- total_defense_systems %>% gather(key = 'gene_id', value = 'CDS', 
                                                          colnames(total_defense_systems)[9:19])
total_defense_systems <- total_defense_systems[!(is.na(total_defense_systems$CDS)), ]
total_defense_genes <- left_join(total_defense_genes, total_defense_systems, by = 'CDS')
total_defense_genes %>% write.table('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/gene_annotation/16-1-2.total_defense_genes_summary.txt', 
                                    sep = '\t', row.names = F, col.names = T, quote = F)
# ==============================================================================

# ==============================================================================
# merge the info of total CDSs with total defense genes.
total_cds <- read.delim('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/gene_annotation/16-1-1.total_cds_summary.txt', 
                        sep = '\t', header = T)
total_defense_genes <- read.delim('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/gene_annotation/16-1-2.total_defense_genes_summary.txt',
                                  sep = '\t', header = T)
total_cds <- left_join(total_cds, total_defense_genes, by = 'CDS')
total_cds$gene_name[is.na(total_cds$gene_name)] <- 'non-defense-gene'
total_cds$CDS_new <- str_replace_all(total_cds$CDS, pattern = "=", replacement = ":")
total_cds$gene_name_new <- paste("gene_name=", total_cds$gene_name, "+", total_cds$CDS_new, sep = "")
total_cds$gene_len <- paste("gene_len=", as.character(total_cds$end - total_cds$start), sep = "")
total_cds$attributes <- paste(total_cds$attributes, total_cds$contig_len, total_cds$gene_len, total_cds$gene_name_new, sep = ";")
total_cds$annotation_source <- "Prodigal+DefenseFinder"
total_cds$annotation_type <- "CDS"
total_cds$phase <- 0
total_cds[is.na(total_cds)] <- "."
total_cds %>% write.table('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/gene_annotation/16-1-3.total_cds_with_fine_annotation.txt', 
                          sep = '\t', row.names = F, col.names = T, quote = F)
# Write each subject's cds annotation.
for (i in unique(total_cds$subject)) {
  print(i)
  subject_cds <- total_cds[total_cds$subject == i, ]
  subject_cds_name <- paste('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/gene_annotation/16-1-3.',
                            as.character(i), "_cds_with_fine_annotation.txt", sep = "")
  subject_cds %>% write.table(file = subject_cds_name, sep = "\t", quote = F, row.names = F, col.names = T)
}
# ==============================================================================

# ==============================================================================
# Extract columns from the total cds annotation list into the gff table.
total_cds <- read.delim('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/gene_annotation/16-1-3.total_cds_with_fine_annotation.txt', 
                        sep = '\t', header = T)
total_gff <- total_cds[, c('contig_id', 'annotation_source', 'annotation_type', 
                           'start', 'end', "hit_i_eval", 
                           "strand", "phase", "attributes", "subject")]
total_gff %>% write.table('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/gene_annotation/16-1-4.total_gff_with_subject.txt', 
                          sep = '\t', row.names = F, col.names = T, quote = F)

# Write each subject's gff annotation.
for (i in unique(total_cds$subject)) {
  print(i)
  subject_gff <- total_gff[total_gff$subject == i, 1:9]
  subject_gff_name <- paste('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/gff/', as.character(i), "_MGX.gff", sep = "")
  subject_gff %>% write.table(file = subject_gff_name, sep = "\t", quote = F, row.names = F, col.names = F)
}
# ==============================================================================