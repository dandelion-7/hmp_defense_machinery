library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(randomcoloR)

getwd()
setwd('~/crisprome/hmp/scripts/')

# ==============================================================================
# Counting matrix for each subject will be too large after merging, so a loop will be adopted to summarize the counts independently.
# Test with one subject's file first.
subject_cds <- read.delim('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/gene_annotation/16-1-3.2039_cds_with_fine_annotation.txt',
                          sep = "\t", header = T)
mapping_counts <- read.delim('~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/simplified_counts/MGX/2039_MGX_simplified_featureCounts.txt', 
                             sep = '\t', header = F)
colnames(mapping_counts) <- c("gene_name", "CDS", "sample", "mapping_count", "subject")
samples <- as.data.frame(mapping_counts$sample)
samples <- separate(data = samples, col = `mapping_counts$sample`, sep = "_", 
                    into = c("subject", "time_point", "hospital",
                             "disease", "data_type", "file_extension"))
mapping_counts <- cbind(mapping_counts, samples[, c(2:5)])
sample_reads_sum <- mapping_counts %>% group_by(sample) %>% 
  summarise(sample_total_reads = sum(mapping_count))
mapping_counts <- left_join(mapping_counts, sample_reads_sum, by = 'sample')

mapping_counts <- left_join(mapping_counts, subject_cds[, c(1:39)], 
                            by = c("CDS", "gene_name", "subject"))
defense_genes_counts <- mapping_counts %>% filter(gene_name != "non-defense-gene")
sample_defense_gene_reads_sum <- defense_genes_counts %>% group_by(sample) %>% 
  summarize(sample_defense_gene_reads = sum(mapping_count))
defense_genes_counts <- left_join(defense_genes_counts, sample_defense_gene_reads_sum, by = 'sample')

# sample_defense_gene_reads_sum$sample_defense_gene_reads / sample_reads_sum$sample_total_reads
sample_type_reads <- defense_genes_counts %>% group_by(sample, subject, time_point, type) %>% 
  summarise(sample_type_reads = sum(mapping_count))
sample_type_reads <- left_join(sample_type_reads, sample_reads_sum, by = 'sample')
sample_type_reads <- left_join(sample_type_reads, sample_defense_gene_reads_sum, by = 'sample')
sample_type_reads$type_proportion <- sample_type_reads$sample_type_reads / sample_type_reads$sample_defense_gene_reads
sample_type_reads <- sample_type_reads %>% mutate(type_legend = case_when(
  type_proportion >= 0.01 ~ type,
  type_proportion < 0.01 ~ 'others'
))
n_distinct(sample_type_reads$type_legend)
color_33 <- c("#bdbdbd", "#C8E8C1", "#A8A390", "#5ADC7F", "#DBB65D", "#E2888F", "#AECDE4", "#6A8EA8", "#E7C4A9",
              "#DDEAE4", "#DD47D9", "#70E0D9", "#B9E88C", "#D68A56", "#E55446", "#8A39EA", "#E54F9A",
              "#5BC0E8", "#A57099", "#E4DB55", "#E7E79E", "#C5F057", "#6389DC", "#83E6AF", "#74A16B",
              "#E99BD4", "#74E547", "#685BCB", "#B3A7E9", "#C774D8", "#E0C3D9", "#bdbdbd", "#737373")
sample_type_reads$type_legend <- reorder(sample_type_reads$type_legend, c(sample_type_reads$type_proportion))
sample_type_reads %>% ggplot(aes(x = time_point, y = type_proportion)) + 
  geom_col(aes(fill = type_legend)) + 
  scale_fill_manual(values = color_33)
sample_defense_gene_reads_sum$sample_defense_gene_reads/sample_reads_sum$sample_total_reads
