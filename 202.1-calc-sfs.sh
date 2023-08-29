#!/bin/bash
#SBATCH -o outputs/202/calc-sfs-%j.out
#SBATCH -t 48:00


mkdir outputs/202
wc=$(wc -l poplists/poplist3.txt | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
	string="sed -n ${x}p poplists/poplist3.txt"
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1}')
	set -- $var
	pop=$1

echo "#!/bin/bash
#SBATCH --job-name=sfs${x}
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --partition=bigmemm
#SBATCH --mem=96G 
#SBATCH --time=48:00:00
#SBATCH --output=outputs/202/${pop}-%j.slurmout

##############################################

nInd=\$(wc -l poplists/${pop}.bamlist | awk '{print \$1}')
mInd=\$((\${nInd}/2))

#############################################
#Getting sites together if needed, e.g. maccamp@farm:~/spineflower/0009$ cat selection.sites | perl -pe 's/_/:/g' > sites


angsd -b poplists/${pop}.bamlist -anc genome/GCF_001640805.2_TLL_Latcal_v3_genomic.fna -ref genome/GCF_001640805.2_TLL_Latcal_v3_genomic.fna -rf genome/lates-lgs.txt  -out outputs/202/${pop} -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -baq 2 -GL 1 -doMajorMinor 1 -doMaf 1 -minInd $mInd -nind $nInd -minMapQ 10 -minQ 20 -doSaf 2 -nThreads 8 
realSFS outputs/202/${pop}.saf.idx > outputs/202/${pop}.sfs

#Rscript 1000_scripts/plotSFS.R 0011/${pop}.sfs
" > sfs_${pop}.sh

sbatch sfs_${pop}.sh
rm sfs_${pop}.sh

x=$(( $x + 1 ))
done

