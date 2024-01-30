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

anvi-display-pan -g PROCHLORO-GENOMES.db \
                 -p PROCHLORO/Prochlorococcus_Pan-PAN.db

```