# 
$${\color{red}DAY 4}$$
# 

## Your data
``` 
cd /work_beegfs/sunam###/Metagenomics
```


## Bin refinement

$\color{#58A6FF}\textsf{\Large\&#x24D8;\kern{0.2cm}\normalsize Note}$
We focus only on the ARCHAEA BINS!!

Use anvi-summarize. *``Anvi-summarize`` lets you look at a comprehensive overview of your collection and its many statistics that anvi’o has calculated.
It will create a folder called SUMMARY that contains many different summary files, including an HTML output that conveniently displays them all for you.”* 
(https://anvio.org/help/7.1/programs/anvi-summarize/).

This command will also create ``.fa`` files of your bins, needed for further analysis using other programs.

$\color{#58A6FF}\textsf{\Large\&#x24D8;\kern{0.2cm}\normalsize Note}$
Do not forget to activate the conda environment

``` 
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8
``` 

First, you can use the following command to get a list of your collections; then use anvi-summarize:

```ssh
anvi-summarize -p ? -c ? --list-collections
anvi-summarize -c ? -p ? -C ? -o ? --just-do-it
```

<details><summary><b>Finished commands</b></summary>

```ssh
anvi-summarize -p /PATH/TO/merged_profiles/PROFILE.db -c /PATH/TO/contigs.db --list-collections
```

Then use anvi-summarize as displayed below.

```ssh
anvi-summarize -c /PATH/TO/contigs.db -p /PATH/TO/merged_profiles/profile.db -C METABAT2 -o SUMMARY_METABAT2 --just-do-it
```
</details>

$\color{#58A6FF}\textsf{\Large\&#x24D8;\kern{0.2cm}\normalsize Note}$
Explore the err output from your summary table


As each bin is stored in its own folder, use 
``` 
cd /PATH/TO/SUMMARY/bin_by_bin

mkdir ../../ARCHAEA_BIN_REFINEMENT

cp /PATH/TO/bin_by_bin/METABAT_BIN_###/*.fa /PATH/TO/ARCHAEA_BIN_REFINEMENT/
``` 
$\color{#D29922}\textsf{\Large\&#x26A0;\kern{0.2cm}\normalsize Warning}$
!!!!!!!!!!!!!!!DO THIS FOR ALL ARCHAEA BINS YOU HAVE!!!!!!!!!!!!!!!

### Chimera detection in MAGs

Use [GUNC](https://grp-bork.embl-community.io/gunc/ ) to check run chimera detection. 

**Genome UNClutter (GUNC)** is “a tool for detection of chimerism and contamination in prokaryotic genomes resulting from mis-binning of genomic contigs from unrelated lineages.”

Chimeric genomes are genomes wrongly assembled out of two or more genomes coming from separate organisms. For more information on GUNC: https://genomebiology.biomedcentral.com/articles/10.1186/s13059-021-02393-0

to use [GUNC](https://grp-bork.embl-community.io/gunc/ ) , activate the following environment: 

```
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate gunc
``` 
Use the following loop to process all your files in one run: 


```ssh
cd /PATH/TO/ARCHAEA_BIN_REFINEMENT

mkdir GUNC

for i in *.fa; do gunc run -i ? -r /work_beegfs/sunam###/Databases/gunc_db_progenomes2.1.dmnd --out_dir ? --threads 10 --detailed_output; done

gunc plot -d /PATH/TO/YOUR/diamond_output/METABAT__#-contigs.diamond.progenomes_2.1.out -g /PATH/TO/YOUR/genes_calls/gene_counts.json
```

<details><summary><b>Finished commands</b></summary>

```ssh
cd /PATH/TO/ARCHAEA_BIN_REFINEMENT

mkdir GUNC

for i in *.fa; do gunc run -i "$i" -r /work_beegfs/sunam###/Databases/gunc_db_progenomes2.1.dmnd --out_dir GUNC/"$i" --threads 10 --detailed_output; done
```
</details>

in case of errors please run 

```
conda install bioconda::prodigal
conda install bioconda::diamond==2.0.4.
```


> `-i` name of the input file
> `-r` name of the gunc database (downloaded in advance)

#### Questions
* Do you get ${\color{red}ARCHAEA}$ bins that are chimeric? 
* hint: look at the CSS score (explained in the lecture) and the column PASS GUNC in the tables outputs per bin in your gunc_output folder.
* In your own words (2 sentences max), explain what is a chimeric bin.

> INSERT\
> YOUR\
> ANSWER\
> HERE

### Manual bin refinement

As large metagenome assemblies can result in hundreds of bins, pre-select the better ones for manual refinement, e.g. > 70% completeness.

Before you start, make a **copy/backup** of your unrefined bins the ``ARCHAEA_BIN_REFINEMENT``.

$\color{#D29922}\textsf{\Large\&#x26A0;\kern{0.2cm}\normalsize Warning}$
You can save your work as refinement overwrites the bins. 

``` 
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8
``` 

Use anvi refine to work on your bins manually. *“In the interactive interface, any bins that you create will overwrite the bin that you originally opened. If you don’t provide any names, the new bins’ titles will be prefixed with the name of the original bin, so that the bin will continue to live on in spirit.
Essentially, it is like running anvi-interactive, but disposing of the original bin when you’re done.” https://anvio.org/help/main/artifacts/interactive/*

``` 
anvi-refine -c /PATH/TO/contigs.db -C METABAT -p /PATH/TO/merged_profiles/PROFILE.db --bin-id Bin_METABAT__##
``` 

```diff
-!!!!!!!!!!!!!!!!!!!!!AS MENTIONED BEFORE!!!!!!!!!!!!!!!!!!!!!
- Here you need to access anvi’o interactive -
- REPLACE the command line you want to run in interactive mode -
```

```
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8

anvi-refine -c /PATH/TO/contigs.db -C METABAT -p /PATH/TO/merged_profiles/PROFILE.db --bin-id METABAT__25
```

You can now sort your bins by **GC content**, by **coverage** or both. 

For refinement it is easier to use the clustering based on only differential coverage, and then only based on sequence composition in search for outliers.

The interface allows you to categorize contigs into separate bins (selection tool). Unhighlighted contigs are removed when the data is saved.

You can also evaluate taxonomy and duplicate single copy core genes.


You can also remove contigs. 

Spend some time to experiment in the browser.

$\color{#58A6FF}\textsf{\Large\&#x24D8;\kern{0.2cm}\normalsize Note}$
For refinement use clustering based on only differential coverage, and then only based on sequence composition in search for outliers.


#### Questions
* Does the quality of your ${\color{red}ARCHAEA}$ improve? 
* hint: look at completeness redundancy in the interface of anvio and submit info of before and after 
* Submit your output Figure

> INSERT\
> YOUR\
> ANSWER\
> HERE


## Coverage visualization

You should manually visualize your **ARCHAEA BINS** coverage.
 
**Do so by using anvio interactive interface.**

## Questions
  
* **how abundant are the archaea bins in the 3 samples? (relative abundance)**
* **you can also use anvi-inspect -p -c, anvi-script-get-coverage-from-bam or, anvi-profile-blitz. Please look up the help page for each of those commands and construct the appropriate command line

* https://anvio.org/help/main/artifacts/summary/
* 
 
> INSERT\
> YOUR\
> ANSWER\
> HERE


