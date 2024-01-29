#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=15:00:00
#SBATCH --job-name=pipeline_genome_assembly
#SBATCH --output=pipeline_genome_assembly.out
#SBATCH --error=pipeline_genome_assembly.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0 #for GTDB-tk database path
module load micromamba/1.4.2
export MAMBA_ROOT_PREFIX=$HOME/.micromamba
eval "$(micromamba shell hook --shell=bash)"

# 1 Short read cleaning-------------------------------------------------------

echo "---------short read cleaning started---------"
micromamba activate 01_short_reads_qc

## 1.1 fastqc raw
cd $WORK/genomics/0_raw_reads/short_reads/
mkdir -p $WORK/genomics/1_short_reads_qc/1_fastqc_raw
for i in *.gz; do fastqc $i -o $WORK/genomics/1_short_reads_qc/1_fastqc_raw -t 32; done

## 1.2 fastp 
mkdir -p $WORK/genomics/1_short_reads_qc/2_cleaned_reads
fastp -i $WORK/genomics/0_raw_reads/short_reads/241155E_R1.fastq.gz \
 -I $WORK/genomics/0_raw_reads/short_reads/241155E_R2.fastq.gz \
 -R $WORK/genomics/1_short_reads_qc/2_cleaned_reads/fastp_report \
 -h $WORK/genomics/1_short_reads_qc/2_cleaned_reads/report.html \
 -o $WORK/genomics/1_short_reads_qc/2_cleaned_reads/241155E_R1_clean.fastq.gz \
 -O $WORK/genomics/1_short_reads_qc/2_cleaned_reads/241155E_R2_clean.fastq.gz -t 32 -q 25

## 1.3 fastqc cleaned
cd $WORK/genomics/1_short_reads_qc/2_cleaned_reads
mkdir -p $WORK/genomics/1_short_reads_qc/3_fastqc_cleaned
for i in *.gz; do fastqc $i -o $WORK/genomics/1_short_reads_qc/3_fastqc_cleaned -t 12; done
micromamba deactivate
echo "---------short read cleaning completed successfully---------"

# 2 Long read cleaning-----------------------------------------------------
echo "---------long reads cleaning started---------"
micromamba activate 02_long_reads_qc

## 2.1 Nanoplot raw
cd $WORK/genomics/0_raw_reads/long_reads/
mkdir -p $WORK/genomics/2_long_reads_qc/1_nanoplot_raw
NanoPlot --fastq $WORK/genomics/0_raw_reads/long_reads/*.gz \
 -o $WORK/genomics/2_long_reads_qc/1_nanoplot_raw -t 12 \
 --maxlength 40000 --minlength 1000 --plots kde --format png \
 --N50 --dpi 300 --store --raw --tsv_stats --info_in_report

## 2.2 Filtlong
mkdir -p $WORK/genomics/2_long_reads_qc/2_cleaned_reads
filtlong --min_length 1000 --keep_percent 90 $WORK/genomics/0_raw_reads/long_reads/*.gz | gzip > $WORK/genomics/2_long_reads_qc/2_cleaned_reads/241155E_cleaned_filtlong.fastq.gz

## 2.3 Nanoplot cleaned
cd $WORK/genomics/2_long_reads_qc/2_cleaned_reads
mkdir -p $WORK/genomics/2_long_reads_qc/3_nanoplot_cleaned
NanoPlot --fastq $WORK/genomics/2_long_reads_qc/2_cleaned_reads/*.gz \
 -o $WORK/genomics/2_long_reads_qc/3_nanoplot_cleaned -t 12 \
 --maxlength 40000 --minlength 1000 --plots kde --format png \
 --N50 --dpi 300 --store --raw --tsv_stats --info_in_report

micromamba deactivate
echo "---------long reads cleaning completed Successfully---------"

# 3 Assembly (1 hour)-----------------------------------------------------------
echo "---------Unicycler Assembly pipeline started---------"
micromamba activate 03_unicycler
cd $WORK/genomics
mkdir -p $WORK/genomics/3_hybrid_assembly
unicycler -1 $WORK/genomics/1_short_reads_qc/2_cleaned_reads/241155E_R1_clean.fastq.gz -2 $WORK/genomics/1_short_reads_qc/2_cleaned_reads/241155E_R2_clean.fastq.gz -l $WORK/genomics/2_long_reads_qc/2_cleaned_reads/241155E_cleaned_filtlong.fastq.gz -o $WORK/genomics/3_hybrid_assembly/ -t 32
micromamba deactivate
echo "---------Unicycler Assembly pipeline Completed Successfully---------"

# 4 Assembly quality-----------------------------------------------------------
echo "---------Assembly Quality Check Started---------"

## 4.1 Quast (5 minutes)
micromamba activate 04_checkm_quast
cd $WORK/genomics/3_hybrid_assembly
mkdir -p $WORK/genomics/3_hybrid_assembly/quast
quast.py $WORK/genomics/3_hybrid_assembly/assembly.fasta --circos -L --conserved-genes-finding --rna-finding \
 --glimmer --use-all-alignments --report-all-metrics -o $WORK/genomics/3_hybrid_assembly/quast -t 32
micromamba deactivate

## 4.2 CheckM
micromamba activate 04_checkm_quast
cd $WORK/genomics/3_hybrid_assembly
mkdir -p $WORK/genomics/3_hybrid_assembly/checkm
checkm lineage_wf $WORK/genomics/3_hybrid_assembly/ $WORK/genomics/3_hybrid_assembly/checkm -x fasta --tab_table --file $WORK/genomics/3_hybrid_assembly/checkm/checkm_results -r -t 32
checkm tree_qa $WORK/genomics/3_hybrid_assembly/checkm
checkm qa $WORK/genomics/3_hybrid_assembly/checkm/lineage.ms $WORK/genomics/3_hybrid_assembly/checkm/ -o 1 > $WORK/genomics/3_hybrid_assembly/checkm/Final_table_01.csv
checkm qa $WORK/genomics/3_hybrid_assembly/checkm/lineage.ms $WORK/genomics/3_hybrid_assembly/checkm/ -o 2 > $WORK/genomics/3_hybrid_assembly/checkm/final_table_checkm.csv
micromamba deactivate

# 4.3 Checkm2
# (can not work, maybe due to insufficient memory usage)
micromamba activate 05_checkm2
cd $WORK/genomics/3_hybrid_assembly
mkdir -p $WORK/genomics/3_hybrid_assembly/checkm2
checkm2 predict --threads 32 --input $WORK/genomics/3_hybrid_assembly/* --output-directory $WORK/genomics/3_hybrid_assembly/checkm2 
micromamba deactivate
echo "---------Assembly Quality Check Completed Successfully---------"

# 5 Annotate-----------------------------------------------------------
echo "---------Prokka Genome Annotation Started---------"

micromamba activate 06_prokka
cd $WORK/genomics/3_hybrid_assembly
# Prokka creates the output dir on its own
prokka $WORK/genomics/3_hybrid_assembly/assembly.fasta --outdir $WORK/genomics/4_annotated_genome --kingdom Bacteria --addgenes --cpus 32
micromamba deactivate
echo "---------Prokka Genome Annotation Completed Successfully---------"


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

# 7 multiqc-----------------------------------------------------------
echo "---------Multiqc Started---------"
micromamba activate 01_short_reads_qc
multiqc -d $WORK/genomics/ -o $WORK/genomics/6_multiqc
micromamba deactivate
echo "---------Multiqc Completed Successfully---------"


module purge
jobinfo


