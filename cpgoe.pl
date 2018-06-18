#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;

my $fasta = "";
my $gff   = "";

GetOptions(
    'i|in|fasta=s' => \$fasta,
    'gff=s'        => \$gff
    ) || die;
