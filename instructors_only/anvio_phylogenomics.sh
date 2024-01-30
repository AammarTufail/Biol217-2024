#complete Phylogenomics workflow with Anvi'o

mkdir -p phylogenomics
cd phylogenomics
wget https://ndownloader.figshare.com/files/28715136 -O AnvioPhylogenomicsTutorialDataPack.tar.gz
# unpack it
tar -zxvf AnvioPhylogenomicsTutorialDataPack.tar.gz
rm -rf AnvioPhylogenomicsTutorialDataPack.tar.gz
# renmae the folder
mv AnvioPhylogenomicsTutorialDataPack genomes
# take a peak
ls genomes

cd genomes/distantly-related
# generate contigs.db
for i in `ls *fa | awk 'BEGIN{FS=".fa"}{print $1}'`
do
    anvi-gen-contigs-database -f $i.fa -o $i.db -T 12
    anvi-run-hmms -c $i.db
done
# download the already created file
wget https://goo.gl/XuezQF -O external-genomes.txt

anvi-db-info Salmonella_enterica_21170.db

anvi-get-sequences-for-hmm-hits --external-genomes external-genomes.txt \
                                --hmm-source Bacteria_71 \
                                --list-available-gene-names

anvi-get-sequences-for-hmm-hits --external-genomes external-genomes.txt \
                                -o concatenated-proteins.fa \
                                --hmm-source Bacteria_71 \
                                --gene-names Ribosomal_L1,Ribosomal_L2,Ribosomal_L3,Ribosomal_L4,Ribosomal_L5,Ribosomal_L6 \
                                --return-best-hit \
                                --get-aa-sequences \
                                --concatenate
anvi-gen-phylogenomic-tree -f concatenated-proteins.fa \
                           -o phylogenomic-tree.txt

wget https://goo.gl/UZDbC8 -O view.txt

anvi-interactive -p phylogenomic-profile.db \
                 -d view.txt \
                 -t phylogenomic-tree.txt \
                 --title "Phylogenomics Tutorial Example #2" \
                 --manual


# pangenome and phylogenomics

cd ../closely-related
ls
# generate contigs.db
for i in `ls *fa | awk 'BEGIN{FS=".fa"}{print $1}'`
do
    anvi-gen-contigs-database -f $i.fa -o $i.db
    anvi-run-hmms -c $i.db
done

wget https://goo.gl/DTM9sz -O external-genomes.txt

# get the gene sequences
anvi-get-sequences-for-hmm-hits --external-genomes external-genomes.txt \
                                -o concatenated-proteins.fa \
                                --hmm-source Bacteria_71 \
                                --gene-names Ribosomal_L1,Ribosomal_L2,Ribosomal_L3,Ribosomal_L4,Ribosomal_L5,Ribosomal_L6 \
                                --return-best-hit \
                                --get-aa-sequences \
                                --concatenate
                                
# compute the phylogenomic tree
anvi-gen-phylogenomic-tree -f concatenated-proteins.fa \
                           -o phylogenomic-tree.txt

# run the interactive interface
anvi-interactive -p phylogenomic-profile.db \
                 -t phylogenomic-tree.txt \
                 --title "Phylogenomics Tutorial Example #3" \
                 --manual


# pangenome+pangenome
 # generate anvi'o genomes storage
anvi-gen-genomes-storage -e external-genomes.txt \
                         -o Salmonella-GENOMES.db

# do the pangenomic analysis --this will take about
# 5 to 10 mins
anvi-pan-genome -g Salmonella-GENOMES.db \
                --project-name Salmonella \
                --num-threads 12

# display the pangenome
anvi-display-pan -g Salmonella-GENOMES.db \
                 -p Salmonella/Salmonella-PAN.db
