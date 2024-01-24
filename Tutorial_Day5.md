# 
$${\color{red}DAY 5}$$
# 

## Your data
``` 
cd /work_beegfs/sunam###/Metagenomics
``` 

$\color{#58A6FF}\textsf{\Large\&#x24D8;\kern{0.2cm}\normalsize Note}$
Do not forget to activate the conda environment

``` 
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8
``` 


## Taxonomic assignment

You will now add taxonomic annotations to your MAG. 

``anvi-run-scg-taxonomy`` *associates the single-copy core genes in your contigs-db with taxnomy information*. (https://anvio.org/help/main/programs/anvi-run-scg-taxonomy/)


```ssh
anvi-run-scg-taxonomy -c ? -T 20 -P 2
```

<details><summary><b>Finished commands</b></summary>


```ssh
anvi-run-scg-taxonomy -c /PATH/TO/contigs.db -T 20 -P 2
```
</details>

Now you can run ``anvi-estimate-scg-taxonomy``, *‘This program makes quick taxonomy estimates for genomes, metagenomes, or bins stored in your contigs-db using single-copy core genes’* (https://anvio.org/help/main/programs/anvi-estimate-scg-taxonomy/). Use the program in metagenome-mode, as your contigs contain multiple genomes. 

```ssh
anvi-estimate-scg-taxonomy -c ? --metagenome-mode ? ? ? ?
```

<details><summary><b>Finished commands</b></summary>

To estimate abundance of Ribosomal RNAs within your dataset (coverage) use: 
```ssh
anvi-estimate-scg-taxonomy -c /PATH/TO/contigs.db -p /PATH/TO/profile.db --metagenome-mode --compute-scg-coverages --update-profile-db-with-taxonomy
```
The output will be seen on your terminal, if you want to save it you will need to run the command as follows: 

```ssh
anvi-estimate-scg-taxonomy -c /PATH/TO/contigs.db -p /PATH/TO/profile.db --metagenome-mode --compute-scg-coverages --update-profile-db-with-taxonomy > temp.txt
```
ONE final summary to get comprehensive info about your METABAT2 bins:
```ssh
anvi-summarize -p /PATH/TO/merged_profiles/PROFILE.db -c /PATH/TO/contigs.db --metagenome-mode -o /PATH/TO/SUMMARY_METABAT2 -C METABAT2
```

</details>


## Questions
  
* **Did you get a species assignment to the ${\color{red}ARCHAEA}$ bins previously identified?**
* **Does the HIGH-QUALITY assignment of the bin need revision?**
* **hint: MIMAG quality tiers https://www.nature.com/articles/nbt.3893**

 
> INSERT\
> YOUR\
> ANSWER\
> HERE

## Genome dereplication {{BONUS}}

Genome dereplication will be done using anvio. ``anvi-dereplicate-genome`` *“uses the user’s similarity metric of choice to identify genomes that are highly similar to each other, and groups them together into redundant clusters. The program finds representative sequences for each cluster and outputs them into fasta files.”*
(https://anvio.org/help/7/programs/anvi-dereplicate-genomes/)


It will use fastANI by Jain et al. (DOI: 10.1038/s41467-018-07641-9) to perform the dereplication. 
This program calculates Average Nucleotide Identity. The fast version (fastANI) is faster than the base version (piANI), at the expense of accuracy. 

Before you run anvios dereplication you have to prepare a tab delimited txt file with the following structure: 

| name | bin_id | collection_id | profile_db_path | contigs_db_path |
| --- | --- | --- | --- | --- |
| Name_1 | Bin_1 | Collection A | path/to/profile.db | path/to/contigs.db |
| Name_2 | Bin_2 | Collection A | path/to/profile.db | path/to/contigs.db |

Now you can run the actual dereplication step:

```ssh
anvi-dereplicate-genomes -i ? --program fastANI --similarity-threshold ? -o ? --log-file log_ANI -T 10
```

<details><summary><b>Finished commands</b></summary>

```ssh
anvi-dereplicate-genomes -i /PATH/TO/file.txt --program fastANI --similarity-threshold 0.95 -o ANI --log-file log_ANI -T 10
```
</details>


>`-i` txt file of your contigs\
>`--program` specify the program anvio will use for dereplication (here fastANI)\
>`--similarity-threshold` if two genomes have a similarity greater or equal to this threshold, they will belong to the same cluster\
>`-o` output_folder\
>`-O` output_folder/R2.fastq.gz output file\
>`--log-file` name of the log file\
>`-T` number of threads used

## Questions
  
* **How many species do you have in the dataset?**
* **Try to dereplicate again at 90% identity then at 80%identity. In your own words, explain the differences between the different %identities.**
 
> INSERT\
> YOUR\
> ANSWER\
> HERE
