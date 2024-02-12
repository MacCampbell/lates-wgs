#! /usr/bin/perl -w

#The goal of this program is to read in a list of SNPs that are fixed for "A" type Omy05 inds,
#and "R" type individuals
#omy05	1	AA/RR
#omy05	2	AA/RR
#omy05	3	AA/RR

#then to read in several individual genotyps
#omy05	1	AA	AA	AR	AR	RR
#omy05	2	AA	AA	AR	AR	RR
#omy05	3	AA	AA	AR	AR	RR

#prepare genotype file to remove that one empty column, e.g. 
#$gunzip -c genotypes.geno.gz | cut -f 1-20 > out.geno

#Need to remove the omy05 from genotype file
#gunzip -c outputs/100/test3.geno.gz | grep omy05 | cut -f 2-48 > outputs/100/test3.omy05.geno
#gunzip -c outputs/100/test4-maf05p.geno.gz | grep omy05 | cut -f 2-50 > outputs/100/test4-maf05p.omy05.geno
#usage

#./105-omy05-haplotyper.pl genotypes.txt  genosToTest.txt bamlist
#./105-omy05-haplotyper.pl omy05/biallelic-diagnostic-omy05.txt outputs/100/test3.omy05.geno bamlists/test3.bamlist 2>err;

#Saving to file:
#$ ./105-omy05-haplotyper.pl omy05/biallelic-diagnostic-omy05.txt outputs/100/test3.omy05.geno bamlists/test3.bamlist >omy05/test3-omy05-genotypes.txt 2>err;

#genosToTest.txt a list of genos to test!
#12	AA	GG
#14	CC	TT
#cut -f 2-20  genoBases.txt > genosToTest.txt 

#finds sites within genotypes.txt, defines AA/RR types, and then checks out genos to test!
my $sep="\t";
my $genoFile=shift;
my $testFile=shift;
my $bamlist=shift;
my @samples;
# I should probably program a way to generalize this length of the bamlist.
my $testSize=190;
my %sites;

open (INFILE, "<$genoFile") || die "Can't open $genoFile\n";
	while(<INFILE>) {
    chomp;
    next if (/^$/);            # skip empty line
	my @line = split(/\t/, $_);
	$sites{$line[0]}=$line[1].$sep.$line[2];

}	

close(INFILE);

print "samples\tNumberAA\tNumberAR\tNumberRR\n";
for (my $i=1; $i<=$testSize; $i++) {
my $Agenos=0;
my $Rgenos=0;
my $ARgenos=0;

my %tests;
open (INFILE, "<$testFile") || die "Can't open $testFile\n";
	while(<INFILE>) {
    chomp;
    next if (/^$/);            # skip empty line
	my @line = split(/\t/, $_);
	$tests{$line[0]}=$line[$i];

}	

close(INFILE);
#Read in bamfile so we can assign omy05 genoyptes to it:
open (INFILE, "<$bamlist") || die "Can't open $bamlist\n";
	while(<INFILE>) {
    chomp;
    next if (/^$/);            # skip empty line
	my $line=$_;
	push(@samples, $line);

}	

close(INFILE);


my @keys = keys %sites;
    for my $key (@keys) {
      #get AA/RR refs
      my @a= split($sep, $sites{$key});
      my @aa=split(//, $a[0]);
      my @rr=split(//, $a[1]);
      my $a=$aa[0];
      my $r=$rr[0];
      if (exists $tests{$key}) {
      my @genos=split(//, $tests{$key});
      my $aCntr;
      my $rCntr;
      if (($a eq $genos[0]) && ($a eq $genos[1])) {
      	$aCntr+=2;
      	$rCntr=0;
      	$Agenos++;
      } elsif (($r eq $genos[0]) && ($r eq $genos[1])) {
        $aCntr=0;
        $rCntr+=2;
        $Rgenos++;
      } elsif ((($a eq $genos[0]) && ($r eq $genos[1])) || (($r eq $genos[0]) && ($a eq $genos[1]))) {
      	$aCntr++; $rCntr++;
      	$ARgenos++;
      } elsif ( ($genos[0] eq "N") && ($genos[1] eq "N")) {
      $aCntr=0;
      $rCntr=0;
      } else {
      print STDERR "you have a snp at site $key that isn't as decisive as your think\n";
      	$aCntr="NA";
      	$rCntr="NA";
      }
      
      }
      
      
        #print "The sites of '$fruit' is $tests{$fruit}\n";
 }


print "$samples[$i-1]\t$Agenos\t$ARgenos\t$Rgenos\n";

}


#print "\n";


