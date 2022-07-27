module load qiime2/2019.1
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path SorgRIL1_manifest.csv --output-path SorgRIL1_paired-end-demux.qza --input-format PairedEndFastqManifestPhred33
qiime tools peek SorgRIL1_paired-end-demux.qza
qiime demux summarize --i-data SorgRIL1_paired-end-demux.qza --o-visualization SorgRIL1_paired-end-demux.qzv
qiime dada2 denoise-paired   --i-demultiplexed-seqs SorgRIL1_paired-end-demux.qza   --o-table SorgRIL1_table   --o-representative-sequences SorgRIL1_rep-seqs   --p-trim-left-f 0   --p-trim-left-r 0   --p-trunc-len-f 220   --p-trunc-len-r 160 --p-hashed-feature-ids --o-denoising-stats stats-dada2.qza --p-n-threads 0 --verbose
qiime feature-table summarize  --i-table SorgRIL1_table.qza  --o-visualization SorgRIL1_table.qzv  --m-sample-metadata-file SorgRIL1_metadata.tsv
qiime feature-table tabulate-seqs   --i-data SorgRIL1_rep-seqs.qza   --o-visualization SorgRIL1_rep-seqs.qzv
qiime alignment mafft   --i-sequences SorgRIL1_rep-seqs.qza   --o-alignment SorgRIL1_aligned-rep-seqs.qza --verbose --p-n-threads -0
qiime alignment mask   --i-alignment SorgRIL1_aligned-rep-seqs.qza   --o-masked-alignment SorgRIL1_masked-aligned-rep-seqs.qza --verbose
qiime phylogeny fasttree   --i-alignment SorgRIL1_masked-aligned-rep-seqs.qza   --o-tree SorgRIL1_unrooted-tree.qza --verbose --p-n-threads 1
qiime phylogeny midpoint-root   --i-tree SorgRIL1_unrooted-tree.qza   --o-rooted-tree SorgRIL1_rooted-tree.qza
qiime feature-classifier classify-sklearn   --i-classifier silva-132-99-515-806-nb-classifier.qza   --i-reads SorgRIL1_rep-seqs.qza   --o-classification SorgRIL1_silva-taxonomy.qza --p-n-jobs -2 --verbose
qiime tools export --input-path SorgRIL1_table.qza  --output-path exported
mv ./exported/feature-table.biom ./exported/SorgRIL1_OTU_Table.biom
qiime tools export  --input-path SorgRIL1_silva-taxonomy.qza  --output-path exported
mv ./exported/taxonomy.tsv ./exported/SorgRIL1_silva_taxonomy.tsv
qiime tools export --input-path SorgRIL1_rep-seqs.qza --output-path exported
mv ./exported/dna-sequences.fasta ./exported/SorgRIL1_rep_seqs.fasta
 qiime tools export --input-path SorgRIL1_rooted-tree.qza --output-path exported
mv ./exported/tree.nwk ./exported/SorgRIL1_tree.nwk
cd ./exported
cp SorgRIL1_silva_taxonomy.tsv SorgRIL1_silva_taxonomy_biom.tsv
sed -i '1d' SorgRIL1_silva_taxonomy_biom.tsv
sed  -i '1i #OTUID	taxonomy	confidence' SorgRIL1_silva_taxonomy_biom.tsv
biom add-metadata -i SorgRIL1_OTU_Table.biom -o SorgRIL1_OTU_Table_silva_taxonomy.biom --observation-metadata-fp SorgRIL1_silva_taxonomy_biom.tsv --sc-separated taxonomy
biom convert -i SorgRIL1_OTU_Table_silva_taxonomy.biom -o SorgRIL1_OTU_Table_silva_taxonomy.tsv --to-tsv --header-key taxonomy --output-metadata-id 'Consensus Lineage'
