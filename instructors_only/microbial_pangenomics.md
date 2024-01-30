# Anvio Microbial Pangenomics

```bash
mkdir -p microbial_pangenomics
cd microbial_pangenomics
wget https://ndownloader.figshare.com/files/28834476 -O Prochlorococcus_31_genomes.tar.gz
tar -zxvf Prochlorococcus_31_genomes.tar.gz
cd Prochlorococcus_31_genomes
anvi-migrate *.db --migrate-safely
anvi-gen-genomes-storage -e external-genomes.txt \
                         -o PROCHLORO-GENOMES.db

anvi-pan-genome -g PROCHLORO-GENOMES.db \
                --project-name "Prochlorococcus_Pan" \
                --output-dir PROCHLORO \
                --num-threads 10 \
                --minbit 0.5 \
                --mcl-inflation 10 \
                --use-ncbi-blast

anvi-import-misc-data layer-additional-data.txt \
                      -p PROCHLORO/Prochlorococcus_Pan-PAN.db \
                      --target-data-table layers

# anvi-display-pan -g PROCHLORO-GENOMES.db \
#                  -p PROCHLORO/Prochlorococcus_Pan-PAN.db

anvi-import-state -p PROCHLORO/Prochlorococcus_Pan-PAN.db \
                  --state pan-state.json \
                  --name default

anvi-compute-genome-similarity -e external-genomes.txt \
                 -o ANI \
                 -p PROCHLORO/Prochlorococcus_Pan-PAN.db \
                 -T 12

anvi-get-sequences-for-gene-clusters -p PROCHLORO/Prochlorococcus_Pan-PAN.db \
                                     -g PROCHLORO-GENOMES.db \
                                     --min-num-genomes-gene-cluster-occurs 31 \
                                     --max-num-genes-from-each-genome 1 \
                                     --concatenate-gene-clusters \
                                     --output-file PROCHLORO/Prochlorococcus-SCGs.fa

trimal -in PROCHLORO/Prochlorococcus-SCGs.fa \
       -out PROCHLORO/Prochlorococcus-SCGs-trimmed.fa \
       -gt 0.5 

iqtree -s PROCHLORO/Prochlorococcus-SCGs-trimmed.fa \
       -m WAG \
       -bb 1000 \
       -nt 8

echo -e "item_name\tdata_type\tdata_value" \
        > PROCHLORO/Prochlorococcus-phylogenomic-layer-order.txt

# add the newick tree as an order
echo -e "SCGs_Bayesian_Tree\tnewick\t`cat PROCHLORO/Prochlorococcus-SCGs-trimmed.fa.treefile`" \
        >> PROCHLORO/Prochlorococcus-phylogenomic-layer-order.txt

# import the layers order file
anvi-import-misc-data -p PROCHLORO/Prochlorococcus_Pan-PAN.db \
                      -t layer_orders PROCHLORO/Prochlorococcus-phylogenomic-layer-order.txt


anvi-display-pan -g PROCHLORO-GENOMES.db \
                 -p PROCHLORO/Prochlorococcus_Pan-PAN.db

```


https://merenlab.org/data/spiroplasma-pangenome/

# for bacteroides fragilis
https://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria
https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/007/065/GCA_000007065.1_ASM706v1/