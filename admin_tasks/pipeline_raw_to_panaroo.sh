#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=15:00:00
#SBATCH --job-name=pipeline_raw_to_panaroo
#SBATCH --output=pipeline_raw_to_panaroo.out
#SBATCH --error=pipeline_raw_to_panaroo.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load micromamba/1.4.2
export MAMBA_ROOT_PREFIX=$HOME/.micromamba
eval "$(micromamba shell hook --shell=bash)"

# 1 Short read cleaning-------------------------------------------------------
micromamba activate 01_short_reads_qc

## 1.1 fastqc raw
cd $WORK/genomics/0_raw_reads/short_reads/
mkdir -p ../../1_short_reads_qc/1_fastqc_raw
for i in *.gz; do fastqc $i -o ../../1_short_reads_qc/1_fastqc_raw; done

## 1.2 fastp 
mkdir -p ../../1_short_reads_qc/2_cleaned_reads
fastp -i 241155E_R1.fastq.gz -I 241155E_R2.fastq.gz -R fastp_report -h report.html -o ../../1_short_reads_qc/2_cleaned_reads/sample1_R1_clean.fastq.gz -O ../../1_short_reads_qc/2_cleaned_reads/sample1_R2_clean.fastq.gz -t 6 -q 25

## 1.3 fastqc cleaned
cd $WORK/genomics/1_short_reads_qc/2_cleaned_reads
mkdir -p ../3_fastqc_cleaned
for i in *.gz; do fastqc $i -o ../3_fastqc_cleaned; done

micromamba deactivate

# 2 Long read cleaning-----------------------------------------------------

micromamba activate 02_long_reads_qc

## 2.1 Nanoplot raw
cd $WORK/genomics/0_raw_reads/long_reads/
mkdir -p ../../2_long_reads_qc/1_nanoplot_raw
NanoPlot --fastq *.gz -o ../../2_long_reads_qc/1_nanoplot_raw -t 6 --maxlength 40000 --minlength 1000 --plots kde --format png --N50 --dpi 300 --store --raw --tsv_stats --info_in_report

## 2.2 Filtlong
mkdir -p ../../2_long_reads_qc/2_cleaned_reads
filtlong --min_length 1000 --keep_percent 90 *.gz | gzip > sample1_cleaned_filtlong.fastq.gz
mv sample1_cleaned_filtlong.fastq.gz ../../2_long_reads_qc/2_cleaned_reads/


## 2.3 Nanoplot cleaned
cd $WORK/genomics/2_long_reads_qc/2_cleaned_reads
mkdir -p ../3_nanoplot_cleaned
NanoPlot --fastq *.gz -o ../3_nanoplot_cleaned -t 6 --maxlength 40000 --minlength 1000 --plots kde --format png --N50 --dpi 300 --store --raw --tsv_stats --info_in_report

micromamba deactivate


# 3 Assembly-----------------------------------------------------------

micromamba activate 03_unicycler
cd $WORK/genomics
mkdir -p 3_hybrid_assembly
unicycler -1 ./1_short_reads_qc/2_cleaned_reads/sample1_R1_clean.fastq.gz -2 ./1_short_reads_qc/2_cleaned_reads/sample1_R2_clean.fastq.gz -l ./2_long_reads_qc/2_cleaned_reads/sample1_cleaned_filtlong.fastq.gz -o 3_hybrid_assembly/ -t 12
micromamba deactivate


# 4 Assembly quality-----------------------------------------------------------


## 4.1 Quast
micromamba activate 04_checkm_quast
cd $WORK/genomics/3_hybrid_assembly
mkdir -p quast
quast.py assembly.fasta --circos -L --conserved-genes-finding --rna-finding\
     --glimmer --use-all-alignments --report-all-metrics -o quast -t 16
micromamba deactivate


## 4.2 CheckM
micromamba activate 04_checkm_quast
cd $WORK/genomics/3_hybrid_assembly
mkdir -p checkm
checkm lineage_wf ./ ./checkm -x fasta --tab_table --file ./checkm/checkm_results -r -t 24
checkm tree_qa ./checkm
checkm qa ./checkm/lineage.ms ./checkm/ -o 1 > ./checkm/Final_table_01.csv
checkm qa ./checkm/lineage.ms ./checkm/ -o 2 > ./checkm/final_table_checkm.csv
micromamba deactivate


# 4.3 Checkm2
# (can not work, maybe due to insufficient memory usage)
micromamba activate 05_checkm2
cd $WORK/genomics/3_hybrid_assembly
mkdir -p checkm2
checkm2 predict --threads 12 --input ./* --output-directory ./checkm2 
micromamba deactivate

# 5 Annotate-----------------------------------------------------------

micromamba activate 06_prokka
cd $WORK/genomics/3_hybrid_assembly
# Prokka creates the output dir on its own
prokka assembly.fasta --outdir ../4_annotated_genome --kingdom Bacteria --addgenes --cpus 12
micromamba deactivate

# 6 Classification-----------------------------------------------------------

# (can not work, maybe due to insufficient memory usage increase the ram in bash script)
micromamba activate 07_gtdb
cd $WORK/genomics/4_annotated_genome
mkdir -p ../5_gtdb_classification
gtdbtk classify_wf --cpus 12 --genome_dir ./ --out_dir ../5_gtdb_classification --extension .fna 
# reduce cpu and increase the ram in bash script in order to have best performance
micromamba deactivate

# 7 panaroo pangenomics-----------------------------------------------------------
# Only working with multiple samples
micromamba activate 08_panaroo
mkdir -p $WORK/genomics/6_panaroo
cd $WORK/genomics/6_panaroo
cp ../4_annotated_genome/*.gff .
panaroo -i *.gff -o ./ --clean-mode strict -t 12 --remove-invalid-genes
micromamba deactivate
