#!/bin/bash
#SBATCH -o outputs/202/calc_pwst-%j.out
#SBATCH -t 48:00


mkdir outputs/202

#./1000_scripts/list_to_pwcomps.pl meta/poplist > 0011/pw.list

wc=$(wc -l poplists/pairwise-list.txt | awk '{print $1}')
x=1
while [ $x -le $wc ]
do
	string="sed -n ${x}p outputs/202/pairwise-list.txt"
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1,$2}')
	set -- $var
	pop1=$1
	pop2=$2

echo "#!/bin/bash
#SBATCH --job-name=fst${x}
#SBATCH -n 8
#SBATCH --nodes=1 
#SBATCH --partition=bigmemm
#SBATCH --mem=124GB 
#SBATCH --time=48:00:00
#SBATCH --output=outputs/202/${pop1}_${pop2}-%j.slurmout
#############################################

realSFS outputs/202/${pop1}.saf.idx outputs/202/${pop2}.saf.idx > outputs/202/${pop1}_${pop2}.2dsfs

#Rscript scripts/plot2DSFS_2D.R outputs/202/${pop1}_${pop2}.2dsfs \$(wc -l outputs/202/${pop1}.bamlist | awk '{print \$1}') \$(wc -l outputs/202/${pop2}.bamlist | awk '{print \$1}') $pop1 $pop2
#Rscript scripts/plot2dSFS.R outputs/202/${pop1}_${pop2}.2dsfs outputs/202/${pop1}_${pop2}.2dsfs.pdf ${pop1} ${pop2}

realSFS fst index outputs/202/${pop1}.saf.idx outputs/202/${pop2}.saf.idx -sfs outputs/202/${pop1}_${pop2}.2dsfs -fstout outputs/202/${pop1}_${pop2} 

realSFS fst stats outputs/202/${pop1}_${pop2}.fst.idx > outputs/202/${pop1}_-_${pop2}.fst.stats
" > fst_${pop1}_${pop2}.sh

sbatch fst_${pop1}_${pop2}.sh
rm fst_${pop1}_${pop2}.sh

x=$(( $x + 1 ))
done


#hold til complete
#grep "" outputs/202/*fst.stats | sed 's/.fst.stats:/      /' | sed 's:outputs/202/::' |  tr "_-_" "\t" | awk '{print $1"_"$2"_"$3"\t"$4"_"$5"_"$6"\t"$8}' > outputs/202/pwfst.all

#Changed by Mac to accomodate different delimiter
grep "" outputs/202/*fst.stats | sed 's/.fst.stats:/\t/' | sed 's:outputs/202/::' | perl -pe 's/_-_/\t/g' > outputs/202/pwfst.all

#1000_scripts/pwlist_to_matrix.pl 0011/pwfst.all > 0011/pwfst.fstmatrix
