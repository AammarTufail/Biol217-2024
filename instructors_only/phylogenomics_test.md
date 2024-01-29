# Anvio phylogenomics
https://merenlab.org/2017/06/07/phylogenomics/

start working with fasta files and include them into the pangenome

## Download exampel data
```
mkdir -p $HOME/phylogenomics_test

# download the data pack
wget https://ndownloader.figshare.com/files/28715136 -O AnvioPhylogenomicsTutorialDataPack.tar.gz

# unpack it
tar -zxvf AnvioPhylogenomicsTutorialDataPack.tar.gz

#were working with the distantly related example data
cp AnvioPhylogenomicsTutorialDataPack/distantly-related/* ./
```
## download the genome.txt file
```
wget https://goo.gl/XuezQF -O external-genomes.txt
```
If we want additional information about genus and phylum:
```
wget https://goo.gl/UZDbC8 -O view.txt
```
* does not work. File is always empty
* If we want to use it, use:
```
echo -e "genome_id\tgenome\tphylum\tgenus" > view.txt
echo -e "Bacteroides_fragilis_2334\tB. fragilis 03\tBacteroidetes\tBacteroides" >> view.txt
echo -e "Bacteroides_fragilis_2346\tB. fragilis 02\tBacteroidetes\tBacteroides" >> view.txt
echo -e "Bacteroides_fragilis_2347\tB. fragilis 01\tBacteroidetes\tBacteroides" >> view.txt
echo -e "Escherichia_albertii_6917\tE. albertii\tProteobacteria\tEscherichia" >> view.txt
echo -e "Escherichia_coli_6920\tE. coli 02\tProteobacteria\tEscherichia" >> view.txt
echo -e "Escherichia_coli_9038\tE. coli 01\tProteobacteria\tEscherichia" >> view.txt
echo -e "Prevotella_dentalis_19591\tP. dentalis\tBacteroidetes\tPrevotella" >> view.txt
echo -e "Prevotella_denticola_19594\tP. denticola\tBacteroidetes\tPrevotella" >> view.txt
echo -e "Prevotella_intermedia_19600\tP. intermedia\tBacteroidetes\tPrevotella" >> view.txt
echo -e "Salmonella_enterica_21806\tS. enterica 01\tProteobacteria\tSalmonella" >> view.txt
echo -e "Salmonella_enterica_22047\tS. enterica 02\tProteobacteria\tSalmonella" >> view.txt
echo -e "Salmonella_enterica_22289\tS. enterica 03\tProteobacteria\tSalmonella" >> view.txt
```


## Script 1:
```
## Generate contigs db
for i in `ls *fa | awk 'BEGIN{FS=".fa"}{print $1}'`
do
    anvi-gen-contigs-database -f $i.fa -o $i.db -T 4
    anvi-run-hmms -c $i.db
done

## run hmms for Rimosomal genes L1-L6
    # any gene names can be entered
    # without --gene-names it will run for all genes
anvi-get-sequences-for-hmm-hits --external-genomes external-genomes.txt \
                                -o concatenated-proteins.fa \
                                --hmm-source Bacteria_71 \
                                --gene-names Ribosomal_L1,Ribosomal_L2,Ribosomal_L3,Ribosomal_L4,Ribosomal_L5,Ribosomal_L6 \
                                --return-best-hit \
                                --get-aa-sequences \
                                --concatenate

## generate phylogenomic tree
anvi-gen-phylogenomic-tree -f concatenated-proteins.fa \
                           -o phylogenomic-tree.txt
```
## display the phylogenome
```
srun --pty --mem=10G --nodes=1 --tasks-per-node=1 --cpus-per-task=1 --partition=base /bin/bash

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8_biol217

#run it without the -d flag if you didnt download/create the additional information file: view.txt
anvi-interactive -p phylogenomic-profile.db \
                 -d view.txt \
                 -t phylogenomic-tree.txt \
                 --title "Phylogenomics Tutorial Example #1" \
                 --manual
```
In a new terminal (update the node "n100" to actually used one)
```
ssh -L 8060:localhost:8080 sunam226@caucluster.rz.uni-kiel.de

ssh -L 8080:localhost:8080 n114
```
click: http://127.0.0.1:8060/



# Pangenome integration from Phylogenomics workflow

#----------------------------------------------------------
#-----------------------------------------------------------
Probably not used in the course, if we want to use a different pangenome: 
#----------------------------------------------------------
## generate the pangenome to recieve gene clusters
```
# generate anvi'o genomes storage
anvi-gen-genomes-storage -e external-genomes.txt \
                         -o Salmonella-GENOMES.db

# do the pangenomic analysis --this will take about
# 5 to 10 mins
anvi-pan-genome -g Salmonella-GENOMES.db \
                --project-name Salmonella \
                --num-threads 8


# display the pangenome
anvi-display-pan -g Salmonella-GENOMES.db \
                 -p Salmonella/Salmonella-PAN.db
```
* Generate a bin for all the genes youre interested in (f.e. core genes, sccgs, ...)
    * save as default
## export the alignment gene cluster
```
anvi-get-sequences-for-gene-clusters -g Salmonella-GENOMES.db \
                                     -p Salmonella/Salmonella-PAN.db \
                                     --collection-name default \
                                     --bin-id Some_Core_PCs \
                                     --concatenate-gene-clusters \
                                     -o concatenated-proteins.fa
```
## generate the phylogenomic tree
```
anvi-gen-phylogenomic-tree -f concatenated-proteins.fa \
                           -o phylogenomic-tree.txt
```
## visualize the tree
```
srun --pty --mem=10G --nodes=1 --tasks-per-node=1 --cpus-per-task=1 --partition=base /bin/bash

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8_biol217

# run the interactive interface
anvi-interactive -p phylogenomic-profile.db \
                 -t phylogenomic-tree.txt \
                 --title "Phylogenomics Tutorial Example #4" \
                 --manual
```
In a new terminal (update the node "n100" to actually used one)
```
ssh -L 8060:localhost:8080 sunam226@caucluster.rz.uni-kiel.de

ssh -L 8080:localhost:8080 n100
```
click: http://127.0.0.1:8060/

#----------------------------------------------------
Course will continue from here
#------------------------------------------------------------
#------------------------------------------------------

## Add the phylogenomics to the pangenome:
create a tab delimited file to add a new genomes order called: layers_order.txt
* the data values are inside phylogenomic-tree.txt, so paste it into the file
```
echo -e "item_name\tdata_type\tdata_value" > layers_order.txt
printf "phylo_tree\tnewick\t%s\n" "$(cat phylogenomic-tree.txt)" >> layers_order.txt
```
### import he data to pan db
```
anvi-import-misc-data -p Salmonella/Salmonella-PAN.db \
                      -t layer_order.txt \
                      additional-layers-data.txt
```
### display the pangenome
```
srun --pty --mem=10G --nodes=1 --tasks-per-node=1 --cpus-per-task=1 --partition=base /bin/bash

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8_biol217

# run the interactive interface
anvi-display-pan -g Salmonella-GENOMES.db \
                 -p Salmonella/Salmonella-PAN.db
```
In a new terminal (update the node "n100" to actually used one)
```
ssh -L 8060:localhost:8080 sunam226@caucluster.rz.uni-kiel.de

ssh -L 8080:localhost:8080 n100
```
click: http://127.0.0.1:8060/