### 
$${\color{red}DAY 7b}$$
### 

# Pangenomics - comparing genomes using [Anvio](https://anvio.org/)

- [Pangenomics - comparing genomes using Anvio](#pangenomics---comparing-genomes-using-anvio)
  - [Aim](#aim)
  - [1. Load the required modules](#1-load-the-required-modules)
  - [2. Download the data](#2-download-the-data)
  - [3. Create `contigs.dbs` from `.fasta` files](#3-create-contigsdbs-from-fasta-files)
  - [4. Visualize `contigs.db`](#4-visualize-contigsdb)
  - [5. Create external genomes file](#5-create-external-genomes-file)
  - [6. Investigate contamination](#6-investigate-contamination)
  - [7. Visualise contigs for refinement](#7-visualise-contigs-for-refinement)
  - [8. Splitting the genome in our good bins](#8-splitting-the-genome-in-our-good-bins)
  - [9. Estimate completeness of split vs. unsplit genome:](#9-estimate-completeness-of-split-vs-unsplit-genome)
  - [10. Compute pangenome](#10-compute-pangenome)
  - [11. Display the pangenome](#11-display-the-pangenome)
 

## Aim
In this tutorial we will compare the genomes of 52 *Vibrio jasicida* strains using Anvio. We will create a pangenome and visualize it. We will also look at the completeness of the genomes and the contamination of the genomes. 

This tutorial follows the workflow of the [anvi'o miniworkshop](https://merenlab.org/tutorials/vibrio-jasicida-pangenome/) and the [pangenomics workflow](https://merenlab.org/2016/11/08/pangenomics-v2/).

> **`Note:`** There are some intentional typos, please have a look when you are typing your code.

**Programs used:**

| Program or Database                                          | Function                                                     |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [anvi'o](https://anvio.org/)                                 | Wrapper for genome comparissons                              |
| [DIAMOND](https://www.wsi.uni-tuebingen.de/lehrstuehle/algorithms-in-bioinformatics/software/diamond/) | creates high-throughput protein alignments                   |
| [pyANI](https://github.com/widdowquinn/pyani)                | calculates genome similarities based on average nucleotide identity |
| [KEGG](https://www.kegg.jp/)                                 | Kyoto Encyclopaedia of Genes and Genomes (Database)          |
| [NCBI COG](https://www.ncbi.nlm.nih.gov/research/cog)        | Clusters of Orthologous Genes (Database)                     |

## 1. Load the required modules

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=5:00:00
#SBATCH --job-name=anvio_pangenomics
#SBATCH --output=anvio_pangenomics.out
#SBATCH --error=anvio_pangenomics.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8

# create new folder
mkdir $WORK/pangenomics/02_anvio_pangenomics
```

## 2. Download the data

```bash
curl -L https://ndownloader.figshare.com/files/28965090 -o V_jascida_genomes.tar.gz
tar -zxvf V_jascida_genomes.tar.gz
ls V_jascida_genomes
```

## 3. Create `contigs.dbs` from `.fasta` files

```bash
cd $WORK/pangenomics_test/V_jascida_genomes/

ls *fasta | awk 'BEGIN{FS="_"}{print $1}' > genomes.txt

# remove all contigs <2500 nt
for g in `cat genomes.txt`
do
    echo
    echo "Working on $g ..."
    echo
    anvi-script-reformat-fasta ${g}_scaffolds.fasta \
                               --min-len 2500 \
                               --simplify-names \
                               -o ${g}_scaffolds_2.5K.fasta
done

# generate contigs.db
for g in `cat genomes.txt`
do
    echo
    echo "Working on $g ..."
    echo
    anvi-gen-contigs-database -f ${g}_scaffolds_2.5K.fasta \
                              -o V_jascida_${g}.db \
                              --num-threads 4 \
                              -n V_jascida_${g}
done

# annotate contigs.db
for g in *.db
do
    anvi-run-hmms -c $g --num-threads 4
    anvi-run-ncbi-cogs -c $g --num-threads 4
    anvi-scan-trnas -c $g --num-threads 4
    anvi-run-scg-taxyonomy -c $g --num-threads 4
done
``` 

## 4. Visualize `contigs.db`

- Open the terminal and write these commands:
```bash
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8

anvi-display-contigs-stats /path/to.your/databases/*db
```



```bash
srun --reservation=biol217 --pty --mem=16G --nodes=1 --tasks-per-node=1 --cpus-per-task=1 --partition=base /bin/bash

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8_biol217
anvi-display-contigs-stats /path/to.your/databases/*db
```

> **In a new terminal (update the node `n100` to actually used one)**

```bash
ssh -L 8060:localhost:8080 sunam###@caucluster.rz.uni-kiel.de

ssh -L 8080:localhost:8080 n100
```

click: http://127.0.0.1:8060/

Afterwards exit the node pressing `Ctrl + D` twice.


## 5. Create external genomes file

```bash
anvi-script-gen-genomes-file --input-dir /path/to/input/dir \
                             -o external-genomes.txt
```

## 6. Investigate contamination

* Directly in the terminal
* To see if all look similar


```bash
cd V_jascida_genomes
anvi-estimate-genome-completeness -e external-genomes.txt
```

## 7. Visualise contigs for refinement

```bash
anvi-profile -c V_jascida_52.db \
             --sample-name V_jascida_52 \
             --output-dir V_jascida_52 \
             --blank
```

Now to display run this command directly in the terminal
* create bin V_jascida_52_CLEAN and store it as default


```bash
srun --pty --mem=10G --nodes=1 --tasks-per-node=1 --cpus-per-task=1 --partition=base /bin/bash

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8_biol217

anvi-interactive -c V_jascida_52.db \
                 -p V_jascida_52/PROFILE.db
```


In a new terminal (update the node "n100" to actually used one)

```bash
ssh -L 8060:localhost:8080 sunam226@caucluster.rz.uni-kiel.de

ssh -L 8080:localhost:8080 n100
```
click: http://127.0.0.1:8060/

## 8. Splitting the genome in our good bins

```bash
anvi-split -p V_jascida_52/PROFILE.db \
           -c V_jascida_52.db \
           -C default \
           -o V_jascida_52_SPLIT

# Here are the files you created
#V_jascida_52_SPLIT/V_jascida_52_CLEAN/CONTIGS.db

sed 's/V_jascida_52.db/V_jascida_52_SPLIT\/V_jascida_52_CLEAN\/CONTIGS.db/g' external-genomes.txt > external-genomes-final.txt
```
## 9. Estimate completeness of split vs. unsplit genome:

```bash
anvi-estimate-genome-completeness -e external-genomes.txt
anvi-estimate-genome-completeness -e external-genomes-final.txt
```
## 10. Compute pangenome

```bash
anvi-gen-genomes-storage -e external-genomes-final.txt \
                         -o V_jascida-GENOMES.db

anvi-pan-genome -g V_jascida-GENOMES.db \
                --project-name V_jascida \
                --num-threads 4                         
```
## 11. Display the pangenome

```bash
srun --pty --mem=10G --nodes=1 --tasks-per-node=1 --cpus-per-task=1 --partition=base /bin/bash

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8_biol217

anvi-display-pan -p V_jascida/V_jascida-PAN.db \
                 -g V_jascida-GENOMES.db
```

In a new terminal (update the node "n100" to actually used one)

```bash
ssh -L 8060:localhost:8080 sunam226@caucluster.rz.uni-kiel.de

ssh -L 8080:localhost:8080 n100

click: http://127.0.0.1:8060/
```
