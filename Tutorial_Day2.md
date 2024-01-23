
# From raw reads to MAGs

## Aim

In this tutorial, the aim is to learn how to assemble Metagenome Assembled Genomes (MAG) from raw reads. 
You will start by 
* Pre-processing the raw reads (trimming adapters, removing chimeras, removing phiX174 virus sequences…) 
* Assemble reads into contigs/fasta
* Assess quality of assemblies
* Bin contigs into MAGs
* Asses the completeness, contamination, and strain heterogeneity of your MAGs

**! We are not taking credit for the tools, we are simply explaining how they work for an in-house tutorial !** 

## Tools used in tutorials Day2, Day3 and Day4

| Tool | Version | Repository |
| --- | --- | --- |
| fastqc | 0.12.1 | [FastQC](https://github.com/s-andrews/FastQC ) |
| fastp | 0.23.4 | [fastp](https://github.com/OpenGene/fastp ) |
| megahit | 1.2.9 | [megahit](https://github.com/voutcn/megahit ) |
| samtools | 1.19 | [samtools](https://github.com/samtools/samtools ) |
| QUAST | 5.2.0 | [quast](https://quast.sourceforge.net/quast ) |
| Bowtie2 | 2.4.5 | [bowtie2](https://bowtie-bio.sourceforge.net/bowtie2/index.shtml ) |
| binsanity | 0.5.3 | [binsanity](https://github.com/edgraham/BinSanity) |
| MetaBAT2 | 2.12.1 | [Metabat2](https://bitbucket.org/berkeleylab/metabat/src/master/ ) |
| DASTool | 1.1.5 | [DAS_Tool](https://github.com/cmks/DAS_Tool ) |
| anvi´o | 8 | [anvi’o](https://anvio.org/ ) |
| GUNC | 1.0.5 | [GUNC](https://grp-bork.embl-community.io/gunc/ ) |

## Bash script and the working system

The **caucluster** is Linux-based cluster that is particularly suitable for serial, moderately parallel and high memory computation.

### Performing batch calculations

To run a **batch calculation** it is not only important to instruct the batch system which program to execute, but also to specify the required resources, such as number of nodes, number of cores per node, main memory or computation time. These resource requests are written together with the program call into a so-called **batch** or **job script**, which is submitted to the batch system with the command.

```
sbatch <jobscript>
```

An Example script ${\color{red}“anviscript”}$ will be provided/shown the screen

Note, that every job script starts with the directive **#!/bin/bash** on the first line. The subsequent lines contain the directive **#SBATCH**, followed by a specific resource request or some other job information

After the lines with the SBATCH settings, pre-installed modules can be loaded (if required). If in doubt, a list of these can be called with < **module av** >. At the end of the job script, one finally specifies the program call. To adjust resources at a later date the line <**jobinfo**> is added to the script. This will generate a report on requested and used resources within the stdout file.
  
### Batch parameters

The following table summarizes the most important job parameters. 

| Parameter | Explanation |
| --- | --- | 
| #SBATCH | Slurm batch script directive | 
| --partition=<name> or -p <name> | Slurm partition (~batch class) | 
| --job-name=<name> or -J <jobname> | Job name | 
| --output=<filename> or -o <filename> | Stdout file | 
| --error=<filename> or -e <filename> | Stderr file; if not specified, stderr is redirected to stdout file | 
| --nodes=<nnodes> or -N <nnodes> | Number of nodes | 
| --ntasks-per-node=<ntasks> | Number of tasks per node; number of MPI processes per node | 
| --cpus-per-task=<ncpus> or -c <ncpus> | Number of cores per task or process | 
| --mem=<size[units]> | Real memory required per node; default unit is megabytes (M); use G for gigabytes | 
| --time=<time> or -t <time> | Walltime in the format "hours:minutes:seconds" | 


### Special Batch parameters
  
An important job parameters specific for our course for dedicated resources.

```
#SBATCH --reservation=biol217
```
**${\color{red}DO NOT CHANGE IT}$**
  
**MOST IMPORTANT FOR OUR COURSE:** 

- **A BATCH SCRIPT SUBMISSION IS TO BE DONE WITH EVERY STEP**

- - **EXCEPT VISUALIZATION STEPS**

- **A BATCH SCRIPT SUBMISSION IS TO BE DONE FOR ALL DAYS NOT JUST THE ANVIO DAYS**

**TO CHANGE**
  
- **Job name** 
- **Stdout file**
- **Stderr file**

**to reflect the step you are doing and get a log file per command execution.**
  
**This will help with debugging and not overwriting output files.**

AFTER ALL PARAMETERS comes 
  
- **your conda activation command line**
- **your command line for executing a process in your pipeline (see below)**

After job submission the batch server evaluates the job script, searches for free, appropriate compute resources and, when able, executes the actual computation or queues the job.


Successfully submitted jobs are managed by the batch system and can be displayed with the following commands:
  
```
squeue
```
  
or
  
```
squeue -u <username>
```
  
or for showing individual job details
  
```
squeue -j <jobid>
scontrol show job <jobid>
```
  
To terminate a running or to remove a queued job from the batch server use

```
scancel <jobid>  
``` 
For all details please refer to the online webpage description from the [RZ caucluster - CAU KIEL online documentation](https://www.rz.uni-kiel.de/en/our-portfolio/hiperf/caucluster?set_language=en)


``` 
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --time=5:00:00
#SBATCH --job-name=fastqc
#SBATCH --output=fastqc.out
#SBATCH --error=fastqc.err
#SBATCH --partition=base
#SBATCH --reservation=biol217

module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8
```


## The dataset
  
The background concerning the dataset and analysis based on 16S amplicon sequence analysis was published by Martin Fischer (https://sfamjournals.onlinelibrary.wiley.com/doi/full/10.1111/1751-7915.13313). Metagenomes from the same samples were sequenced.

In summary, The samples originated from one mesophilic agricultural biogas plant located near Cologne, Germany, sampled in more or less monthly intervals over a period of 587 days. As described by Fischer et al; 2016, the NH4+–N concentrations during the sampling period, exceeded the ~3.0 g l−1 [NH4+–N] reported ammonia concentration beneficial for acetoclastic methanogenesis where the temperature and pH of the environment play a crucial role.

**Here we will focus on 3 samples only.**

## Preparation
  
All packages and programs needed are already installed into one conda environment. Activate this environment every time you open a terminal using the following command:

```
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8
``` 


Most programs you will be using don't have a graphical user interface but are run through a terminal. 
Running the command **tool --help** function will display the required, optional and description of each parameter for the tool.


**First things to look for in the help command of every tool to structure your command line are:**

- **what is the input?**
- **what is the output?** 
- **number of cpus/threads**
- **required parameters!**
- **optional parameters!**

  
Example:

If you are using ``tool -o``  and you want to know what the flag ``-o``  means, type ``tool --help`` 
Keep in mind that, whenever you need a certain file, script or whatever else for a command, you can either 
* Change to the directory where the file is stored and give the name of the file as input, or 
* In the path you are currently at, you give the full path of where the file is located 
* If ``example_file123`` is stored in the folder ``example_folder456`` your commands could look like this: ``[.../some_folder]$example program -i ../example_folder456/example_file123`` when you are somewhere, or ``[.../example_folder456]$ example_program -i example_file123`` when you are in the folder where the file is stored

Remember, most issues are ${\color{red}typos}$ or ${\color{red}path}$ related ${\color{red}!!!!!!!}$
  
  
  
# 
$${\color{red}DAY 2}$$
# 

## Quality Control of raw reads
  
First we need to evaluate the quality of the sequenced data before proceeding with further analysis. You will use fastqc and fastp for this. 

[FastQC](https://github.com/s-andrews/FastQC ) provides an overview of basic quality control metrics like the **phred quality score**. This metric gives you an idea on how accurately the base reading was.

$\color{#D29922}\textsf{\Large\&#x26A0;\kern{0.2cm}\normalsize Warning}$
Before you start, create a folder to store your results in. ${\color{red}Hint:}$ use ``mkdir``!

The first command allows you to loop over all files ending with **.gz** (can be changed to other endings, here those files are compressed **.fastq** files) you have in the directory you are currently in. The second command can be used for single files. In both cases the output will be stored in the **output_folder** (change the name according to the name of your folder).

$\color{#58A6FF}\textsf{\Large\&#x24D8;\kern{0.2cm}\normalsize Note}$
DO NOT FORGET TO SUBMIT YOUR COMMAND IN A BATCH SCRIPT!

```ssh
fastqc ? -o ?
```

<details><summary><b>Finished commands</b></summary>

```ssh
fastqc file.gz -o output_folder/ 
```

or in a loop:

```ssh
for i in *.gz; do fastqc $i -o output_folder/; done
```
</details>

  
> `file.gz` name of the input file\
> `-o` output folder
  
[fastp](https://github.com/OpenGene/fastp ) allows you to process the reads using different parameters. The following command loops over your data applying fastp. As we have paired end readings we need to specify two different inputs for **R1** and **R2** files, which makes the loop look a little complicated.

For a better understanding, you will find the single command below.

```ssh
fastp -i ? -I ? -R ? -o ? -O ? -t 6 -q 20
```

<details><summary><b>Finished commands</b></summary>

```ssh
fastp -i sample1_R1.fastq.gz -I sample1_R2.fastq.gz -R fastp_report -o sample1_R1_clean.fastq.gz -O sample1_R2_clean.fastq.gz -t 6 -q 20
```

</details>

```
> `--html` creates an .html report file in html format\
>`-i` R1 input file name\
>`-I` R2 input file name\
>`-R` report title, here ‘_report’ is added to each file\
>`-o` output_folder/R1.fastq.gz output file\
>`-O` output_folder/R2.fastq.gz output file\
>`-t` trim tail 1, default is 0, here 6 bases are trimmed\
>`-q` 20 reads with a phred score of <=20 are trimmed
```

## Assembly

The first step is to use your [fastp](https://github.com/OpenGene/fastp) processed data and perform genome assemblies using [megahit](https://github.com/voutcn/megahit ), an ultra-fast and memory-efficient NGS assembler. It is optimized for metagenomes coassembly, multiple samples:

```ssh
cd /PATH/TO/CLEAN/READS
                                       
megahit -1 ? -1 ? -1 ? -2 ? -2 ? -2 ? --min-contig-len 1000 --presets meta-large -m 0.85 -o ? -t 12        
```

<details><summary><b>Finished commands</b></summary>

```ssh
megahit -1 sample1_R1_clean.fastq.gz -1 sample2_R1_clean.fastq.gz -1 sample3_R1_clean.fastq.gz -2 sample1_R2_clean.fastq.gz -2 sample2_R2_clean.fastq.gz -2 sample3_R2_clean.fastq.gz --min-contig-len 1000 --presets meta-large -m 0.85 -o /PATH/TO/3_coassembly/ -t 12   
```
</details>
                                       
> `-1` path to R1 file\
> `-2` path to R2 file, for paired end readings only\
> `-o` path to output folder

The output folder will contain the assembly file per **SAMPLE**:
``output_dir/final.contigs.fa`` contains resulting contigs. Sequence assembled from short or long reads, that still represents only a fraction of the longer context to which it belongs to.
  
To visualize contig graph in **Bandage**, the first step is to convert the fasta file(s) intermediate_contigs/k{kmer_size}.contigs.fa into SPAdes-like **FASTG** format. The following code shows the translation from **NAME.contigs.fa** into **NAME.fastg**.
  
Example:
```
megahit_toolkit contig2fastg 99 final.contigs.fa > final.contigs.fastg                   
```
Then the FASTG file k99.fastg can be loaded into **Bandage**.

The program is already installed on your PC and can be used as a GUI.
Use it to open the **final.contigs.fastg** file. Once it's loaded (this might take a second) click on Draw graph to create a graph. 
  
You can now label the nodes by adding parameters like Depth or Name. Whenever you change something you need to click draw graph again.

## Questions
  
* **Please submit your generated figure and explain in your own words what you can see (keep it short).**
 
> INSERT\
> YOUR\
> ANSWER\
> HERE
