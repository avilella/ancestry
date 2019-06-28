#!/usr/bin/perl
use strict;
use warnings;
use IPC::Open3 'open3'; $SIG{CHLD} = 'IGNORE';
use Symbol 'gensym';
use Getopt::Long;

##INFO=<ID=ASW,Number=A,Type=String,Description="Allele frequency in Americans of African Ancestry in SW USA population">
##INFO=<ID=CEU,Number=A,Type=String,Description="Allele frequency in Utah Residents (CEPH) with Northern and Western Ancestry population">
##INFO=<ID=CHB,Number=A,Type=String,Description="Allele frequency in Han Chinese in Bejing, China population">
##INFO=<ID=CHD,Number=A,Type=String,Description="Allele frequency in Chinese in Metropolitan Denver, Colorado population">
##INFO=<ID=CHS,Number=A,Type=String,Description="Allele frequency in Southern Han Chinese population">
##INFO=<ID=CLM,Number=A,Type=String,Description="Allele frequency in Colombians from Medellin, Colombia population">
##INFO=<ID=FIN,Number=A,Type=String,Description="Allele frequency in Finnish in Finland population">
##INFO=<ID=GBR,Number=A,Type=String,Description="Allele frequency in British in England and Scotland population">
##INFO=<ID=GIH,Number=A,Type=String,Description="Allele frequency in Gujarati Indian from Houston, Texas population">
##INFO=<ID=IBS,Number=A,Type=String,Description="Allele frequency in Iberian Population in Spain population">
##INFO=<ID=JPT,Number=A,Type=String,Description="Allele frequency in Japanese in Tokyo, Japan population">
##INFO=<ID=LWK,Number=A,Type=String,Description="Allele frequency in Luhya in Webuye, Kenya population">
##INFO=<ID=MKK,Number=A,Type=String,Description="Allele frequency in Maasai in Kinyawa, Kenya population">
##INFO=<ID=MXL,Number=A,Type=String,Description="Allele frequency in Mexican Ancestry from Los Angeles USA population">
##INFO=<ID=PUR,Number=A,Type=String,Description="Allele frequency in Puerto Ricans from Puerto Rico population">
##INFO=<ID=TSI,Number=A,Type=String,Description="Allele frequency in Toscani in Italia population">
##INFO=<ID=YRI,Number=A,Type=String,Description="Not provided in original VCF header">

# #chrom position rsid A1 A2 YRI CHB CHD TSI MKK LWK CEU JPT
# chr1 631495 rs2185539 T C 0.00343 0.00182 0.00229 0.00245 0.21240 0.00227 0.00223 0.00221


my $pops = "ASW:CEU:CHB:CHD:CHS:CLM:FIN:GBR:GIH:IBS:JPT:LWK:MKK:MXL:PUR:TSI:YRI";
my $self = bless {};
my $inputfile;
my $debug; my $verbose;
my $iter = 10000;
GetOptions(
	   'i|input|inputfile:s' => \$inputfile,
           'debug' => \$debug,
           'pops:s' => \$pops,
           'iter:s' => \$iter,
          'verbose' => \$verbose,
          );

my @pops = split(":",$pops);
foreach my $pop (@pops) {
  $self->{pop}{$pop} = 1;
}

# HEADER
print "#chrom position rsid A1 A2 " . join(" ",@pops) . "\n";

my $cmd = "gunzip -c $inputfile ";
open(my $fh, "-|","$cmd") or die $!;
my $count = 0;
while (<$fh>) {
  my $line = $_; chomp $line;
  if ($line =~ /^##/) {
    print "$line\n" if ($verbose);
    next;
  }
  if ($line =~ /^#/) {
    print "$line\n" if ($verbose);
    next;
  }
  my ($CHROM,$POS,$ID,$REF,$ALT,$QUAL,$FILTER,$INFO) = split("\t",$line);
  my @kvs = split("\;",$INFO);
  if (scalar(@kvs) != 22) {
    next;
  }
  my @freqs;
  foreach my $entry (@kvs) {
    print STDERR "# $entry\n" if ($verbose);
    my ($k,$v,@rest) = split("\=",$entry);
    if (defined ($self->{pop}{$k})) {
      my $alt_freq = $rest[-1];
      $alt_freq =~ s/\}$//;
      push @freqs, $alt_freq;
    }
  }
  print "$CHROM $POS $ID $ALT $REF " . join(" ",@freqs) . "\n";
  $DB::single=1;1;#??
  print STDERR "[$count]\n" if ($count % $iter == 0); $count++;
}


