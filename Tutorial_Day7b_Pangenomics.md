# 
$${\color{red}DAY 7b}$$
# 




```bash
cd $WORK/pangenomics
mkdir -p 01_input_data
cd 01_input_data
# download the data pack
wget https://ndownloader.figshare.com/files/28715136 -O input_genomes.tar.gz
# unpack it and remove packed files
tar -zxvf input_genomes.tar.gz
rm -r input_genomes.tar.gz
#rename the dir
mv AnvioPhylogenomicsTutorialDataPack/ input_genomes/ 
#let's see what we have
ls -l input_genomes/
# remove only Salmonella
rm -r $WORK/pangenomics/01_input_data/input_genomes/distantly-related/Salmonella_enterica*
```
# Pangenomics - comparing genomes with ANVIO

## Aim
In this tutorial we will combine both the previously assembled MAGs and reference genomes for a phylogenetic and functional genome comparison.
This tutorial follows the workflow of the [anvi'o miniworkshop](https://merenlab.org/tutorials/vibrio-jasicida-pangenome/) and the [pangenomics workflow](https://merenlab.org/2016/11/08/pangenomics-v2/).


**Workflow:**

1. Recap on the Batch Script
2. Evaluating the contigs databases
3. Create pangenome from individual bins/genomes
4. Compare the data phylogenetically (ANI)
5. Visualizing the pangenome
6. Interpreting and ordering the pangenome
7. BONUS: BlastKoala

**Folder Structure:** 02_contigs-dbs, 03_pangenome

**Programs used:**

| Program or Database                                          | Function                                                     |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [anvi'o](https://anvio.org/)                                 | Wrapper for genome comparissons                              |
| [DIAMOND](https://www.wsi.uni-tuebingen.de/lehrstuehle/algorithms-in-bioinformatics/software/diamond/) | creates high-throughput protein alignments                   |
| [pyANI](https://github.com/widdowquinn/pyani)                | calculates genome similarities based on average nucleotide identity |
| [BlastKOALA](https://www.kegg.jp/blastkoala/)                | Onlinetool which creates metabolic networks for a given genome, based on the KEGG database |
| [KEGG](https://www.kegg.jp/)                                 | Kyoto Encyclopaedia of Genes and Genomes (Database)          |
| [NCBI COG](https://www.ncbi.nlm.nih.gov/research/cog)        | Clusters of Orthologous Genes (Database)                     |



## 1. A recap on the batch script and for loops

To create a batch script copy the dummy from here, or one of your older  scripts

```ssh
cp ....sh .
```

The batch script should contain:

1. The shebang
2. Processing requirements as #SBATCH commands
    - Reservation
    - Nodes to use
    - CPUs (for  multithreading)
    - memory requirements
    - time
    - working directory
    - log files
    - partitions
3. Stdin and Stderr paths
4. Slurm modules needed for the task
5. The command
6. jobinfo

```shell
#!/bin/bash

#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=5G
#SBATCH --time=1:30:00
#SBATCH --reservation=biol217

#SBATCH -D ./
#SBATCH --output=./3_fasta-for-anvio.out
#SBATCH --error=./3_fasta-for-anvio.out
#SBATCH --partition=all

# for pangenome
conda activate /home/sunam225/miniconda3/miniconda4.9.2/usr/etc/profile.d/conda.sh/envs/anvio-7.1

# set working directory by navigating there
cd ....

# Insert your command here


# provides information on resource requirements as stdout
jobinfo
```

# Start of Pangenomics

## 2. Evaluation of our starting databases (Directory: 02_contigs-dbs)

Today we are working with a new set of contigs.dbs. They contain MAGs from the Biogasreactor, and a complete Methanogen Genome.

In order to get us started we will visualize and compare these bins in a summary overview.

This is done with the <anvi-display> function. Bring up the help and check which parameters you need.


As we have an interactive interface, this requires tunneling, the same way we did last week:

```ssh
#get direct access to a HPC compute node
srun --reservation=biol217 --pty --mem=10G --nodes=1 --tasks-per-node=1 --cpus-per-task=1 /bin/bash

#activate the conda environment
conda activate /home/sunam225/miniconda3/miniconda4.9.2/usr/etc/profile.d/conda.sh/envs/anvio-7.1

# start anvi'o interactive display
anvi-display-contigs-stats *db
```

Now open another terminal and start the tunnel:

*Remeber to adjust the node name and your sunam user*
   
*If anvio tells you so, change the port: 8080 to the allocated port*

```ssh
ssh -L 8060:localhost:8080 sunam225@caucluster-old.rz.uni-kiel.de
ssh -L 8080:localhost:8080 node{#}
```


After entering your password, you need to manually open a chrome browser and enter the following IP. 
http://127.0.0.1:8060


**Task:** Take some time to click through the views and compare the MAGs. Add a screenshot of your output to your documentation. Answer the following Questions:

**Question:** How do the MAGs compare in size and number of contigs to the full genome?

**Answer**
>Answer
>Here


**Question:** Based on the contig numbers, sizes and number of marker genes (HMM hits), which two MAGs are the best and which is the worst?

**Answer**
>Answer
>Here

When you are done, close the window and Ctrl+C in the command lines.

Close the direct access to a cluster node with:

```ssh
exit
```

## 3. Making a Pangenome (Directory: 03_pangenome)


A pangenome visualizes entire genomes for comparisson.

It can show essential and accessory gene clusters, phylogenetic relationships and genome qualities.


### 3.1 Create an external genomes file

To tell the programm which genomes and MAGs it should use, we will create the "external genomes file".

The [external genomes file](https://anvio.org/help/7/artifacts/external-genomes/) contains one column with the genome/bin name and one with its path (where it is saved).

| name          | contigs_db_path                   |
| ------------- | --------------------------------- |
| Bin1          | /path/to/contigs-bin-01-120311.db |
| Genome-name   | /path/to/contigs-genome-name.db   |


We already have a folder with all the genome databases we want to compare (02_contigs-dbs). Anvi'o has a script to create the input information for us:

**TASK:** Complete the following line, and use it on the login node.

```ssh 
anvi-script-gen-genomes-file --input-dir ? -o external-genomes.txt
```

Now look into your file to verify whether it looks accurate. 

*Tip* use `cat` or `head`

**OUTPUT**
> Paste your table here

### 3.2 Estimate genome completeness

To avoid any nasty suprises by adding a bad bin or incomplete genome to the pangenome, estimate genome completeness.
This will give you information on the quality of your MAGs and genomes.

**Question:** The command provides its output as a table to the standard output of the terminal. What can you add to the code to direct output to, e.g. a  .txt file?

<details><summary><b>Solution:</b></summary>

```ssh
anvi-estimate-genome-completeness -e external-genomes.txt > genome-completeness.txt
```
</details>

We want to specifically look at **redundancy** and **completeness**.


**Question:** How do the bins compare to isolate genomes? Would you remove one, based on the output of the completeness estimation?

**ANSWER:**
>Answer
>Here

**OPTIONAL:** An option at this stage is to further refine your bins, by removing sequences that contaminate the genome. As you have done this last week, we will go ahead with the genomes we have.

### 3.3 Remove unwanted genomes (Directory: 02_contigs-dbs)

As we have some MAGs with a low completion, we will remove them from our pangenome. Common practice is, to consider only genomes with **> 70% completion** and **< 10% redundancy**.

For this go back to 02_contig-dbs, create a new directory "discarded" and `mv` the "bad MAGs_dbs" to this folder.

Return to 03_pangenome and recreate the external genomes file.

```ssh
anvi-script-gen-genomes-file --input-dir ? -o external-genomes-final.txt
```

## 3.4 Creating the pangenome database (Directory: 03_pangenome)

In anvi'o we will need to generate two artifacts, similar to when working with assemblies. The first is the [genomes-storage.db](https://anvio.org/help/7/artifacts/genomes-storage-db/), which corresponds to an individual contigs.db, but merges all individual genomes you are working with into one database. The files themselves will be a bit leaner, than all files together, making it easier to share and publish those.

The database contains:

1. all genome fasta files
2. the gene annotations (HMMs, SCGs) which were added before
3. any new annotations and genome comparisons we will make

The second file is the [pan-genome.db](https://anvio.org/help/main/programs/anvi-pan-genome/). It is similar to the profile you generate to annotate your bins. 

This will contain:

1. genome similarities based on gene amino acid sequences.
2. resolved gene clusters
3. any post-analysis of gene clusters, downstream analyses and visualisations


We will combine the next two steps in one *BATCH script* with the following computing requirements:

**change SBATCH Settings: --nodes=1, --cpus-per-task=10, --mem=500M, --time=00:05:00**

*Don't forget to specify your .err and .out files. This time give them the same name and the ending .log, e.g. Example.log*

Look for the following commands and settings and complete this in your batch script:

```ssh
anvi-gen-genomes-storage -e ? -o ?

anvi-pan-genome -g ? --project-name ? --num-threads 10
```

<details><summary><b>Finished commands</b></summary>

```ssh
anvi-gen-genomes-storage -e external-genomes_final.txt \
                         -o ?-GENOMES.db
```

The command to create the pan-genomes is the following:

```ssh
anvi-pan-genome -g Methano-GENOMES.db \
                --project-name "NAMEOFCHOICE" \ #Foldername
                --num-threads 10
```
</details>

## 4. Genome similarity based on average nucleotide identity (ANI) (Directory: 03_pangenome)

The next step calculates the [genome similarity](https://anvio.org/help/main/programs/anvi-compute-genome-similarity/) to each other. The most commonly used approach is average nucleotide identity using the [MUMmer](https://mummer.sourceforge.net/) algorithm to align each genome. The result of this is used as a measure to determine how related the genomes are and whether you have discovered a new species. Usually the cutoff for the species boundary is set at 95-96% identity over a 90% genome coverage [[Ciufo, et al., 2018](); [Jain, et al. (2018)](https://doi.org/10.1038/s41467-018-07641-9)].

Once anvi'o has calculated the genome similarity, you can use its output to organize your genomes based on their relatedness.

Depending on the amount of genomes you are using, this step can be quite memory intensive.

Find out what the following parameters mean and complete the command in a **BATCH script**:

**SBATCH Settings: --nodes=1, --cpus-per-task=10, --mem=600M, --time=00:02:00**

```ssh
anvi-compute-genome-similarity --external-genomes ? --program ? --output-dir ? --num-threads ? --pan-db ?
```

<details><summary><b>Finished commands</b></summary>

```ssh
anvi-compute-genome-similarity --external-genomes external-genomes_final.txt \
                               --program pyANI \
                               --output-dir ANI \
                               --num-threads 10 \
                               --pan-db Biol217/Biol217-PAN.db
```
</details>

Once we have calculated the genome similarity, we will start our interactive interface for the pangenome


## 5. Visualizing the pangenome (Directory: 03_pangenome)

>*Tip:* When we are working in the interface, we may want to save the changes we have made to the views. This can easily be done via the save buttons. Make sure to give your state a significant name, i.e. the step you are at.

First get direct access to a HPC compute node:
```ssh
srun --pty --mem=10G --nodes=1 --tasks-per-node=1 --cpus-per-task=1 --reservation=biol217 --partition=all /bin/bash

#activate the conda environment
conda activate /home/sunam225/miniconda3/miniconda4.9.2/usr/etc/profile.d/conda.sh/envs/anvio-7.1

```

Let's check out the pangenome command:

```ssh
anvi-display-pan -h
```

Scroll to the top of the help and find out which **INPUT FILES** you need. Write the command and use the additional flag -P. ***What is the -P flag for?***

**Answer:**
> Answer here

<details><summary><b>Finished anvi-display-pan command</b></summary>
Each of you must use a different port (-P): 8080 - 8090

```ssh
# start anvi'o interactive display
anvi-display-pan -p Biol217/Biol217-PAN.db \
                 -g Methanogen-GENOMES.db \
                 -P 8083
```

Now open another terminal in MobaXterm and start the tunnel:
*Remeber to adjust the node name and your sunam user*

```ssh
ssh -L 8060:localhost:8080 sunamXXX@caucluster-old.rz.uni-kiel.de 
ssh -L 8080:localhost:8080 nodeXXX
```

After entering your password, you need to manually open a chrome browser and enter the following IP. 
http://127.0.0.1:8060

</details>


### **6. Interpreting and ordering the pangenome (interactive interface)**

### **TASKS: Genome similarity**

1. Remove combined homogeneity, functional homogeneity, geometric homogeneity, max num parsimonay, number of genes in gene cluster and number of genomes gene cluster has hits from the active view. *Tip: Play with Height*

2. Create a "Bin-highlight" including alls SCGs and name it accordingly. [How to?](https://app.tango.us/app/workflow/Create-SCG-Gene-Range-210254e1f8bb46f6b283730303ef9f8a)

3. Cluster the genomes based on **Frequency**

**Question:** Based on the frequency clustering of genes, do you think all genomes are related? Why?

**Answer:**
> Answer
> Here

4. Highlight your reference genome in one color, its closest relative in a similar one, and distict genomes in a third colour.

**Question:** How does the reference genome compare to its closest bin?
*Tip: Consider the genome depiction and layers above*

> Answer

5. Go to Layers and remove Num gene clusters, Singeltons, Genes per kbp and Total length from view. Add ANI_percentage_identity to the view and play with the threshold.

**Questions:** What % ANI cutoff is used to determine a prokaryotic species? How high can you go until you see changes in ANI in your pangenome? What does the ANI clustering tell you about genome relatedness?

> Answer

### **TASKS: Functional Profiling**

1. Using the Search Function, highlight all genes in the KEGG Module for Methanogenesis
2. Create a new bin called "Methanogenesis" and store your search results in this bin.

**Question:** How are Methanogenesis genes distributed across the genome?
> Answer

3. Google COG Categories and select one you are interesed in. Create a new bin, find your Category in the Pangenome and add it to this selection.

4. Save your state and export this view as .svg

***INSER FINAL VIEW HERE***

### **TASKS: Functional/geometric homogeneity and their uses**

1. Using search parameters, find a gene which occurs:
    - in all genomes
    - a maximum of 1 times (Single copy gene)
    - has a high variability in its functional homogeneity (max. 0.80)
    
    This gene will be highly conserved, but has diversified in its AA make-up.

2. Highlight the found genes on the interface. Inspect one of the gene-clusters more closely (Inspect gene-cluster).

**Question:** What observations can you make regarding the geometric homogeneity between all genomes and the functional homogeneity?

>Answer and Screenshot



## **BONUS: BlastKoala**

Outside of anvi'o there are a range of tools available to investigate your organisms metabolism. One of these is BlastKOALA, which generates a metabolic profile of your genome based on the KEGG database.

**Task:** Check out the [BlastKOALA Results](https://www.kegg.jp/kegg-bin/blastkoala_result?id=5167323e7144fba776bf171bbf8afe664095205a&passwd=IdCWWe&type=blastkoala) for this Methanogen. 

Reconstruct its pathways and check out what it can do. 

**Question:** Can the organism do methanogenesis? Does it have genes similar to a bacterial secretion system?
   
**Answer:**
   > Answer Here

