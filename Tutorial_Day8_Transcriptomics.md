###
$${\color{red}DAY 8}$$
### 
# RNA-Seq analysis (Transcriptomics) - Tutorial

## Aim 
The aim of this tuorial is to train you in:
- Setting up RNA-Seq data analysis pipeline
- RNA-Seq data pre-processing
- RNA-Seq Data Analysis
- Differential Gene Expression
- Data Visualization
- Functional enrichment Analysis

You will: 
- Download the required files
- Setting up the files in specific locations
- Checking read quality
- Align the reads to a reference sequence
- Calculate the coverage
- Perform gene wise quantification
- Calculate differential gene expression
- Much more....

## Tools used
| Tool        | Version | Repository                                                                        |
|-------------|---------|-----------------------------------------------------------------------------------|
| READemption |  2.0.3  | [link](https://reademption.readthedocs.io/en/latest/) |
| DESeq2      |   4.2   | [link](http://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html) |
| edgeR       |   3.32  | [link](https://bioconductor.org/packages/release/bioc/vignettes/edgeR/inst/doc/edgeRUsersGuide.pdf) |
| limma       |   3.46  | [link](https://bioconductor.org/packages/release/bioc/vignettes/limma/inst/doc/usersguide.pdf) |
| R           |   4.1.0 | [link](https://cran.r-project.org/) |
| RStudio     |   1.4.1717 | [link](https://rstudio.com/) |
| Kallisto    |   0.48.0 |  [link](https://github.com/pachterlab/kallisto)


<!-- > COMMENT
Short introduction with an aim!
If we use multiple tools, add table with tools, version and link to github
> ALSO; > https://reademption.readthedocs.io/en/latest/example_analysis.html#multi-species-analysis for more
Tutorial taken from here, both commands and part of the explanation, mention as source -->

---
### **Example Run**

### 
$${\color{Yellow}Example1}$$
### 

## **The Dataset we will use**
The dataset you will use today comes from a publication by [*Kröger et al. 2013*](https://doi.org/10.1016/j.chom.2013.11.010).

>The aim of the study was to *"`present a simplified approach for global promoter identification in bacteria using RNA-seq-based transcriptomic analyses of 22 distinct infection-relevant environmental conditions. Individual RNA samples were combined to identify most of the 3,838 Salmonella enterica serovar Typhimurium promoters`"* [(*Kröger et al. 2013*)](https://doi.org/10.1016/j.chom.2013.11.010). Twenty two `22` different environmental conditions were used to study the effect on gene expression.

Here you will use a subset of the original dataset including two replicates from two conditions:
> 1. **`InSPI2`** *"an acidic phosphate-limiting minimal media that induces Salmonella pathogenicity 
island (SPI) 2 transcription"*.\
    This is suspected to create an environmental shock that could induce the upregulation of
specific gene sets.
> 2. **`LSP`** growth in Lennox Broth medium

> **Here you have the complete script for exampel analysis.**

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=0-04:00:00
#SBATCH --job-name=reademption_tutorial
#SBATCH --output=reademption_tutorial.out
#SBATCH --error=reademption_tutorial.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0

#set proxy environment to download the data and use the internet in the backend
export http_proxy=http://relay:3128
export https_proxy=http://relay:3128
export ftp_proxy=http://relay:3128

conda activate reademption
# create folders
reademption create --project_path READemption_analysis --species salmonella="Salmonella Typhimurium"

# Download the files
FTP_SOURCE=ftp://ftp.ncbi.nih.gov/genomes/archive/old_refseq/Bacteria/Salmonella_enterica_serovar_Typhimurium_SL1344_uid86645/
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_016810.fa $FTP_SOURCE/NC_016810.fna
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_017718.fa $FTP_SOURCE/NC_017718.fna
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_017719.fa $FTP_SOURCE/NC_017719.fna
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_017720.fa $FTP_SOURCE/NC_017720.fna

#rename the files similar to the genome naming
sed -i "s/>/>NC_016810.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_016810.fa
sed -i "s/>/>NC_017718.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_017718.fa
sed -i "s/>/>NC_017719.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_017719.fa
sed -i "s/>/>NC_017720.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_017720.fa
wget -P READemption_analysis/input/salmonella_annotations https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/210/855/GCF_000210855.2_ASM21085v2/GCF_000210855.2_ASM21085v2_genomic.gff.gz

# unzip the file
gunzip READemption_analysis/input/salmonella_annotations/GCF_000210855.2_ASM21085v2_genomic.gff.gz
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/InSPI2_R1.fa.bz2
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/InSPI2_R2.fa.bz2
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/LSP_R1.fa.bz2
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/LSP_R2.fa.bz2

#read alignment
reademption align -p 4 --poly_a_clipping --project_path READemption_analysis

# read coverage
reademption coverage -p 4 --project_path READemption_analysis

# gene quantification
reademption gene_quanti -p 4 --features CDS,tRNA,rRNA --project_path READemption_analysis
reademption deseq -l InSPI2_R1.fa.bz2,InSPI2_R2.fa.bz2,LSP_R1.fa.bz2,LSP_R2.fa.bz2 -c InSPI2,InSPI2,LSP,LSP -r 1,2,1,2 --libs_by_species salmonella=InSPI2_R1,InSPI2_R2,LSP_R1,LSP_R2 --project_path READemption_analysis

# visualzation
reademption viz_align --project_path READemption_analysis
reademption viz_gene_quanti --project_path READemption_analysis
reademption viz_deseq --project_path READemption_analysis
conda deactivate
module purge
jobinfo

```



### 
$${\color{red}Example2}$$
### 
## Dataset to be used in the example

The dataset you will use today comes from a publication by [*Prasse et al. 2017*](https://doi.org/10.1080/15476286.2017.1306170).

### **How to download the data to be used for RNA_seq Analysis?**

> 1. Find the accession number of the data you want to download, mentioned in the published paper.
> 2. Go to the NCBI website and search for the accession number.
> 3. Download the data from SRA database.
> 4. Find the `SRR numbers` of the data you want to download. and run the following commands:

1. Activate the environment:

```bash
#use micromamba to activate grabseq
module load micromamba/1.4.2
micromamba activate 10_grabseqs
```

2. Download the data specifying the SRA:

<font color="Yellow" size=6> 
Open the paper from this <a href="https://doi.org/10.1080/15476286.2017.1306170">Prasse et al. 2017</a>, find out the SRR numbers, quantity of samples and treatments, and write down here:
</font>

---

```bash
grabseqs sra -t 4 -m metadata.csv SRR***
```
<details><summary><b>Here you can see the commands</b></summary>
Nevigate to new folder:
```bash
mkdir fastq_raw
cd fastq_raw
```
Download the data specifying the SRA:

```bash
grabseqs sra -t 4 -m ./metadata.csv SRR4018514
grabseqs sra -t 4 -m ./metadata.csv SRR4018515
grabseqs sra -t 4 -m ./metadata.csv SRR4018516
grabseqs sra -t 4 -m ./metadata.csv SRR4018517
```

Or, you can also use the following:

```bash
grabseqs sra -t 4 -m metadata.csv SRR4018514 SRR4018515 SRR4018516 SRR4018517
```
</details>

## > **Note:** **_**Rename each SRR*** file according to the sample name. For example, SRR4018514 to `wt_R1.fastq.gz`, SRR4018515 to `wt_R2.fastq.gz`, SRR4018516 to `mut_R1.fastq.gz`, and SRR4018517 to `mut_R2.fastq.gz`.**_**

# 
$${\color{Green}Complete Script}$$
# 

### **Run the following commands in terminal**

```bash
# Activate the environment:
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate reademption

# go to the directory you want to work in
cd $WORK/RNAseq

# create folders
reademption create --project_path READemption_analysis --species metanosarcina="Methanosarcina mazei Gö1"
```

> # `2.` copy the reference genome and annotation files to the input folder

> # `3.` copy the raw_reads to the READemption_analysis/input/reads folder


> # `4.` Run the following commands after optimization for complete analysis in the backend.
>
> **Note:** **_**Change the names according to your file names present in the READemption_analysis/input/reads/ directory**_**

> You can also download the script from here: [link](./RNAseq/rna_seq_methanosarcina.sh), if you do not have sequence and annotation files for the genomes you may find here: `.fasta file` [link](./RNAseq/genome_input/sequence.fasta) and `.gff file` [link](./RNAseq/genome_input/annotation.gff3)

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=0-04:00:00
#SBATCH --job-name=rna_seq_methanosarcina
#SBATCH --output=rna_seq_methanosarcina.out
#SBATCH --error=rna_seq_methanosarcina.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate reademption

## 1. create a directory for the analysis
# reademption create --project_path READemption_analysis \
# 	--species metanosarcina="Methanosarcina mazei Gö1"

#2- copy the sequences and files in respective directories
# download the sequences from the NCBI database or github folder named "genome_input"

#3- Processing and aligning the reads
reademption align --project_path READemption_analysis \
	--processes 32 --segemehl_accuracy 95 \
	--poly_a_clipping \
	--fastq --min_phred_score 25 \
	--progress

#4- Coverage
reademption coverage --project_path READemption_analysis \
	--processes 32

#5- Performing gene wise quantification
reademption gene_quanti --project_path READemption_analysis \
	--processes 32 --features CDS,tRNA,rRNA 

#6- Performing differential gene expression analysis 

####NOTE:: Change the names according to your file names in the READemption_analysis/input/reads/ directory
reademption deseq --project_path READemption_analysis \
	--libs mut_R1.fastq.gz,mut_R2.fastq.gz,wt_R1.fastq.gz,wt_R2.fastq.gz \
	--conditions mut,mut,wt,wt --replicates 1,2,1,2 \
	--libs_by_species metanosarcina=mut_R1,mut_R2,wt_R1,wt_R2

#7- Create plots 
reademption viz_align --project_path READemption_analysis
reademption viz_gene_quanti --project_path READemption_analysis
reademption viz_deseq --project_path READemption_analysis

# The whole command will take around 2 hours to run.
conda deactivate
module purge
jobinfo
```



---


