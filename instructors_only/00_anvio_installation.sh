#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=32G
#SBATCH --time=5:00:00
#SBATCH --job-name=anvio_installation
#SBATCH --output=anvio_installation.out
#SBATCH --error=anvio_installation.err
#SBATCH --partition=base

#set proxy environment
export http_proxy=http://relay:3128
export https_proxy=http://relay:3128
export ftp_proxy=http://relay:3128

module load micromamba/1.4.2
micromamba activate
export MAMBA_ROOT_PREFIX=$HOME/.micromamba
eval "$(micromamba shell hook --shell=bash)"
module load micromamba/1.4.2

micromamba create -y --name anvio-8 python=3.10
micromamba activate anvio-8
micromamba install -y -c conda-forge -c bioconda python=3.10 \
        sqlite prodigal idba mcl muscle=3.8.1551 famsa hmmer diamond \
        blast megahit spades bowtie2 bwa graphviz "samtools>=1.9" \
        trimal iqtree trnascan-se fasttree vmatch r-base r-tidyverse \
        r-optparse r-stringi r-magrittr bioconductor-qvalue meme ghostscript

# try this, if it doesn't install, don't worry (it is sad, but OK):
micromamba install -y -c bioconda fastani

cd $HOME
curl -L https://github.com/merenlab/anvio/releases/download/v8/anvio-8.tar.gz \
        --output anvio-8.tar.gz
pip install anvio-8.tar.gz
anvi-setup-scg-taxonomy
anvi-setup-ncbi-cogs
anvi-setup-kegg-data
# setup a place to download CONCOCT source code
mkdir -p ~/github/ && cd ~/github/

# get a clone of the CONCOCT codebase from the fork
# that is tailored for the anvi'o conda environment
git clone https://github.com/merenlab/CONCOCT.git

# build and install
cd CONCOCT
micromamba install anaconda::cython -y 
python setup.py build
python setup.py install

micromamba deactivate
module purge
jobinfo

