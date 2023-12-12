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

After finishing script 5 and 7, filtered data from script 3 can be deleted for storage space.

### 4/4-1/4-2/4-3/4-4
Script 4s performs fastqc on the datasets after fastp filtering. Because MGX/MTX/MVX files were grouped, so the script 4s are also splited for different types of files. Outputs of fastqc were classified according to library types (MGX/MTX/MVX) and visualized with multiqc. 

<font color=red>Because the IBDMDB datasets are from two studies, all the step above are done separately for data from the two studies. Output folders without specification are from the Nature paper, and with $nat_microbiol$ prefix are from the Nature Microbiology paper. For script 3/4s, the input/output directories in the scripts might be for Nature or Nat.Microbiol paper.</font>

<font color=red>Hereafter, the filtered MGX/MTX/MVX files from the two studies are put into a merged folder for MGX/MTX/MVX separately. And the downstream analysis won't specify the Nature/Nat.Microbiol paper.</font>

### 5
Script 5 performs bowtie2 of MGX/MTX/MVX reads onto human genome to eliminate human-derived reads.

### 6-1/6-2
Script 6s performs read assembly with megahit. Each subject's MGX/MVX samples at different time points were pooled for mixed assembly.

Megahit accepts multiple PE/SE files separated with comma, so the `xargs` was used in the script for substituting `\n` with `,` through sed command. Meanwhile, must follow `megahit [options] {-1 <pe1> -2 <pe2> | --12 <pe12> | -r <se>} [-o <out_dir>]` the order of parameters/input files, options need to be set before the files.

### 7
Script 7 is more mapping MTX reads onto rRNA reference, so as to eliminate the rRNA contamination in the metatranscriptomic data. The rRNA bowtie2 reference is from QQ, which works fairly well.

Fasta files of LSU/SSU rRNA were downloaded from SILVA, and constructed into reference with `bowtie2-build`, but the mapping rates of MTX were very low. So the exact input file for rRNA reference should be further considered.

### 8
Script 8 uses geNomad to extract virus/plasmid contigs from the assembled contigs of MGX/MVX data. "total" or "without-nn" end-to-end flows of geNomad were both run on the MGX/MVX contigs.

The `--threads` of "total" mode need to be low. 2 is OK.

### 9
Script 9 uses bowtie2 to align filtered MGX (from script 5) and MTX (from script 7) to assembled MGX contigs.

### 10
Script 10 performs dereplication of the assembled MGX/MTX contigs from script 6 with CD-HIT. 

The sequence identity (0.95) and alignment coverage over shorter sequences (0.9) are referred to other publications: 
1.Viruses interact with hosts that span distantly related microbial domains in dense hydrothermal mats, 2023, Nature Microbiology. (0.95; 0.85)
2.Genomic variation and strain-specific functional adaptation in the human gut microbiome during early life, 2019, Nature Microbiology. (0.95; 0.9)
3.Elevated rates of horizontal gene transfer in the industrialized human microbiome, 2021, Cell. (0.9 identity with vsearch).

<font color=red>CD-HIT is too slow for the large amounts of assembled contigs. Script 10 is not finished.</font>

### 11-1/11-2/11-3
Script 11-1 performs contig binning with metabat2/maxbin2 with contigs from script 6 and mapping results from script 9. The results of binning might be further used for DAS tools to optimize the bins.

Script 11-2/3 are designed for combining the binning results from Metabat2 and MaxBin2 to refine the bins with DAS Tool, but DAS Tool can't run successfully, so the script is not done currently.

### 12-1/12-2
Script 12-1 split all the assembled long contigs (>=500) into 500 subsets, which allows easy running of DefenseFinder. Then prodigal will predict all the CDSs from the contigs.

Script 12-2 utilizes DefenseFinder to predict possible anti-phage defense related genes.

### 13
Script 13 uses MMseqs2 to assign taxonomies to the assembled contigs.

### 14
Script 14 evaluates the quality (completeness and contamination) of bins, and assign taxonomy.

### 15
Script 15 assign taxonomy to the bins.

### 16s
Script 16s summarizes the results of defense-related genes' annotation to generate the gff files (1). And through featureCounts, the quantity of mapped reads onto predicted defense genes are obtained (2-4). Then the abundances of these defense related genes in MGX and MTX datasets are summarized for all subjects (5-7).
