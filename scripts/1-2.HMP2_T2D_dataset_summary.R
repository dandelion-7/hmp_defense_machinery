# This script is for summarizing the sample information of datasets from T2D study of HMP2.
# But the annotations of dataset are poor (duplicated annotations and data, ambiguous annotation etc), so the data will not be used for analysis.
#----------------------------------------------------------------------------------------------------------------

getwd()
setwd('~/crisprome/hmp/intermediates/1.dataset_summary/')

files <- read.table('T2D_hmp_manifest_22c21c74b9.tsv', header = T, sep = '\t')
samples <- read.table('T2D_hmp_manifest_metadata_2d471065fa.tsv', 
                      header = T, sep = '\t')

files <- cbind(files, samples, by = 'sample_id')
files <- files[, -6]
files$sample_body_site[files$sample_body_site == 'nasal cavity'] <- 'nasal-cavity'
files <- files[!(str_detect(files$urls, 'Private')), ]
files <- files %>% mutate(library_type = case_when(
  str_detect(urls, 'genome') ~ 'MGX',
  str_detect(urls, 'transcriptome') ~ 'MTX', 
))
files <- files %>% mutate(new_name = paste(subject_id, sample_body_site, visit_number, library_type, sep = '_'))

files_summary <- files %>% group_by(new_name) %>% summarize(file_count = n())