#!/usr/bin/env perl

use strict;
use warnings;

use Pod::Usage;

use Getopt::Long;

my $fasta = "";
my $gff   = "";
my ($help, $man);

GetOptions(
    'i|in|fasta=s' => \$fasta,
    'gff=s'        => \$gff,
    'manual!'      => \$man,
    'help!'        => \$help
    ) || pod2usage( "Try '$0 --help' for more information." );

pod2usage( -exitval => 0, -verbose => 1 ) if $help;
pod2usage( -exitval => 0, -verbose => 2 ) if $man;

if ($fasta eq "" || $gff eq "")
{
    pod2usage( -exitval => 1, -verbose => 2 );
}


=pod

=head1 cpgoe

A single perl script calculating CpG o/e values according to Elango 2009.

=head2 VERSION

v0.1.0

=head2 SYNOPSIS

   ./cpgoe.pl

=head2 PARAMETER

=head3 C<--fasta|--in|-i>

A fasta file providing sequencing information.
Mandatory!

=head3 C<--gff|-g>

A gff file providing sequence annotation information. Only the fields:
chromosome, start, and stop are considered.  Mandatory!

=cut
