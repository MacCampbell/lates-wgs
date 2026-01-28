#!/bin/bash -l

#Setting up for 
#Requires a tab delimited list of paired end files with desired name (list, $1)
#SRR1613242_1.fastq.gz  SRR1613242_2.fastq.gz SRR1613242

#Requires a path to indexed reference genome (ref, $2)
# /home/maccamp/genomes/GCF021917145.1/GCF_021917145.1_fHypTra1_genomic.fna

#bash ../../101.2-do-align.sh to-align.txt /home/maccamp/genomes/GCF021917145.1/GCF_021917145.1_fHypTra1_genomic.fna
list=$1
ref=$2

wc=$(wc -l ${list} | awk '{print $1}')

x=1
while [ $x -le $wc ] 
do
        string="sed -n ${x}p ${list}" 
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1, $2, $3}')   
        set -- $var
        c1=$1
        c2=$2
        c3=$3

       echo "#!/bin/bash -l
       module load bwa/0.7.17
       bwa mem $ref ${c1} ${c2} | samtools view -Sb | samtools sort - -o ${c3}.sort.bam
       samtools index ${c3}.sort.bam
       samtools view -f 0x2 -b ${c3}.sort.bam | samtools rmdup - ${c3}.sort.flt.bam
       samtools index ${c3}.sort.flt.bam
       reads=\$(samtools view -c ${c3}.sort.bam)
       rmdup=\$(samtools view -c ${c3}.sort.flt.bam)
       depth=\$(samtools depth -a ${c3}.sort.flt.bam | awk '{sum+="\$3"} END {print sum/NR}' )
       echo \"${c3},\${reads},\${rmdup},\${depth}\"  > ${c3}.stats" > ${c3}.sh
       sbatch -p bmh -t 8-11:00:00 --mem=8G ${c3}.sh

       x=$(( $x + 1 ))

done


