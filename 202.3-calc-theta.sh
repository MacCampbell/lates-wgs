#!/bin/bash
#SBATCH -o outputs/202/calc-sfs-%j.out
#SBATCH -t 48:00


mkdir outputs/202
wc=$(wc -l poplists/lineage-list.txt | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
	string="sed -n ${x}p poplists/lineage-list.txt"
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1}')
	set -- $var
	pop=$1

echo "#!/bin/bash
#SBATCH --job-name=sfs${x}
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --partition=bigmemh
#SBATCH --mem=124G 
#SBATCH --time=24:00:00
#SBATCH --output=outputs/202/${pop}-%j.slurmout

##############################################

nInd=\$(wc -l poplists/${pop}.bamlist | awk '{print \$1}')
mInd=\$((\${nInd}/2))

#############################################
#Getting sites together if needed, e.g. maccamp@farm:~/spineflower/0009$ cat selection.sites | perl -pe 's/_/:/g' > sites
#Skipping this part to calch sfs as already tone
###angsd -b poplists/${pop}.bamlist -anc genome/GCF_001640805.2_TLL_Latcal_v3_genomic.fna -ref genome/GCF_001640805.2_TLL_Latcal_v3_genomic.fna -rf genome/lates-lgs.txt  -out outputs/202/${pop} -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -baq 2 -GL 1 -doMajorMinor 1 -doMaf 1 -minInd $mInd -nind $nInd -minMapQ 10 -minQ 20 -doSaf 2 -nThreads 8 
###realSFS outputs/202/${pop}.saf.idx > outputs/202/${pop}.sfs

realSFS saf2theta outputs/202/${pop}.saf.idx -outname outputs/202/${pop}-thetas -sfs outputs/202/${pop}.sfs -fold 1
thetaStat do_stat outputs/202/${pop}-thetas.thetas.idx -outnames outputs/202/${pop}-thetas-stat

#Rscript 1000_scripts/plotSFS.R 0011/${pop}.sfs
" > sfs_${pop}.sh

sbatch sfs_${pop}.sh
rm sfs_${pop}.sh

x=$(( $x + 1 ))
done

#summarize
#cat poplists/poplist.txt | while read pop; do echo $pop; awk 'NR == 1 {print "Population" "\t" $0 ; next;}{print FILENAME "\t" $0 ;}' outputs/202/$pop-thetas-stat.pestPG > outputs/202/$pop-diversity.stats; done;

