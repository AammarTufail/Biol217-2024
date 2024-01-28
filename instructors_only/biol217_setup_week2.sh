#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=0-15:00:00
#SBATCH --job-name=biol217_setup_week2
#SBATCH --output=biol217_setup_week2.out
#SBATCH --error=biol217_setup_week2.err
#SBATCH --partition=base

#load modules
module load gcc12-env/12.1.0
module load miniconda3/4.12.0 #for GTDB-tk database path
module load micromamba/1.4.2
export MAMBA_ROOT_PREFIX=$HOME/.micromamba
eval "$(micromamba shell hook --shell=bash)"
micromamba shell init --shell=bash --prefix=~/.micromamba

#set proxy environment
export http_proxy=http://relay:3128
export https_proxy=http://relay:3128
export ftp_proxy=http://relay:3128

# ##-------------------------------Installations----------------------------
#1- short reads qc
micromamba create -n 01_short_reads_qc -y
micromamba activate 01_short_reads_qc
micromamba install bioconda::fastqc -y
micromamba install bioconda::fastp -y
micromamba install bioconda::multiqc -y
micromamba deactivate

#2- long reads qc
micromamba create -n 02_long_reads_qc -y
micromamba activate 02_long_reads_qc
micromamba install bioconda::nanoplot -y
micromamba install bioconda::filtlong -y
pip install seaborn
pip install matplotlib
micromamba install -c bioconda pycoqc -y
micromamba deactivate

#3- Unicycler
micromamba create -n 03_unicycler -y
micromamba activate 03_unicycler
micromamba install -c bioconda unicycler -y
micromamba install -c conda-forge gcc -y
micromamba install -c conda-forge clang -y
micromamba install -c intel icc_rt -y
micromamba install -c conda-forge setuptools -y
micromamba install -c bioconda spades -y
micromamba install -c bioconda racon -y
micromamba install -c bioconda blast -y
micromamba install -c bioconda bandage -y
micromamba deactivate

#4- checkm and quast
micromamba create -n 04_checkm_quast -y
micromamba activate 04_checkm_quast
micromamba install python=3.9 -y
micromamba install -c bioconda numpy matplotlib pysam -y
micromamba install -c bioconda hmmer prodigal pplacer -y
micromamba install -c bioconda checkm-genome -y
#mkdir -p $WORK/Databases/checkm
#cd $WORK/Databases/checkm
#wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
#tar xvzf checkm_data_2015_01_16.tar.gz
export CHECKM_DATA_PATH=$WORK/Databases/checkm/
micromamba install -c bioconda quast -y
micromamba deactivate

#5 checkM2
cd $WORK/genomics/
# copy checkm2.yml file to the working directory
wget https://github.com/chklovski/CheckM2/blob/main/checkm2.yml
micromamba create -n 05_checkm2 -f checkm2.yml -y
micromamba activate 05_checkm2
rm -f checkm2.yml
pip install CheckM2
echo "-------------------done installing----------------------"
mkdir -p $WORK/Databases/checkm2/
checkm2 database --download --path $WORK/Databases/checkm2/
echo "----------------------done downloading the database----------------------"
checkm2 testrun -t 16
echo "----------------------Test Run Completed----------------------"

#6- prokka
micromamba create -n 06_prokka -y
micromamba activate 06_prokka
micromamba install -c bioconda prokka -y
micromamba deactivate

#7- GTDBtk with conda
micromamba create -n 07_gtdbtk -c conda-forge -c bioconda gtdbtk=2.1.1 -y
micromamba activate 07_gtdbtk
micromamba install numpy=1.23.1 -y
#download databases
#mkdir $WORK/Databases/GTDBTK_day6
#cd $WORK/Databases/GTDBTK_day6/
#wget https://data.gtdb.ecogenomic.org/releases/latest/auxillary_files/gtdbtk_data.tar.gz # eta 12h
#tar xvzf gtdbtk_data.tar.gz
conda env config vars set GTDBTK_DATA_PATH="$WORK/Databases/GTDBTK_day6";
micromamba deactivate

#8- panaroo
micromamba create -n 08_panaroo python=3.9 -y
micromamba activate 08_panaroo
micromamba install -c conda-forge -c bioconda -c defaults 'panaroo>=1.3' -y
micromamba install -c bioconda biopython=1.68 -y #remember to roll down the version to 1.68
micromamba install -c anaconda numpy -y
micromamba install -c anaconda networkx -y
micromamba install -c bioconda gffutils -y
micromamba install -c bioconda edlib -y
micromamba install -c anaconda joblib -y
micromamba install -c conda-forge tqdm -y
micromamba install -c bioconda cd-hit -y
#optional packages 
micromamba install -c bioconda prokka -y
micromamba install -c bioconda prank -y
micromamba install -c bioconda mafft -y
micromamba install -c bioconda clustalw -y
micromamba install -c bioconda mash -y
micromamba deactivate

#9- ANVIO  (already use the one cynthia installed and please confirm if pangenomics is working fine on it? by using the data we get from genome assembly)




#10- grabseqs for RNAseq data
micromamba create -n 10_grabseqs -y
micromamba activate 10_grabseqs
micromamba install bioconda::sra-tools -y
micromamba install conda-forge::pigz -y
micromamba install grabseqs -c louiejtaylor -c bioconda -c conda-forge -y
# grabseqs sra SRP441176 -l #if it does not work or give errors
#replacing /usr/local/lib/python3.6/site-packages/grabseqslib/sra.py line 94 with (without hashtag)
# metadata = requests.get("https://trace.ncbi.nlm.nih.gov/Traces/sra-db-be/sra-db-be.cgi?rettype=runinfo&term="+pacc)
#retry
# grabseqs sra SRP441176 -l
  # --> Did not work: had to replace the line
  # --> Path is: "/zfshome/sunam226/.micromamba/envs/10_grabseqs/lib/python3.7/site-packages/grabseqslib/sra.py"
micromamba deactivate 

# ##-------------------------------close everything & jobinfo----------------------------
micromamba deactivate
module purge
jobinfo

