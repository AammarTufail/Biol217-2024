### 
$${\color{red}DAY 6}$$
### 


# **Genomics**

- [**Genomics**](#genomics)
  - [AIMs:](#aims)
  - [1. Your data for today](#1-your-data-for-today)
  - [2. Quality Control](#2-quality-control)
    - [2.1. Short reads](#21-short-reads)
      - [2.1.1. Run fastqc](#211-run-fastqc)
      - [2.1.2. Run `fastp`](#212-run-fastp)
    - [2.1.3. Check the quality of the cleaned reads with fastqc again](#213-check-the-quality-of-the-cleaned-reads-with-fastqc-again)
    - [Questions](#questions)
  - [2.2. Long reads](#22-long-reads)
    - [2.2.1. NanoPlot](#221-nanoplot)
    - [2.2.2. Filtlong](#222-filtlong)
    - [2.2.3. NanoPlot again](#223-nanoplot-again)
    - [Questions](#questions-1)
  - [3. Assemble the genome using Uniycler](#3-assemble-the-genome-using-uniycler)
  - [4. Check the assembly quality](#4-check-the-assembly-quality)
    - [4.1. Quast](#41-quast)
    - [4.2. CheckM](#42-checkm)
    - [4.3. CheckM2](#43-checkm2)
    - [4.4. Bandage](#44-bandage)
  - [5. Annotate the Genomes with `Prokka`](#5-annotate-the-genomes-with-prokka)
  - [6. Classifiy the Genomes with `GTDBTK`](#6-classifiy-the-genomes-with-gtdbtk)
  - [7. Run MultiQC](#7-run-multiqc)
  - [Questions](#questions-2)

## AIMs: 
- Step by step understanding of genome assembly.
- To `assemble the genome` of a bacteria from short and long reads.
- We will use hybrid assember for a nice hybrid assembly.
- We will check the quality in [Bandage](https://rrwick.github.io/Bandage/).

> **`Note:`** We will be using `Absolute Paths` in this tutorial. So, please make sure to use the correct paths.
> **For Example:** `$WORK/genomics/0_raw_reads/`

## 1. Your data for today
``` 
cd $WORK/genomics
``` 

> `Do not forget to activate the micromamba environment`

```bash
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
module load micromamba/1.4.2
micromamba activate 01_short_reads_qc
``` 

## 2. Quality Control

### 2.1. Short reads

#### 2.1.1. Run fastqc

You need to create a job script to run `fastqc` and submit the job.

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=5:00:00
#SBATCH --job-name=01_fastqc
#SBATCH --output=01_fastqc.out
#SBATCH --error=01_fastqc.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load micromamba/1.4.2
micromamba activate 01_short_reads_qc


# creata new folder for output of qc 
mkdir -p $WORK/genomics/1_short_reads_qc/1_fastqc_raw
for i in ./add/absolute/path/*.gz; do fastqc $i -o ./add/absolute/path/output_dir/ -t 32; done

jobinfo
```

<details style="background-color: black;">
<summary style="font-size: 28px;"><b>Finished commands</b></summary>

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=5:00:00
#SBATCH --job-name=01_fastqc
#SBATCH --output=01_fastqc.out
#SBATCH --error=01_fastqc.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
module load micromamba3/4.12.0
micromamba activate 01_short_reads_qc

## 1.1 fastqc raw reads
mkdir -p $WORK/genomics/1_short_reads_qc/1_fastqc_raw
for i in *.gz; do fastqc $i -o $WORK/genomics/1_short_reads_qc/1_fastqc_raw -t 32; done
jobinfo
```
</details>


#### 2.1.2. Run `fastp` 

> Add `fastp` command and rerun the job script by commenting/disabling the fastqc command, as shown on [Day-2](./Tutorial_Day2.md).

<details><summary><b>Finished commands</b></summary>

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=5:00:00
#SBATCH --job-name=01_fastqc
#SBATCH --output=01_fastqc.out
#SBATCH --error=01_fastqc.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
module load micromamba3/4.12.0
micromamba activate 01_short_reads_qc

## 1.1 fastqc raw reads
# mkdir -p $WORK/genomics/1_short_reads_qc/1_fastqc_raw
# for i in *.gz; do fastqc $i -o $WORK/genomics/1_short_reads_qc/1_fastqc_raw -t 32; done

## 1.2 fastp 
mkdir -p $WORK/genomics/1_short_reads_qc/2_cleaned_reads
fastp -i $WORK/genomics/0_raw_reads/short_reads/241155E_R1.fastq.gz \
 -I $WORK/genomics/0_raw_reads/short_reads/241155E_R2.fastq.gz \
 -R $WORK/genomics/1_short_reads_qc/2_cleaned_reads/fastp_report \
 -h $WORK/genomics/1_short_reads_qc/2_cleaned_reads/report.html \
 -o $WORK/genomics/1_short_reads_qc/2_cleaned_reads/241155E_R1_clean.fastq.gz \
 -O $WORK/genomics/1_short_reads_qc/2_cleaned_reads/241155E_R2_clean.fastq.gz -t 6 -q 25

jobinfo
```
</details>

### 2.1.3. Check the quality of the cleaned reads with fastqc again

```bash
# write the complete for loop and make a new folder for the cleaned reads quality report.
```

<details><summary><b>Finished commands</b></summary>

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=5:00:00
#SBATCH --job-name=01_fastqc
#SBATCH --output=01_fastqc.out
#SBATCH --error=01_fastqc.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
module load micromamba3/4.12.0
micromamba activate 01_short_reads_qc

## 1.1 fastqc raw reads
# mkdir -p $WORK/genomics/1_short_reads_qc/1_fastqc_raw
# for i in *.gz; do fastqc $i -o $WORK/genomics/1_short_reads_qc/1_fastqc_raw -t 32; done

## 1.2 fastp 
mkdir -p $WORK/genomics/1_short_reads_qc/2_cleaned_reads
fastp -i $WORK/genomics/0_raw_reads/short_reads/241155E_R1.fastq.gz \
 -I $WORK/genomics/0_raw_reads/short_reads/241155E_R2.fastq.gz \
 -R $WORK/genomics/1_short_reads_qc/2_cleaned_reads/fastp_report \
 -h $WORK/genomics/1_short_reads_qc/2_cleaned_reads/report.html \
 -o $WORK/genomics/1_short_reads_qc/2_cleaned_reads/241155E_R1_clean.fastq.gz \
 -O $WORK/genomics/1_short_reads_qc/2_cleaned_reads/241155E_R2_clean.fastq.gz -t 32 -q 25

## 1.3 fastqc cleaned
mkdir -p $WORK/genomics/1_short_reads_qc/3_fastqc_cleaned
for i in *.gz; do fastqc $i -o $WORK/genomics/1_short_reads_qc/3_fastqc_cleaned -t 12; done
micromamba deactivate
echo "---------short read cleaning completed successfully---------"
```
</details>

### Questions
  
* **How Good is the read quality?**
* **How many reads do you had before trimming and how many do you have now?**
* **Did the quality of the reads improve after trimming?**
 
> INSERT\
> YOUR\
> ANSWER\
> HERE


## 2.2. Long reads

### 2.2.1. NanoPlot

```bash
micromamba activate 02_long_reads_qc

cd $WORK/genomics/0_raw_reads/long_reads/
NanoPlot --fastq $file -o $output_dir -t 6 --maxlength 40000 --minlength 1000 --plots kde --format png --N50 --dpi 300 --store --raw --tsv_stats --info_in_report
```

### 2.2.2. Filtlong

```bash
filtlong --min_length 1000 --keep_percent 90 $file1 | gzip > sample1_cleaned_filtlong.fastq.gz
mv sample1_cleaned_filtlong.fastq.gz $output_dir
```

### 2.2.3. NanoPlot again

```bash
NanoPlot --fastq $input_dir/file1_cleaned_filtlong.fastq.gz -o $output_dir -t 6 --maxlength 40000 --minlength 1000 --plots kde --format png --N50 --dpi 300 --store --raw --tsv_stats --info_in_report
```

<details><summary><b>Finished commands</b></summary>

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=5:00:00
#SBATCH --job-name=02_long_reads_qc
#SBATCH --output=02_long_reads_qc.out
#SBATCH --error=02_long_reads_qc.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
module load micromamba3/4.12.0

echo "---------long reads cleaning started---------"
micromamba activate 02_long_reads_qc

## 2.1 Nanoplot raw
cd $WORK/genomics/0_raw_reads/long_reads/
mkdir -p $WORK/genomics/2_long_reads_qc/1_nanoplot_raw
NanoPlot --fastq $WORK/genomics/0_raw_reads/long_reads/*.gz \
 -o $WORK/genomics/2_long_reads_qc/1_nanoplot_raw -t 32 \
 --maxlength 40000 --minlength 1000 --plots kde --format png \
 --N50 --dpi 300 --store --raw --tsv_stats --info_in_report

## 2.2 Filtlong
mkdir -p $WORK/genomics/2_long_reads_qc/2_cleaned_reads
filtlong --min_length 1000 --keep_percent 90 $WORK/genomics/0_raw_reads/long_reads/*.gz | gzip > $WORK/genomics/2_long_reads_qc/2_cleaned_reads/241155E_cleaned_filtlong.fastq.gz

## 2.3 Nanoplot cleaned
cd $WORK/genomics/2_long_reads_qc/2_cleaned_reads
mkdir -p $WORK/genomics/2_long_reads_qc/3_nanoplot_cleaned
NanoPlot --fastq $WORK/genomics/2_long_reads_qc/2_cleaned_reads/*.gz \
 -o $WORK/genomics/2_long_reads_qc/3_nanoplot_cleaned -t 32 \
 --maxlength 40000 --minlength 1000 --plots kde --format png \
 --N50 --dpi 300 --store --raw --tsv_stats --info_in_report

micromamba deactivate
echo "---------long reads cleaning completed Successfully---------"

module purge
jobinfo
```
</details>

### Questions
  
* **How Good is the long reads quality?**
* **How many reads do you had before trimming and how many do you have now?**
 
> INSERT\
> YOUR\
> ANSWER\
> HERE

## 3. Assemble the genome using Uniycler

```bash
micromamba activate 03_unicycler
unicycler -1 $short_read1 -2 $short_read2 -l $long_reads -o $output_dir -t 32
```
<details><summary><b>Finished commands</b></summary>

```bash
# 3 Assembly (1 hour)-----------------------------------------------------------
echo "---------Unicycler Assembly pipeline started---------"
micromamba activate 03_unicycler
cd $WORK/genomics
mkdir -p $WORK/genomics/3_hybrid_assembly
unicycler -1 $WORK/genomics/1_short_reads_qc/2_cleaned_reads/241155E_R1_clean.fastq.gz -2 $WORK/genomics/1_short_reads_qc/2_cleaned_reads/241155E_R2_clean.fastq.gz -l $WORK/genomics/2_long_reads_qc/2_cleaned_reads/241155E_cleaned_filtlong.fastq.gz -o $WORK/genomics/3_hybrid_assembly/ -t 32
micromamba deactivate
echo "---------Unicycler Assembly pipeline Completed Successfully---------"
```
</details>

## 4. Check the assembly quality

### 4.1. Quast

- Copy the `.fasta` files of the assembly to the Quast directory
- Run Quast

```bash
micromamba activate 04_checkm_quast

quast.py assembly.fasta --circos -L --conserved-genes-finding --rna-finding\
     --glimmer --use-all-alignments --report-all-metrics -o $output_dir -t 16
```
<details><summary><b>Finished commands</b></summary>

```bash
# 4 Assembly quality-----------------------------------------------------------
echo "---------Assembly Quality Check Started---------"

## 4.1 Quast (5 minutes)
micromamba activate 04_checkm_quast
cd $WORK/genomics/3_hybrid_assembly
mkdir -p $WORK/genomics/3_hybrid_assembly/quast
quast.py $WORK/genomics/3_hybrid_assembly/assembly.fasta --circos -L --conserved-genes-finding --rna-finding \
 --glimmer --use-all-alignments --report-all-metrics -o $WORK/genomics/3_hybrid_assembly/quast -t 32
micromamba deactivate
```
</details>


### 4.2. CheckM

- Copy the `.fasta` files of the assembly to the CheckM directory
- Run CheckM


```bash
micromamba activate 04_checkm_quast
# Create the output directory if it does not exist
mkdir -p $checkm_out
# Run CheckM for this assembly
checkm lineage_wf $inputdir $output_dir -x fasta --tab_table --file $checkm_out/checkm_results -r -t 24
  
# Run CheckM QA for this assembly
checkm tree_qa ./$checkm_out
checkm qa ./$checkm_out/lineage.ms ./$checkm_out/ -o 1 > ./$checkm_out/Final_table_01.csv
checkm qa ./c$checkm_out/lineage.ms ./$checkm_out/ -o 2 > ./$checkm_out/final_table_checkm.csv
```

<details><summary><b>Finished commands</b></summary>

```bash
## 4.2 CheckM
micromamba activate 04_checkm_quast
cd $WORK/genomics/3_hybrid_assembly
mkdir -p $WORK/genomics/3_hybrid_assembly/checkm
checkm lineage_wf $WORK/genomics/3_hybrid_assembly/ $WORK/genomics/3_hybrid_assembly/checkm -x fasta --tab_table --file $WORK/genomics/3_hybrid_assembly/checkm/checkm_results -r -t 32
checkm tree_qa $WORK/genomics/3_hybrid_assembly/checkm
checkm qa $WORK/genomics/3_hybrid_assembly/checkm/lineage.ms $WORK/genomics/3_hybrid_assembly/checkm/ -o 1 > $WORK/genomics/3_hybrid_assembly/checkm/Final_table_01.csv
checkm qa $WORK/genomics/3_hybrid_assembly/checkm/lineage.ms $WORK/genomics/3_hybrid_assembly/checkm/ -o 2 > $WORK/genomics/3_hybrid_assembly/checkm/final_table_checkm.csv
micromamba deactivate
```
</details>

### 4.3. CheckM2

- Copy the `.fasta` files of the assembly to the CheckM2 directory
- Run CheckM2

```bash
micromamba activate 05_checkm2
checkm2 predict --threads 12 --input $path_to/*.fasta --output-directory $output_dir
```

<details><summary><b>Finished commands</b></summary>

```bash
# 4.3 Checkm2
# (can not work, maybe due to insufficient memory usage)
micromamba activate 05_checkm2
cd $WORK/genomics/3_hybrid_assembly
mkdir -p $WORK/genomics/3_hybrid_assembly/checkm2
checkm2 predict --threads 32 --input $WORK/genomics/3_hybrid_assembly/* --output-directory $WORK/genomics/3_hybrid_assembly/checkm2 
micromamba deactivate
echo "---------Assembly Quality Check Completed Successfully---------"
```
</details>

### 4.4. Bandage

- let's visualize the assembly using Bandage
- Install Bandage locally on your computer from [here](https://rrwick.github.io/Bandage/)
- Download the linux version and unzip it
> Open Bandage and load the assembly file `assembly.gfa` from the assembly directory `$WORK/genomics/3_hybrid_assembly/006_final_clean.gfa`

## 5. Annotate the Genomes with `Prokka`

- copy the `.fasta` files of the assembly to the Prokka directory
- Run Prokka to annotate the genome
- Prokka will create the output directory on its own, so dont create it before running it

```bash
micromamba activate 06_prokka
# Run Prokka on the file
prokka $input/assembly.fasta --outdir $output_dir --kingdom Bacteria --addgenes --cpus 32
```

<details><summary><b>Finished commands</b></summary>

```bash
# 5 Annotate-----------------------------------------------------------
echo "---------Prokka Genome Annotation Started---------"

micromamba activate 06_prokka
cd $WORK/genomics/3_hybrid_assembly
# Prokka creates the output dir on its own
prokka $WORK/genomics/3_hybrid_assembly/assembly.fasta --outdir $WORK/genomics/4_annotated_genome --kingdom Bacteria --addgenes --cpus 32
micromamba deactivate
echo "---------Prokka Genome Annotation Completed Successfully---------"
```
</details>

## 6. Classifiy the Genomes with `GTDBTK`

- copy the `.fna` files of the annotated genomes to the GTDBTK directory
- Run GTDBTK

```bash
micromamba activate 07_gtdbtk
#run gtdb
gtdbtk classify_wf --cpus 12 --genome_dir $input_fna_files --out_dir $output_dir --extension .fna 
#reduce cpu and increase the ram in bash script in order to have best performance
```

<details><summary><b>Finished commands</b></summary>

```bash
# 6 Classification-----------------------------------------------------------
echo "---------GTDB Classification Started---------"
# (can not work, maybe due to insufficient memory usage increase the ram in bash script)
micromamba activate 07_gtdbtk
conda env config vars set GTDBTK_DATA_PATH="$WORK/Databases/GTDBTK_day6";
micromamba activate 07_gtdbtk
cd $WORK/genomics/4_annotated_genome
mkdir -p $WORK/genomics/5_gtdb_classification
echo "---------GTDB Classification will run now---------"
gtdbtk classify_wf --cpus 12 --genome_dir $WORK/genomics/4_annotated_genome/ --out_dir $WORK/genomics/5_gtdb_classification --extension .fna 
# reduce cpu and increase the ram in bash script in order to have best performance
micromamba deactivate
echo "---------GTDB Classification Completed Successfully---------"
```
</details>

## 7. Run MultiQC

- multiqc will create the output directory on its own, so dont create it before running it
- Run MultiQC to combine all the QC reports at once at the end of the pipeline.

```bash
micromamba activate 01_short_reads_qc
# run multiqc
multiqc $input_dir -o $output_dir
```

<details><summary><b>Finished commands</b></summary>

```bash
micromamba activate 01_short_reads_qc
multiqc -d $WORK/genomics/ -o $WORK/genomics/6_multiqc
```
</details>

## Questions

- **How good is the quality of genome?**
- **Why did we use Hybrid assembler?**
- **What is the difference between short and long reads?**
- **Did we use Single or Paired end reads? Why?**
- **Write down about the classification of genome we have used here**

> INSERT\
> YOUR\
> ANSWER\
> HERE

----