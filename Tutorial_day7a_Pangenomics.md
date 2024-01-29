# 
$${\color{red}DAY 7a}$$
# 

# Pangenomics - comparing genomes with [PANAROO](https://gtonkinhill.github.io/panaroo/#/)

`AIMs:`

- To compare the genomes of the more than 2 strains of the same big group of bacteria
- Identify the core and accessory genes.
  - Core genes are the genes that are present in all the strains of the same group of bacteria
  - Accessory genes are the genes that are present in some strains of the same group of bacteria

**`Pan-genome is the union of core and accessory genes`**

This is a complete tutorial on how to run Panaroo on a set of genomes.


## Input data

- We need `.gff` files of the annotated genomes which were output of the `prokka` annotation pipeline.

```bash
cd $WORK/pangenomics
```

## RUN Panaroo for pangenomics


```bash
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
# run panaroo
panaroo -i $WORK/pangenomics/gffs/*.gff -o $WORK/pangenomics/01_panaroo/pangenomics_results --clean-mode strict -t 12


micromamba deactivate
module purge
jobinfo

```

# Questions

- **Which one of the genome looks like the most complete and clean?**
- **Which of the genomes have the most similar genes with each other?**
- **Explain the results of this section and add figures.**
