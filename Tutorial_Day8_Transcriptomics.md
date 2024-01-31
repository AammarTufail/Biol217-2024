# 
$${\color{red}DAY 8}$$
# 
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
# **Example Run**

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



# 
$${\color{red}Data Set}$$
# 
## Dataset to be used in the example

The dataset you will use today comes from a publication by [*Prasse et al. 2017*](https://doi.org/10.1080/15476286.2017.1306170).

### **How to download the data to be used for RNA_seq Analysis?**

1. Activate the environment:

```bash
#use micromamba to activate grabseq
module load micromamba/1.4.2
micromamba activate 10_grabseqs

# go the folder 
cd $HOME/.micromamba/envs/10_grabseqs/lib/python3.7/site-packages/grabseqslib/
#open sra.py file
#and replace the line 94 with the following one:
metadata = requests.get("https://trace.ncbi.nlm.nih.gov/Traces/sra-db-be/runinfo?acc="+pacc) 
#save it
micromamba deactivate 10_grabseqs
micromamba activate 10_grabseqs
#usegrabseqs now
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
mkdir fastq
cd fastq
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
Or, you can also use the following:

```bash
grabseqs sra -t 4 -m SRP081251
```
</details>

# 
$${\color{Green}QualityControl}$$
# 

### **Quality Control: How to run `fastqc`?**

1. Activate the environment:

```bash
module load micromamba/1.4.2
micromamba activate 01_short_reads_qc
fastqc -t 4 -o fastqc_output *.fastq.gz
```

or use the for loop:

```bash
mkdir ../qc_reports
for i in *.fastq.gz; do fastqc -t 4 -o ../qc_reports/fastqc_output $i; done
```

2. Open the `fastqc_output` folder and check the quality of the reads.

### **How to run `fastp`?**

1. Activate the environment:

```bash
conda activate /home/sunam226/.conda/envs/grabseq
```

2. Run `fastp`:

```bash
fastp -i SRR4018514.fastq.gz -o SRR4018514_cleaned.fastq.gz -h SRR4018514_fastp.html -j SRR4018514_fastp.json -w 4
```

or in a for loop:

```bash
for i in *.fastq.gz; do fastp -i $i -o ${i}_cleaned.fastq.gz -h ../qc_reports/${i}_fastp.html -j ${i}_fastp.json -w 4 -q 20 -z 4; done
```
> `--html` creates an .html report file in html format\
>`-i` input file name\
>`-R` report title, here ‘_report’ is added to each file\
>`-o` output_folder.fastq.gz output file\
>`-t` trim tail 1, default is 0, here 6 bases are trimmed\
>`-q` 20 reads with a phred score of <=20 are trimmed
> `-z`compression level for gzip output (1 ~ 9). 1 is fastest, 9 is smallest, default is 4. (int [=4])
Generating multiqc report can help us further:

```bash
multiqc -d . -o multiqc_output 
```
> `-d` will also count sub folders

<font color="Yellow" size=8> 
Create a .bash script and run that in caucluster:
</font>

<details><summary><b>Here you can see the commands for bash script</b></summary>

```bash
#!/bin/bash
#SBATCH --job-name=qc
#SBATCH --output=qc.out
#SBATCH --error=qc.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH	--qos=long
#SBATCH --time=0-01:00:00
#SBATCH --partition=all
#SBATCH --reservation=biol217

source ~/.bashrc
module load miniconda3/4.7.12.1
conda activate /home/sunam226/.conda/envs/grabseq
mkdir fastq
cd fastq
grabseqs -t 4 -m ./metadata.csv SRR4018514
grabseqs -t 4 -m ./metadata.csv SRR4018515
grabseqs -t 4 -m ./metadata.csv SRR4018516
grabseqs -t 4 -m ./metadata.csv SRR4018517

mkdir ../qc_reports
for i in *.fastq.gz; do fastqc -t 4 -o ../qc_reports/fastqc_output $i; done
for i in *.fastq.gz; do fastp -i $i -o ${i}_cleaned.fastq.gz -h ../qc_reports/${i}_fastp.html -j ${i}_fastp.json -w 4 -q 20 -z 4; done
cd ..
multiqc -d . -o ./qc_reports/multiqc_output 
jobinfo
```
</details>

---

# 
$${\color{red}READemption}$$
# 


## READemption

- To evaluate this dataset you will use [READemption](https://reademption.readthedocs.io/en/latest/) *"a pipeline for the computational evaluation of RNA-Seq data."*
- We have already installed the pipeline in your CAUCLUSTER IDs, however, you can read [this documentation](https://reademption.readthedocs.io/en/latest/installation.html) for more details on installation procedure.
- As the analysis will take a while, you will run a script that includes a pipeline with all READemption commands needed for this analysis.

### **What is the dataset?**
The dataset you will use today comes from a publication by [*Kröger et al. 2013*](https://doi.org/10.1016/j.chom.2013.11.010).

>The aim of the study was to *"`present a simplified approach for global promoter identification in bacteria using RNA-seq-based transcriptomic analyses of 22 distinct infection-relevant environmental conditions. Individual RNA samples were combined to identify most of the 3,838 Salmonella enterica serovar Typhimurium promoters`"* [(*Kröger et al. 2013*)](https://doi.org/10.1016/j.chom.2013.11.010). Twenty two `22` different environmental conditions were used to study the effect on gene expression.

Here you will use a subset of the original dataset including two replicates from two conditions:
> 1. **`InSPI2`** *"an acidic phosphate-limiting minimal media that induces Salmonella pathogenicity 
island (SPI) 2 transcription"*.\
    This is suspected to create an environmental shock that could induce the upregulation of
specific gene sets.
> 2. **`LSP`** growth in Lennox Broth medium

### **Workflow**

The READemption pipeline is divided into 5 steps:
1. **`create`** - Create a project folder and the required subfolders

Create folders:

```bash
reademption create --project_path READemption_analysis --species salmonella="Salmonella Typhimurium"
```

2. **`prepare`** - Prepare the reference sequences and annotations

Save `Ftp source` one time, to be used later several times:

```bash
FTP_SOURCE=ftp://ftp.ncbi.nih.gov/genomes/archive/old_refseq/Bacteria/Salmonella_enterica_serovar_Typhimurium_SL1344_uid86645/
```
Download the `.fasta` files for genome:
```bash
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_016810.fa $FTP_SOURCE/NC_016810.fna
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_017718.fa $FTP_SOURCE/NC_017718.fna
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_017719.fa $FTP_SOURCE/NC_017719.fna
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_017720.fa $FTP_SOURCE/NC_017720.fna
```
Now, we will download the genime annotation file:
```bash
wget -P READemption_analysis/input/salmonella_annotations https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/210/855/GCF_000210855.2_ASM21085v2/GCF_000210855.2_ASM21085v2_genomic.gff.gz
```
unzip the file:
```bash
gunzip READemption_analysis/input/salmonella_annotations/GCF_000210855.2_ASM21085v2_genomic.gff.gz
```
Now, we will change the headers of fasta files `.fa` with the header of annotation file, using following commands:

```bash
sed -i "s/>/>NC_016810.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_016810.fa
sed -i "s/>/>NC_017718.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_017718.fa
sed -i "s/>/>NC_017719.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_017719.fa
sed -i "s/>/>NC_017720.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_017720.fa
```

Now we will download the raw reads as mentioned [here](#dataset-to-be-used-in-the-example):
  
```bash
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/InSPI2_R1.fa.bz2
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/InSPI2_R2.fa.bz2
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/LSP_R1.fa.bz2
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/LSP_R2.fa.bz2
```

----

After downloading the files we will make our `.bash` script and submit the job, as follows:

### **Run via .bash file**
All commands used in the script are described here, step by step.
```bash
#!/bin/bash
#SBATCH --job-name=reademption_
#SBATCH --output=reademption.out
#SBATCH --error=reademption.err
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --qos=long
#SBATCH --time=1-00:00:00
#SBATCH --partition=all
#SBATCH --export=NONE
#SBATCH --reservation=biol217

source ~/.bashrc

#activating conda
module load miniconda3/4.7.12.1
conda activate /home/sunam226/.conda/envs/reademption
reademption align -p 4 --poly_a_clipping --project_path READemption_analysis
reademption coverage -p 4 --project_path READemption_analysis
reademption gene_quanti -p 4 --features CDS,tRNA,rRNA --project_path READemption_analysis
reademption deseq -l InSPI2_R1.fa.bz2,InSPI2_R2.fa.bz2,LSP_R1.fa.bz2,LSP_R2.fa.bz2 -c InSPI2,InSPI2,LSP,LSP -r 1,2,1,2 --libs_by_species salmonella=InSPI2_R1,InSPI2_R2,LSP_R1,LSP_R2 --project_path READemption_analysis
reademption viz_align --project_path READemption_analysis
reademption viz_gene_quanti --project_path READemption_analysis
reademption viz_deseq --project_path READemption_analysis
conda deactivate
jobinfo
```



To run the script by CAUCLUSTER, use the following command:
```bash
sbatch <path/to/READemption_pipeline> #write this path as your own file
```
This command will submit your job to CAUCLUSTER and then you can follow this while it is running.\
If you want to check the status of the script you submitted, use:
```bash
squeue -u sunam***
```

Once you started the script, you can take a look at the single steps. \

### **Run via single commands**
Should you want to re run single steps, use the following conda environment:
```
conda activate Reademption
```

#### *Setup*

First of all you have to prepare the input for READemption.
As the program needs a specific folder structure, you can use the provided command `reademption create` as shown below:
```
reademption create --project_path READemption_analysis salmonella="Salmonella Typhimurium"
```
This will create a folder structure as shown below. It contains both the input and the output folders.
```
READemption_analysis 
├── config.json 
├── input 
│   ├── Salmonella_annotations 
│   ├── Salmonella_reference_sequences 
│   └── reads 
└── output 
    └── align 
        ├── alignments 
        ├── index 
        ├── processed_reads 
        ├── reports_and_stats 
        │   ├── stats_data_json 
        │   └── version_log.txt 
        └── unaligned_reads 
```
More folders containing output files will be added when executing certain analysis.

Before you start the analysis, copy your input files into their respective folders:

Start with the reference sequences. Here you will use the chromosome and three plasmids from *Salmonella*.
The sequences can be retrieved from NCBI, use `wget` to download files directly from the command shell.
Save the general URL for *Salmonella* Typhimurium SL1344’s as the variable `FTP_SOURCE` as you will use it multiple times.

```
FTP_SOURCE=ftp://ftp.ncbi.nih.gov/genomes/archive/old_refseq/Bacteria/Salmonella_enterica_serovar_Typhimurium_SL1344_uid86645/```
```

Now download the sequences in FASTA format using `wget`, use the `-O` flag to specify destination and name of the downloaded file:
Note that the file format is changed from .fna to .fa, as this is a more suitable format for downstream analysis.

```bash
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_016810.fa $FTP_SOURCE/NC_016810.fna
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_017718.fa $FTP_SOURCE/NC_017718.fna
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_017719.fa $FTP_SOURCE/NC_017719.fna
wget -O READemption_analysis/input/salmonella_reference_sequences/NC_017720.fa $FTP_SOURCE/NC_017720.fna
```
> **-O** file name and destination after the download

Now you can download and unzip the .gff3 annotation file using the following link:
```
wget -P READemption_analysis/input/salmonella_annotations https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/210/855/GCF_000210855.2_ASM21085v2/GCF_000210855.2_ASM21085v2_genomic.gff.gz
gunzip READemption_analysis/input/salmonella_annotations/GCF_000210855.2_ASM21085v2_genomic.gff.gz
```
> **-P** destination folder after the download
> **gunzip** unzip .gz files

Next, modify the header of the ref sequence FASTA so that the sequence IDs match the the ones in the first column of the .gff3 file.
```
sed -i "s/>/>NC_016810.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_016810.fa
sed -i "s/>/>NC_017718.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_017718.fa
sed -i "s/>/>NC_017719.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_017719.fa
sed -i "s/>/>NC_017720.1 /" READemption_analysis/input/salmonella_reference_sequences/NC_017720.fa

```
You can open the fasta  and gff3 files and compare the IDs to check if this step worked.

Download the RNA-Seq libraries with the reads in them. In order to make the analysis faster, these are subsamples of 1M reads of the original libraries.
```
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/InSPI2_R1.fa.bz2
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/InSPI2_R2.fa.bz2
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/LSP_R1.fa.bz2
wget -P READemption_analysis/input/reads http://reademptiondata.imib-zinf.net/LSP_R2.fa.bz2
```
Now you have all necessary input. Check the three input folders to make sure the files are where they should be!


#Processing
## Alignment

In the first analysis step you will perform read processing and mapping.
The aim of this is to map the short reads to the reference sequence. This is done in order to assign each read to its origin within the reference genome.

Use `poly_a_clipping` to trim the poly a tail from the reads.  Poly a tales are important for nuclear export, translation and stability of the mRNA, but are not needed for sequence alignments.
```
$ reademption align --processes 4 --poly_a_clipping --project_path READemption_analysis.
```

> **--project_path:** path to the project folder you created \
> **--processes:** number of processes used.  \
> **--poly_a_clipping:**  perfrom poly a clipping \




You can find the staistics as well as files containing the mapped reads and other things in `output/align`.
Take a look at what the single folders contain.
`/reports_and_stats/read_alignment_stats.csv` contains several mapping statistics for each sample,
like the number of successfully aligned reads, number of polyAs detected and so on.


## Coverage

Next you use the `coverage` command. Coverage can be described as the coverage
of each base within the reference sequence by the RNA short reads. $$MORE? COULD INCLUDE A SMALL GRAPH
Use the following command to calculate it:
```
reademption coverage -p 4 --project_path READemption_analysis --paired_end
```
> **--project_path:** path to the project folder \
> **-p:** number of threads

Output files are stored wiggle (.wig) format. This format can be opened with genome browsers like
the Integrated Genome Browser IGB https://www.bioviz.org/ or the Integrative Genome viewer IGV
https://software.broadinstitute.org/software/igv/.
>>Are they going to use it??

In the output folder you will find multiple subfolders:
- `READemption_analysis/output/species1_coverage-raw/` Here you will find the
  raw counting values without normalization. \
- `READemption_analysis/output/species1-tnoar_min_normalized/` Coverage values
  normalized by the total number of aligned reads (tnoar) multiplied by the lowest number of
  aligned reads of all considered libraries. \
- `READemption_analysis/output/species1_coverage-tnoar_mil_normalized/`
  coverage values normalized by the total number of aligned reads and multiplied by one million.    \

Keep in mind that, in order to identify gene expression variations coming from biological
factors, you have to account for differences coming from library size and composition
(if the library for condition *a* includes more reads than the one for condition *b*, it might
look like genes of *a* are more expressed than *b*). Normalization filters these differences out
and makes the results comparable

A forward and reverse evaluation is performed for each strand, where the forward values are
positive and the reverse values are negative. This makes a visual evaluation of the results easier.

## Gene wise quantification

Gene expression quantification compares the sequenced reads to a genomic or transcriptomics reference sequence.  
Here you will quantify the number of reads that align with the annotations found in the .gff3 file.
You can specify feature classes that you want to be considered with `--features`. These can be gene,
CDS or tRNA for example, and can be found in the 'Features' column of your annotations.gff3 file.

```
reademption gene_quanti -p 4 --features CDS,tRNA,rRNA --project_path READemption_analysis
```
> **-p:** number of processes \
> **--project_path:** path to the project folder \
> **--features:**  comma separated list of features that should be considered

Results are structured as follows:
- `READemption_analysis/output/species1_gene_quanti_per_lib/`
  containing a coverage file for each sample showing the number of reads 'covering' each entry of the annotations file,
  -`READemption_analysis/output/species1_gene_quanti_combined/` containing normalized
  coverage values of each sample (combined into one file):
    - **...tpm.csv** contains values Transcript per Million normalized counts.
      (for each 1M RNA molecules in the sample, x come from this gene). TPM considers the gene
      length for normalization.

$$ TPM=   \frac{ total \quad reads \quad mapped \quad to \quad gene * 10^3} {gene \quad length \quad in \quad bp} $$

- **...rpkm.csv** contains the reads per kilobase million normalized read counts.
  it can be used  to compare differentially expressed genes between experimental
  conditions. Generally a higher value means a higher level of expression of the gene.
  RPKM is proportional to tpm. Here $10^3$ normalizes for gene length and $10^6$ for sequencing depth factor.

$$  RPKM = \frac{ total \quad number \quad of \quad reads \quad mapped \quad per \quad  gene * 10^3 * 10^6}  {total \quad number \quad of \quad mapped \quad reads * gene \quad length \quad in \quad bp} $$



- **...tnoar.csv** values are normalized by the total number of aligned reads of the given library

$$ TNOAR=   \frac{ raw\quad reads \quad countings}  {total \quad number \quad of \quad aligned \quad reads} $$

For more information on RPKM, tpm and other normalization methods, check the box below

## Differential gene expression analysis

To perform this step READemption uses DESeq2, an R library used for
differential gene expression analysis using a negative binomial distribution.
(http://bioconductor.org/packages/devel/bioc/vignettes/DESeq2/inst/doc/DESeq2.html)
Negative binomial distribution is used as gene expression data is not normally distributed
(for more information on that check the Additional information section).


```
reademption deseq --libs InSPI2_R1.fa.bz2,InSPI2_R2.fa.bz2,LSP_R1.fa.bz2,LSP_R2.fa.bz2 -c InSPI2,InSPI2,LSP,LSP -r 1,2,1,2 --libs_by_species salmonella=InSPI2_R1,InSPI2_R2,LSP_R1,LSP_R2 project_path READemption_analysis
```
> **--project_path:** path to the project folder \
> **--libs** provide a comma separated list of libraries \
> **--conditions** comma separated conditions, in the same order as the libraries \

>>COMMENT: Maybe more explanation on libs and conditions?

You will find the output in
`READemption_analysis/output/salmonella_deseq/deseq_with_annotations/`.
DESeq will compare all conditions with each other and create -csv files for each comparison.
These files contain most information found in the annotation file (Sequence name, source...)
enriched with results from countings, like raw counting for each sample. \
- **baseMean:** mean of normalized counts of all samples. Note that it does not take into account gene length, it is used in DESeq2 to calculate the
  dispersion of a gene.

- **log2FoldChange:**  This parameter describes the difference when comparing two things.
  Lets say for example, Gene *i* has a raw count of 2 in Group *a* and 1 in Group *b*, the
  this would result in a two fold increase (fold change is calculated as the ratio of A/B or
  B/A). You can then log2 transform the result, resulting in the following values:

|        | raw countings A | raw countings B | fold change A/B | fold change B/A | log2fc A | log2fc B |
|--------|-----------------|-----------------|-----------------|-----------------|----------|----------|
| Gene i |        2        |        1        |        2        |       0.5       |     1    |    -1    |
| Gene j |        1        |        1        |        1        |        1        |     0    |     0    |
| Gene k |        1        |        0        |        0        |        0        |    NA    |    NA    |


Log2foldChange transformation should give you values with a symmetrical and linear relationship, which should
make them easier to understand (for an in depth explanation see Additional information).

-**lfcSE** is the standard error of the log2 fold change parameter.
-**stat:** DESeq2 uses the Wald test to identify genes that are differentially expressed between two sample classes.
-**pvalues:** p value resulting from the Wald test. It basically tells you if there is a statistically
significant difference between the two groups you are comparing for each gene.
-**padj:** is p adjusted (probably the most important column of the results). It shows the p value, adjusted by
Benjamini-Hochberg false discovery rate. P value corrections need to be done when testing
multiple hypothesis against the same data, as this can lead to false positives.

>> Depending on how this is used, we might need a bit more explanation. Check
> https://reademption.readthedocs.io/en/latest/example_analysis.html#multi-species-analysis for more


# Results
## plot creation

We can now create different plots to visualize the results:

```
reademption viz_align --project_path READemption_analysis

```
`viz_align` creates two documents containing histograms showing the
distribution of read lengths before (input_read_length_distribution.pdf) and after
clipping (processed_reads_length_distributions.pdf).
An example of a post processing graph can be seen below:

<p align="center" width="100%">
    <img width="50%" src="https://github.com/AammarTufail/RNA-seq_mattias/blob/main/images/processed_read_length_distribution.jpg" />
</p>

```
reademption viz_gene_quanti --project_path READemption_analysis
```
`viz_gene_quanty` generates a two documents:\
- expression_scatter_plots.pdf is a scatterplot where raw gene wise quantification
  values (log scaled) are compared for each library pair. An r value is given for each plot.
  Note how different the plots look when you compare repetitions of the same conditions
  (eg InSPI2_R1 vs InSPI2_R2) and tow different conditions (eg LSP_R1 vs InSPI2_R1).
  In the first case we have a very good correlation between the two probes, as we would expect
  when comparing two replicates of the same condition. The second graph shows how most genes are still expressed similarly
  under two conditions, but some genes are more expressed under one condition than the other.

<p align="center" width="100%">
  <img width="45%" src="https://github.com/AammarTufail/RNA-seq_mattias/blob/main/images/expression_sp_InSPI2_R1_vs_R2.jpg"  />
  <img width="45%" src="https://github.com/AammarTufail/RNA-seq_mattias/blob/main/images/expression_sp_InSPI2_vs_LSP.jpg"  />
</p>

- rna_class_sizes.pdf shows the proportion of the features selected in `gene_quanti` for each sample.

<p align="center" width="100%">
    <img width="50%" src="https://github.com/AammarTufail/RNA-seq_mattias/blob/main/images/rna_class_sizes.jpg" />
</p>


```
reademption viz_deseq --project_path READemption_analysis
```
`viz_deseq` generates 3 plots. \
- **MA_plot:** shows the log2fold changes (M) against the mean (A) of normalized counts for all the samples in the dataset (baseMean).
  Values coloured red have an adjusted p value padj <= 0.1. Another way of saying this:
  the plot shows magnitude of change (x) against statistical significance (y)
  Outliers are shown as tringles pointing either up or down.

<p align="center" width="100%">
    <img width="50%" src="https://github.com/AammarTufail/RNA-seq_mattias/blob/main/images/MA_InSPI2_LSP.jpg" />
</p>

- **2 volcano_plots:** show the log 2 fold change plotted against the -log transformed p value
  and against the -log transformed, adjusted p value (shown in the plot below). A few things on volcano plots:
    - each dot represents a gene.
    - The x axes shows us the log2 fold change values, negative values hint to downregulated genes,
      positive values hint to upregulated ones (values around 0 show little change).

    - The y axes shows us the -log transformed (adjusted) p value. Due to the transformation,
      statistically significant values can be found in the upper part of the graph (A high value
      on the y-axis means a low p value).

    - the green dotted lines are drawn at x=+-1 and y=+-1.3 (-log10 0.05) which represents the cutoff
      to statistical significance.

  This all means that genes in the upper right quadrant (demarcated by the green lines) show a statistically significant upregulation
  while those in the upper left quadrant show a statistically significant downregulation.

<p align="center" width="100%">
    <img width="50%" src="https://github.com/AammarTufail/RNA-seq_mattias/blob/main/images/volcano_plots_log2_fold_change_vs_adjusted_p-value.jpg" />
</p>


# Additional informations:

Pubblication of the dataset:\
**An infection-relevant transcriptomic compendium for Salmonella enterica Serovar Typhimurium \
DOI: 10.1016/j.chom.2013.11.010** \
https://pubmed.ncbi.nlm.nih.gov/24331466/

Blog entry on different normalization methods: \
https://www.reneshbedre.com/blog/expression_units.html#:~:text=RPKM%20(reads%20per%20kilobase%20of,abundance)%20of%20genes%20or%20transcripts \
Video on RPKM and TPM, how to calculate them and when to use which one: \
https://www.youtube.com/watch?v=TTUrtCY2k-w \

log2 fold change explanation for DESeq2: \
https://www.youtube.com/watch?v=mq6UvDneKc0

In depth explanation on why negative binomial distribution is used for deseq and how to prepare the input data: \
https://www.youtube.com/watch?v=UFB993xufUU

Interpretation of volcano plots: \
https://www.youtube.com/watch?v=7aWAdw2jhj0

<!-- 
# JUNK

First you will run poly a clipping to prepare the reads:
```
reademption align -p 4 --poly_a_clipping --project_path READemption_analysis
```
> **-p:** number of CPUs to use \
> **--poly_a_clipping:** tell READemption what to do in this step \
> **--project_path:** specify the path to the project folder you just created \

Took this part out. I ran it before the first align command, but I dont think that makes+
any sense. Cant run poly a clipping and paired end reads in one command.


>>COMMENT: Cynthia added questions for the students, so here might be a good place
> for some questions regarding the results from the alignment, here is a possible box one could use for questions:

<div class="warning" style='padding:0.1em; background-color:Navy'>
<span>
<p style='margin-top:1em; text-align:center'>
<b>Questions:</b></p>
<p style='margin-left:1em;'>
Here one can add a question: below is some space for possible answers

</p></span>
</div>

Math formulas:
http://www.sciweavers.org/free-online-latex-equation-editor

normalization factors
https://www.reneshbedre.com/blog/expression_units.html#:~:text=RPKM%20(reads%20per%20kilobase%20of,abundance)%20of%20genes%20or%20transcripts -->
