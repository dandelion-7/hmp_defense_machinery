# /miniconda3/bin/R
# This script is for summarizing all the output matrix from featureCounts because each subject has different numbers of samples, so loop required for processing.
library(tidyr)
library(dplyr)
library(stringr)

getwd()
setwd('~/crisprome/hmp/scripts/')

# rectify the featureCounts matrix of MGX
subjects <- c(2039, 2041, 2042, 2047, 2048, 2060, 2061, 2072, 2075, 
              2077, 2079, 2084, 2097, 3022, 4008, 4009, 4013, 4016,
              4018, 4022, 4023, 4024, 4045, 5002, 6014, 6017, 6018)
row_counts <- c()
for (i in subjects) {
  print(i)
  count_matrix_dir <- paste("~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/featureCounts/MGX/",
                        as.character(i), "_MGX_featureCounts.txt", sep = "")
  print(count_matrix_dir)
  
  count_matrix <- read.table(count_matrix_dir, sep = '\t', header = T, skip = 1)
  row_counts <- c(row_counts, nrow(count_matrix))
  
  count_matrix <- count_matrix %>% gather(key = 'sample', value = 'mapping_counts',
                                          colnames(count_matrix)[7:length(colnames(count_matrix))])
  
  output_dir <- paste("~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/featureCounts/MGX/",
                      as.character(i), "_MGX_tidy_featureCounts.txt", sep = "")
  count_matrix %>% write.table(file = output_dir, sep = "\t", 
                               col.names = T, row.names = F, quote = F)
}
sum(row_counts)

# ------------------------------------------------------------------------------
# rectify the featureCounts matrix of MTX
subjects <- c(2039, 2041, 2042, 2047, 2048, 2060, 2061, 2072, 2075, 
              2077, 2079, 2084, 2097, 3022, 4008, 4009, 4013, 4016,
              4018, 4022, 4023, 4024, 4045, 5002, 6014, 6017, 6018)
row_counts <- c()
for (i in subjects) {
  print(i)
  count_matrix_dir <- paste("~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/featureCounts/MTX/",
                            as.character(i), "_MTX_featureCounts.txt", sep = "")
  print(count_matrix_dir)
  
  count_matrix <- read.table(count_matrix_dir, sep = '\t', header = T, skip = 1)
  row_counts <- c(row_counts, nrow(count_matrix))
  
  count_matrix <- count_matrix %>% gather(key = 'sample', value = 'mapping_counts',
                                          colnames(count_matrix)[7:length(colnames(count_matrix))])
  
  output_dir <- paste("~/crisprome/hmp/intermediates/16.antiphage_machinery_stats/featureCounts/MTX/",
                      as.character(i), "_MTX_tidy_featureCounts.txt", sep = "")
  count_matrix %>% write.table(file = output_dir, sep = "\t", 
                               col.names = T, row.names = F, quote = F)
}
sum(row_counts)
