# lates-wgs
Analysis of Lates WGS data   

WGS data and genome from Genbank


##  Genome

in ./genome/     (in .gitignore)      
`wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/640/805/GCF_001640805.2_TLL_Latcal_v3/GCF_001640805.2_TLL_Latcal_v3_genomic.fna.gz`     
`module load bwa/0.7.17`     
`bwa index GCF_001640805.2_TLL_Latcal_v3_genomic.fna.gz`     

Creating list of large contigs      
`gunzip -c GCF_001640805.2_TLL_Latcal_v3_genomic.fna.gz > GCF_001640805.2_TLL_Latcal_v3_genomic.fna`      
`samtools faidx GCF_001640805.2_TLL_Latcal_v3_genomic.fna`    

Note, mtDNA      
NC_007439.1     
`grep NC GCF_001640805.2_TLL_Latcal_v3_genomic.fna.fai  | grep -v "NC_007439.1" | cut -f 1 > lates-lgs.txt`     

This has 24 LGs
## WGS   
61 samples under PRJNA311498     
Illumina HiSeq 2500      
PE 100 bp reads     
Download, align, in 100-series     