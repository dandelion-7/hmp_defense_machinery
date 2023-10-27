# Anti-phage immune machinery analysis with HMP2 (iHMP) IBDMDB dataset.

In this repository, combined analysis of longitudinally paired MGX/MTX of healthy subjects from the IBDMDB branch of HMP2 is performed. It is aimed to analyze the genetic and transcriptonal features of anti-phage machineries of the commensal gut microbiome.

## Scripts annotation
### 1-1/1-2
Scripts 1-1/1-2 are for summarizing the downloading links, md5sum codes, metadata annotations, and the new names (with subject, time point, hospital, diagnosis, library type) of HMP2' IBDMDB/T2D branches.

Metadata annotation of the T2D branch is not clear, so the dataset from the T2D branch will not be used for further analysis.

Datasets of the IBDMDB branch is mainly covered by two studies, *Multi-omics of the gut microbial ecosystem in inflammatory bowel diseases, 2019, Nature* and *Dynamics of metatranscription in the inflammatory bowel disease gut microbiome, 2018, Nature Microbiology*, so in 1-1, the summarizing is also divided into two parts. Summarized output files are also divided according to the two studies, and the output files 1-8 contains the metadata of the total dataset containing the two studies.

Dataset downloading was done with ·prefetch SRRxxxxxxxx·. <font color=red> Only sequencing data from healthy (nonIBD) subjects are downloaded. </font>

### 2
Script 2 performs fastqc on the downloaded raw data. Outputs of fastqc were classified according to library types (MGX/MTX/MVX) and visualized with multiqc.

### 3-1/3-2/3-3
Script 3s use fastp to trim adaptors, filter low-quality reads, and curate overlapped bases.

For MGX datasets, script 3-1 trims the first 15bp at the 5'end of paired reads, because according to results of scritp2, there's a typically skewed A/T/C/G distribution during the first 15bp.

For MTX/MVX datasets, script 3-2/3-3 trims the first 5bp at the 5'end of reads.

### 4/4-1/4-2/4-3/4-4
Script 4s performs fastqc on the datasets after fastp filtering. Because MGX/MTX/MVX files were grouped, so the script 4s are also splited for different types of files. Outputs of fastqc were classified according to library types (MGX/MTX/MVX) and visualized with multiqc. 

<font color=red>Because the IBDMDB datasets are from two studies, all the step above are done separately for data from the two studies. Output folders without specification are from the Nature paper, and with $nat_microbiol$ prefix are from the Nature Microbiology paper. For script 3/4s, the input/output directories in the scripts might be for Nature or Nat.Microbiol paper.</font>

<font color=red>Hereafter, the filtered MGX/MTX/MVX files from the two studies are put into a merged folder for MGX/MTX/MVX separately. And the downstream analysis won't specify the Nature/Nat.Microbiol paper.</font>

### 5
Script 5 performs bowtie2 of MGX/MTX/MVX reads onto human genome to eliminate human-derived reads.
