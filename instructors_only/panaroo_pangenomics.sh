#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=15:00:00
#SBATCH --job-name=panaroo
#SBATCH --output=panaroo.out
#SBATCH --error=panaroo.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load micromamba/1.4.2
export MAMBA_ROOT_PREFIX=$HOME/.micromamba
eval "$(micromamba shell hook --shell=bash)"
module load micromamba/1.4.2
micromamba activate 08_panaroo
#creata a folder for panaroo
mkdir -p $WORK/pangenomics/01_panaroo
# go to that folder
cd $WORK/pangenomics/01_panaroo/
# run panaroo
panaroo -i $WORK/pangenomics/gffs/*.gff -o $WORK/pangenomics/01_panaroo/pangenomics_results --clean-mode strict -t 12

# approximately 30 minutes
micromamba deactivate
module purge
jobinfo
