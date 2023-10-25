# This script summarizes the dataset information: subject(individual), time point, hospital, disease status(UC/CD/nonIBD), library type(16s/metagenome/metatranscriptome/virome).
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
getwd()
setwd('~/crisprome/hmp/intermediates/1.dataset_summary/')
library(readr)
library(readxl)
library(XML)

# from HMP portal
files <- read.table('./hmp_manifest_875273de4e.tsv', header = T, sep = '\t')
files$size <- as.numeric(files$size)/1e+09
samples <- read.table('./hmp_manifest_metadata_97710de305.tsv', 
                      header = T, sep = '\t')
total_info <- cbind(files, samples)
total_info <- total_info[, -5]
total_info <- total_info %>% mutate(omic = case_when(
  str_detect(urls, 'genome') & str_detect(urls, 'raw') ~ 'metagenome',
  str_detect(urls, 'transcriptome') & str_detect(urls, 'raw') ~ 'metatranscriptome'
))
accessible_info <-  total_info[!(str_detect(total_info$urls, 'Private')), ]
accessible_info %>% ggplot(aes(x = size)) + geom_histogram() + 
  scale_x_continuous(limits = c(0, 10), 
                     breaks = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)) + 
  facet_grid(study_full_name ~ omic, scales = 'free') 

# data list from ENA
# files <- read.table('~/crisprome/hmp/intermediates/1.dataset_summary/IBDMDB_PRJNA398089_filereport_tsv.txt',
                    # header = T, sep = '\t')
files <- read.table('~/crisprome/hmp/intermediates/1.dataset_summary/IBDMDB_PRJNA398089_filereport_tsv.txt', 
                      header = T, sep = '\t', quote = "")

# summarize fastq md5 of downloaded data.
fastq_md5 <- as.data.frame(files$fastq_md5)
fastq_md5[, 2:3] <- fastq_md5 %>% separate(`files$fastq_md5`, sep = ';', into = c('fastq_md5_1', 'fastq_md5_2'))

# summarize downloading links of datasets
fastq_ftp <- as.data.frame(files$fastq_ftp)
fastq_ftp[, 2:3] <- fastq_ftp %>% separate(`files$fastq_ftp`, sep = ';', into = c('fastq_ftp_1', 'fastq_ftp_2'))

fastq_aspera <- as.data.frame(files$fastq_aspera)
fastq_aspera[, 2:3] <- fastq_aspera %>% separate(`files$fastq_aspera`, sep = ';', into = c('fastq_ascp_1', 'fastq_ascp_2'))

# summarize sample information of data.
subject <- as.data.frame(files$sample_alias)
subject[, 2] <- subject %>% separate(`files$sample_alias`, sep = '_', into = c('sample_info'))
subject <- subject %>% mutate(hospital = substr(sample_info, 1, 1), 
                              subject_id = substr(sample_info, 2, 5),
                              time_point = substr(sample_info, 6, 20),)

# summarize library types (metagenome/metatranscriptome/virome) of data.
libraries <- as.data.frame(files$library_name)
libraries[, 2:4] <- libraries %>% separate(`files$library_name`, sep = '_', into = c('sample_id', 'library_type_1', 'library_type_2'))
libraries[is.na(libraries)] <- 0
libraries <- libraries %>% mutate(library_type = case_when(
  library_type_2 == 0 ~ library_type_1,
  library_type_2 != 0 ~ paste(library_type_1, library_type_2, sep = '-')
))

# merge summarized info into primary data frame.
files <- cbind(files, subject[, 2:5], libraries[, c(2, 5)], fastq_ftp[, 2:3], fastq_aspera[, 2:3], fastq_md5[, 2:3])
n_distinct(files$subject_id)
n_distinct(files$sample_id)

# summarizing metadata of samples
samples <- xmlParse('IBDMDB_biosample_result.xml') %>% xmlToDataFrame()

# extract SRS id
samples <- samples[, -c(3, 7, 8)]
samples_ids <- as.data.frame(samples$Ids)
samples_ids[, 2:3] <- samples_ids %>% separate(`samples$Ids`, sep = 'SRS', 
                                               into = c('sample_id', 'SRS'))
samples_ids <- samples_ids %>% mutate(SRS_id = paste('SRS', SRS, sep = ''))

# extract disease status of each subject
diseases <- samples[, c(1, 5)]
diseases <- diseases %>% mutate(subject_id = substr(Ids, 13, 17), 
                                subject_id_1 = substr(Ids, 14, 17))
diseases <- diseases %>% mutate(disease_status = case_when(
  str_detect(Attributes, 'disease') | str_detect(Attributes, 'CD') ~ 'CD',
  str_detect(Attributes, 'colitis') | str_detect(Attributes, 'UC') ~ 'UC',
  subject_id == 'H4004' ~ 'CD'
))
diseases$disease_status[is.na(diseases$disease_status)] <- 'nonIBD'
diseases_summary <- diseases %>% group_by(subject_id_1) %>% 
  summarize(subject_number = n_distinct(disease_status))

samples <- cbind(samples_ids, diseases)[, c(4, 6, 8, 9)]
colnames(samples)[1] <- 'secondary_sample_accession'

files <- left_join(files, samples, by = 'secondary_sample_accession')
files <- files %>% mutate(new_name = paste(subject_id, time_point, hospital, disease_status, library_type, sep = '_'))

files %>% write.table('./1-0.HMP2_IBDMDB_dataset_summary.txt', quote = F, 
                      sep = '\t', row.names = F, col.names = T)

# generating files for downloading datasets.
total <- read.delim('~/crisprome/hmp/intermediates/1.dataset_summary/1.HMP2_IBDMDB_dataset_summary.txt', sep = '\t', header = T)
total <- read.table('~/crisprome/hmp/intermediates/1.dataset_summary/1.HMP2_IBDMDB_dataset_summary.txt', quote = "", sep = '\t', header = T)
nonIBD <- total %>% filter(disease_status == 'nonIBD')
IBD <- total %>% filter(disease_status != 'nonIBD')

# summarize SRR
nonIBD_SRR <- as.data.frame(nonIBD$run_accession)
nonIBD_SRR %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-1.nonIBD_SRR.txt', 
                        quote = F, col.names = F, row.names = F)
IBD_SRR <- as.data.frame(IBD$run_accession)
IBD_SRR %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-1.IBD_SRR.txt', 
                           quote = F, col.names = F, row.names = F)

# summarize ftp links
nonIBD_ftp <- c(nonIBD$fastq_ftp_1, nonIBD$fastq_ftp_2)
nonIBD_ftp %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-2.nonIBD_ftp.txt', 
                           quote = F, col.names = F, row.names = F)
IBD_ftp <- c(IBD$fastq_ftp_1, IBD$fastq_ftp_2)
IBD_ftp %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-2.IBD_ftp.txt', 
                           quote = F, col.names = F, row.names = F)

# summarize ascp links
nonIBD_ascp <- c(nonIBD$fastq_ascp_1, nonIBD$fastq_ascp_2)
nonIBD_ascp %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-3.nonIBD_ascp.txt', 
                            quote = F, col.names = F, row.names = F)
IBD_ascp <- c(IBD$fastq_ascp_1, IBD$fastq_ascp_2)
IBD_ascp %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-3.IBD_ascp.txt', 
                            quote = F, col.names = F, row.names = F)

# summarize fastq md5
nonIBD_fastq_md5 <- rbind(
  cbind(nonIBD$fastq_md5_1, paste(nonIBD$run_accession, '_1.fastq.gz', sep = '')),
  cbind(nonIBD$fastq_md5_2, paste(nonIBD$run_accession, '_2.fastq.gz', sep = ''))
  )
nonIBD_fastq_md5 %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-4.nonIBD_fastq_md5.txt', 
                           quote = F, col.names = F, row.names = F, sep = '\t')
IBD_fastq_md5 <- rbind(
  cbind(IBD$fastq_md5_1, paste(IBD$run_accession, '_1.fastq.gz', sep = '')),
  cbind(IBD$fastq_md5_2, paste(IBD$run_accession, '_2.fastq.gz', sep = ''))
)
IBD_fastq_md5 %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-4.IBD_fastq_md5.txt', 
                                 quote = F, col.names = F, row.names = F, sep = '\t')

# summarize sra md5
nonIBD_sra_md5 <- cbind(nonIBD$sra_md5, paste(nonIBD$run_accession, '.sra', sep = ''))
nonIBD_sra_md5 %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-5.nonIBD_sra_md5.txt', 
                               quote = F, col.names = F, row.names = F, sep = '\t')
IBD_sra_md5 <- cbind(IBD$sra_md5, paste(IBD$run_accession, '.sra', sep = ''))
IBD_sra_md5 %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-5.IBD_sra_md5.txt', 
                            quote = F, col.names = F, row.names = F, sep = '\t')

# summarize new-name
total_rename <- cbind(total$run_accession, total$new_name)
total_rename %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-6.total_rename.txt', 
                              quote = F, col.names = F, row.names = F, sep = '\t')

# summarize metadata
nonIBD_metadata <- nonIBD[, c("subject_id", "time_point", "hospital", 
                              "library_type", "disease_status", "new_name")]
nonIBD_metadata$time_point_num <- as.numeric(gsub(x = nonIBD_metadata$time_point, 
                                                  pattern = "[[:upper:]]", replacement = "")) # delete all letters in the time_point column.
nonIBD_metadata <- nonIBD_metadata[order(nonIBD_metadata$subject_id, nonIBD_metadata$time_point_num, nonIBD_metadata$library_type),] # sort according to subject_id/time_point_num/library_type
nonIBD_metadata %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-7.nonIBD_metadata.txt', sep = '\t', col.names = T, row.names = F, quote = F)
IBD_metadata <- IBD[, c("subject_id", "time_point", "hospital", 
                        "library_type", "disease_status", "new_name")]
IBD_metadata$time_point_num <- as.numeric(gsub(x = IBD_metadata$time_point, 
                                               pattern = "[[:upper:]]", replacement = "")) # delete all letters in the time_point column.
IBD_metadata <- IBD_metadata[order(IBD_metadata$subject_id, IBD_metadata$time_point_num, IBD_metadata$library_type),] # sort according to subject_id/time_point_num/library_type
nonIBD_metadata %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-7.IBD_metadata.txt', sep = '\t', col.names = T, row.names = F, quote = F)

#-------------------------------------------------------------------------------
# summarize another part of paired metagenomic-metatranscriptomic data from IBDMDB, (Nature Microbiology 2018)

# summarize new names
nat_micro <- read.delim('~/crisprome/hmp/intermediates/1.dataset_summary/IBDMDB_PRJNA389280_filereport_tsv.txt', 
                      sep = '\t', header = T)
intersect(nat_micro$run_accession, total$run_accession)
nm_names <- as.data.frame(nat_micro$experiment_title)
nm_names <- nm_names %>% separate(`nat_micro$experiment_title`, sep = 'Subject ', into = c('sample', 'subject'))
nm_names <- nm_names %>% separate(subject, sep = '_', into = c('sample_info', 'library_type'))
nm_names$hospital <- substr(nm_names$sample_info, 1, 1)
nm_names$subject_id <- as.numeric(substr(nm_names$sample_info, 2, 5))
nm_names$time_point <- substr(nm_names$sample_info, 6, length(nm_names$sample_info))
nm_names <- nm_names[, -1]
nm_names <- left_join(nm_names, nature_names[, c('subject_id', 'disease_status')], by = 'subject_id')
hmp2_metadata <- read.delim('~/crisprome/hmp/intermediates/1.dataset_summary/hmp2_metadata.csv', 
                            sep = ',', header = T, fill = NA)
hmp2_total_names <- hmp2_metadata[, c(3, 71)]
hmp2_total_names$subject_id <- as.numeric(substr(hmp2_total_names$Participant.ID, 2, 5))
hmp2_total_names <- hmp2_total_names[!duplicated(hmp2_total_names[, 2:3]), 2:3]
nm_names <- left_join(nm_names, hmp2_total_names, by = 'subject_id')
colnames(nm_names)[6] <- 'disease_status'
nm_names$new_name <- paste(nm_names$subject_id, nm_names$time_point,
                           nm_names$hospital, nm_names$disease_status,
                           nm_names$library_type, sep = '_')

nm_fastq <- nat_micro[, c('fastq_md5', 'fastq_ftp', 'fastq_aspera')]
nm_fastq <- nm_fastq %>% separate(fastq_md5, sep = ';', into = c('fastq_md5_unpaired', 'fastq_md5_1', 'fastq_md5_2'))
nm_fastq <- nm_fastq %>% separate(fastq_ftp, sep = ';', into = c('fastq_ftp_unpaired', 'fastq_ftp_1', 'fastq_ftp_2'))
nm_fastq <- nm_fastq %>% separate(fastq_aspera, sep = ';', into = c('fastq_aspera_unpaired', 'fastq_aspera_1', 'fastq_aspera_2'))

nat_micro <- cbind(nat_micro, nm_fastq, nm_names)
nat_micro %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-0.Nat_Microbiol_IBDMDB_dataset_summary.txt', 
                          col.names = T, row.names = F, sep = '\t', quote = F)

nat_micro_IBD <- nat_micro %>% filter(disease_status != 'nonIBD')
nat_micro_nonIBD <- nat_micro %>% filter(disease_status == 'nonIBD')

# summarize srr
nat_micro_IBD_SRR <- nat_micro_IBD$run_accession
nat_micro_IBD_SRR %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-1.Nat_Microbiol_IBD_SRR.txt', 
                                  col.names = F, row.names = F, quote = F, sep = '\t')
nat_micro_nonIBD_SRR <- nat_micro_nonIBD$run_accession
nat_micro_nonIBD_SRR %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-1.Nat_Microbiol_nonIBD_SRR.txt', 
                                  col.names = F, row.names = F, quote = F, sep = '\t')

# summarize sra md5
nat_micro_IBD_sra_md5 <- cbind(nat_micro_IBD$sra_md5, paste(nat_micro_IBD$run_accession, '.sra', sep = ''))
nat_micro_IBD_sra_md5 %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-5.Nat_Microbiol_IBD_sra_md5.txt', 
                                      sep = '\t', col.names = F, row.names = F, quote = F)
nat_micro_nonIBD_sra_md5 <- cbind(nat_micro_nonIBD$sra_md5, paste(nat_micro_nonIBD$run_accession, '.sra', sep = ''))
nat_micro_nonIBD_sra_md5 %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-5.Nat_Microbiol_nonIBD_sra_md5.txt', 
                                      sep = '\t', col.names = F, row.names = F, quote = F)

# summarize new names
nat_micro_rename <- cbind(nat_micro$run_accession, nat_micro$new_name)
nat_micro_rename %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-6.Nat_Microbiol_rename.txt', 
                                 sep = '\t', col.names = F, row.names = F, quote = F)

# summarize metadata
nat_micro_nonIBD_metadata <- nat_micro_nonIBD[, c("subject_id", "time_point", "hospital", 
                              "library_type", "disease_status", "new_name")]
nat_micro_nonIBD_metadata$time_point_num <- gsub('[[:upper:]]', '', nat_micro_nonIBD_metadata$time_point)
nat_micro_nonIBD_metadata %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-7.Nat_Microbiol_nonIBD_metadata.txt', 
                                          sep = '\t', col.names = T, row.names = F, quote = F)
nat_micro_IBD_metadata <- nat_micro_IBD[, c("subject_id", "time_point", "hospital", 
                                            "library_type", "disease_status", "new_name")]
nat_micro_IBD_metadata$time_point_num <- gsub('[[:upper:]]', '', nat_micro_IBD_metadata$time_point)
nat_micro_IBD_metadata %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-7.Nat_Microbiol_IBD_metadata.txt', 
                                        sep = '\t', col.names = T, row.names = F, quote = F)

# merged_metadata 
merged_IBD_metadata <- rbind(IBD_metadata, nat_micro_IBD_metadata)
merged_IBD_metadata %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_IBD_metadata', 
                                    sep = '\t', col.names = T, row.names = F, quote = F)
merged_nonIBD_metadata <- rbind(nonIBD_metadata, nat_micro_nonIBD_metadata)
merged_nonIBD_metadata %>% write.table('~/crisprome/hmp/intermediates/1.dataset_summary/1-8.total_nonIBD_metadata', 
                                       sep = '\t', col.names = T, row.names = F, quote = F)

# nature_names <- total[, c('sample_info', 'hospital', 'subject_id', 'time_point', 'library_type', 'disease_status')]
# nature_names <- nature_names[!duplicated(nature_names[, c('subject_id', 'disease_status')]),]
# nature_names <- left_join(nature_names, hmp2_total_names, by = 'subject_id')