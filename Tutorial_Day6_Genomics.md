# Genomics

## 1. Your data
``` 
cd $WORK/sunam###/genomics
``` 

$\color{#58A6FF}\textsf{\Large\&#x24D8;\kern{0.2cm}\normalsize Note}$
Do not forget to activate the conda environment

``` 
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate 01_short_reads_qc
``` 

## 2. Quality Control

### 2.1. Short reads

#### 2.1.1. Run fastqc

You need to create a job script to run `fastqc` and submit the job.

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --time=5:00:00
#SBATCH --job-name=01_fastqc
#SBATCH --output=01_fastqc.out
#SBATCH --error=01_fastqc.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate 01_short_reads_qc

cd $WORK/sunam###/genomics/0_raw_reads/short_reads/
for i in *.gz; do fastqc $i -o output_folder/; done

jobinfo
```
#### 2.1.2. Run `fastp` 

> Add `fastp` command and rerun the job script by commenting our the fastqc command, as shown on [Day-2](./Tutorial_Day2.md).

<details><summary><b>Finished commands</b></summary>

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --time=5:00:00
#SBATCH --job-name=01_fastqc
#SBATCH --output=01_fastqc.out
#SBATCH --error=01_fastqc.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate 01_short_reads_qc

cd $WORK/sunam###/genomics/0_raw_reads/short_reads/
# for i in *.gz; do fastqc $i -o output_folder/; done

fastp -i sample1_R1.fastq.gz -I sample1_R2.fastq.gz -R fastp_report -h report.html -o sample1_R1_clean.fastq.gz -O sample1_R2_clean.fastq.gz -t 6 -q 25
# do the same for all reads
jobinfo
```
</details>

### 2.1.3. Check the quality again

```bash
# write the complete for loop and make a new folder for the cleaned reads quality report.
```

<details><summary><b>Finished commands</b></summary>

```bash
# run fastqc again but only on clean reads
for i in *_clean.fastq.gz; do fastqc $i -o cleaned_output_folder/; done
```
</details>

### Questions
  
* **How Good is the read quality?**
* **How many reads do you had before trimming and how many do you have now?**
 
> INSERT\
> YOUR\
> ANSWER\
> HERE


## 2.2. Long reads

### 2.2.1. NanoPlot

```bash
conda activate 02_long_reads_qc

NanoPlot --fastq $file -o $nanoplots_before/ -t 6 --maxlength 40000 --minlength 1000 --plots kde --format png --N50 --dpi 300 --store --raw --tsv_stats --info_in_report
```

### 2.2.2. Filtlong

```bash
filtlong --min_length 1000 --keep_percent 90 $file1 | gzip > $file1_cleaned_filtlong.fastq.gz
```

### 2.2.3. NanoPlot again

```bash
NanoPlot --fastq $file1_cleaned_filtlong.fastq.gz -o $nanoplots_after/ -t 6 --maxlength 40000 --minlength 1000 --plots kde --format png --N50 --dpi 300 --store --raw --tsv_stats --info_in_report
```

### Questions
  
* **How Good is the long reads quality?**
* **How many reads do you had before trimming and how many do you have now?**
 
> INSERT\
> YOUR\
> ANSWER\
> HERE

## 3. Assemble the genome using Uniycler

```bash
conda activate 03_unicycler
unicycler -1 $file1 -2 $file2 -l $long_reads -o $hybrid_assembly/genome1 -t 12
```

## 4. Check the assembly quality

### 4.1. Quast

- Copy the `.fasta` files of the assembly to the Quast directory
- Run Quast

```bash
conda activate 04_checkm_quast

quast.py assembly.fasta --circos -L --conserved-genes-finding --rna-finding\
     --glimmer --use-all-alignments --report-all-metrics -o $output_dir -t 16
```

### 4.2. CheckM

- Copy the `.fasta` files of the assembly to the CheckM directory
- Run CheckM


```bash
conda activate 04_checkm_quast
# Create the output directory if it does not exist
mkdir -p $output_dir
  
# Run CheckM for this assembly
checkm lineage_wf ${dir} ${output_dir} -x fasta --tab_table --file ${base_name} -r -t 24
  
# Run CheckM QA for this assembly
checkm qa ${checkm_dir}lineage.ms ${checkm_dir} -o 1 > ${checkm_dir}Final_table_01.csv
checkm qa ${checkm_dir}lineage.ms ${checkm_dir} -o 2 > ${checkm_dir}Final_table_02.csv
checkm tree_qa ${checkm_dir} -o 1 -f ${checkm_dir}tree_01.tsv 
checkm tree_qa ${checkm_dir} -o 2 -f ${checkm_dir}tree_02.tsv
checkm tree_qa ${checkm_dir} -o 3 -f ${checkm_dir}tree_03.tsv  
checkm tree_qa ${checkm_dir} -o 4 -f ${checkm_dir}tree_04.tsv
checkm tree_qa ${checkm_dir} -o 5 -f ${checkm_dir}tree_05.tsv
```

### 4.3. CheckM2

- Copy the `.fasta` files of the assembly to the CheckM2 directory
- Run CheckM2

```bash
conda activate 05_checkm2
checkm2 predict --threads 12 --input ./genome_assemblies/* --output-directory ./checkm2_resuls
```

## 5. Annotate the Genomes with `Prokka`

- copy the `.fasta` files of the assembly to the Prokka directory
- Run Prokka to annotate the genome

```bash
conda activate 06_prokka
# Run Prokka on the file
prokka assembly.fasta --outdir $output_dir --kingdom Bacteria --addgenes --cpus 12
```

## 6. Classifiy the Genomes with `GTDBTK`

- copy the `.fna` files of the annotated genomes to the GTDBTK directory
- Run GTDBTK

```bash
conda activate 07_gtdbtk-2.1.1 
#run gtdb
gtdbtk classify_wf --cpus 12 --genome_dir ./folder/fna_files/ --out_dir ./gtdb_output/ --extension .fna 
#reduce cpu and increase the ram in bash script in order to have best performance
```

## 7. RUN Panaroo for pangenomics

- copy the all `.gff` files of the annotated genomes to the Panaroo directory
- Run Panaroo

```bash
conda activate 08_panaroo
panaroo -i ./10_panaroo/gffs/*.gff -o ./10_panaroo/results/ --clean-mode strict -t 12
```
# Questions

- **Which one of the genome looks like the most complete and clean?**
- **Which of the genomes have the most similar genes with each other?**
- **Explain the results of this section and add figures.**


---