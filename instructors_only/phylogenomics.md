# Phylogenomics

## 1. Load the required modules

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=5:00:00
#SBATCH --job-name=anvio_phylogenomics
#SBATCH --output=anvio_phylogenomics.out
#SBATCH --error=anvio_phylogenomics.err
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
# download the data pack
cd $WORK/pangenomics/02_anvio_pangenomics
wget https://ndownloader.figshare.com/files/28715136 -O AnvioPhylogenomicsTutorialDataPack.tar.gz
# unpack it
tar -zxvf AnvioPhylogenomicsTutorialDataPack.tar.gz
rm -rf AnvioPhylogenomicsTutorialDataPack.tar.gz
# renmae the folder
mv AnvioPhylogenomicsTutorialDataPack genomes
# take a peak
ls genomes
```

## 3. Create `contigs.dbs` from `.fasta` files

```bash
cd $WORK/pangenomics/02_anvio_pangenomics/genomes/distantly-related
# generate contigs.db
for i in `ls *fa | awk 'BEGIN{FS=".fa"}{print $1}'`
do
    anvi-gen-contigs-database -f $i.fa -o $i.db -T 12
    anvi-run-hmms -c $i.db
done
```
> At the end of this, for each FASTA file I should have a file with the same name that ends with ‘.db’. These are the contigs databases that Anvi’o uses to store information about the contigs in each genome.

## 4. Naming `contigs`

> The next step is to define all the contigs databases of interest, and give them a name to introduce them to anvi’o. Let’s call this file ‘external-genomes.txt’:


```bash
# download the already created file
wget https://goo.gl/XuezQF -O external-genomes.txt
```

## 5. Single copy core gene profile

> We need to identify an HMM profile to use, and then select some gene names from this profile to play with. Anvi’o has multiple HMM profiles for single-copy core genes by default, and you can always use the program anvi-db-info to learn which HMM sources you have in a given contigs database.

```bash
anvi-db-info Salmonella_enterica_21170.db
```
> Read the output.
> For the remainder of this tutorial we will use the collection called `Bacteria_71`, which is the default bacterial single-copy core gene collection anvi’o (which also includes ribosomal proteins that are good for archaea as well). 

OK, so we will use Bacteria_71 as a source of single-copy core genes, but which genes exactly should we pick from it? Let’s take a look and see which genes are described in this collection:

```bash
anvi-get-sequences-for-hmm-hits --external-genomes external-genomes.txt \
                                --hmm-source Bacteria_71 \
                                --list-available-gene-names
```

> Read the output.
> You can select any combination of these genes to use for your phylogenomic analysis, including all of them –if you do not declare a `--gene-names` parameter, the program would use all. But considering the fact that ribosomal proteins are often used for phylogenomic analyses, let’s say we decided to use the following ribosomal proteins: `Ribosomal_L1`, `Ribosomal_L2`, `Ribosomal_L3`, `Ribosomal_L4`, `Ribosomal_L5`, and `Ribosomal_L6`.

> **`The following command will give you the concatenated amino acid sequences for these genes:`**

```bash
anvi-get-sequences-for-hmm-hits --external-genomes external-genomes.txt \
                                -o concatenated-proteins.fa \
                                --hmm-source Bacteria_71 \
                                --gene-names Ribosomal_L1,Ribosomal_L2,Ribosomal_L3,Ribosomal_L4,Ribosomal_L5,Ribosomal_L6 \
                                --return-best-hit \
                                --get-aa-sequences \
                                --concatenate
```
> **`Note:`** Please examine the resulting FASTA file concatenated-proteins.fa to better understand what just happened.

Now we have the FASTA file, we can use the program anvi-gen-phylogenomic-tree

## 6. Phylogenomic tree

```bash
anvi-gen-phylogenomic-tree -f concatenated-proteins.fa \
                           -o phylogenomic-tree.txt
```

## 7. ANVIO Interactive tree

```bash
anvi-interactive -p phylogenomic-profile.db \
                 -t phylogenomic-tree.txt \
                 --title "Phylogenomics Tutorial Example #1" \
                 --manual
```
> Close the Anvio Interactive.
> Download the additional data for each genome:

```bash
wget https://goo.gl/UZDbC8 -O view.txt
```
**`Now you can run the interactive interface again to see the additional layers:`**

```bash
anvi-interactive -p phylogenomic-profile.db \
                 -d view.txt \
                 -t phylogenomic-tree.txt \
                 --title "Phylogenomics Tutorial Example #2" \
                 --manual
```



