#!/usr/bin/env perl

use strict;
use warnings;

use Pod::Usage;

use Getopt::Long;
use Bio::SeqIO;

my $fasta = "";
my $gff   = "";
my $gfftype = "mRNA";
my ($help, $man);

GetOptions(
    'i|in|fasta=s' => \$fasta,
    'gff=s'        => \$gff,
    'type=s'       => \$gfftype,
    'manual!'      => \$man,
    'help!'        => \$help
    ) || pod2usage( "Try '$0 --help' for more information." );

pod2usage( -exitval => 0, -verbose => 1 ) if $help;
pod2usage( -exitval => 0, -verbose => 2 ) if $man;

if ($fasta eq "" || $gff eq "")
{
    pod2usage( -exitval => 1, -verbose => 2 );
}

my $gffcontent = {};

open(FH, "<", $gff) || die "Unable to open '$gff': $!\n";
while(<FH>)
{
    chomp;

    my ($chr, undef, $type, $start, $stop, undef, $strand) = split(/\t/);

    if (defined $type && $type eq $gfftype)
    {
	push(@{$gffcontent->{$chr}}, { chr => $chr, type => $type, start => $start, stop => $stop, strand => $strand });
    }
}
close(FH) || die "Unable to close '$gff': $!\n";

# get the sequence file
my $seqio_object = Bio::SeqIO->new(-file => $fasta);

# print a header line
print join("\t", qw(#chr start stop strand num_c prob_c num_g prob_g num_cg prob_cg cpgoe)), "\n";

while (my $seq_object = $seqio_object->next_seq)
{
    if (exists $gffcontent->{$seq_object->id()})
    {
	foreach my $item (@{$gffcontent->{$seq_object->id()}})
	{
	    my $seq = substr($seq_object->seq(), $item->{start}, ($item->{stop}-$item->{start}+1));

	    if ($item->{strand} eq "-")
	    {
		$seq = reverse $seq;
		$seq =~ tr/ACGTacgt/TGCAtgca/;
	    }
	    my $num_c = $seq =~ tr/Cc/Cc/;
	    my $num_g = $seq =~ tr/Gg/Gg/;

	    my $len = length($seq);

	    my %dinucl_comp = ();
	    for(my $i=0; $i<$len-1; $i++)
	    {
		my $dinucl = substr($seq, $i, 2);
		$dinucl_comp{lc($dinucl)}++;
	    }

	    my $prob_c = $num_c/$len;
	    my $prob_g = $num_g/$len;

	    my $num_cg = 0;
	    $num_cg = $dinucl_comp{gc} if (exists $dinucl_comp{gc});
	    my $prob_cg = $num_cg/$len;

	    my $cpgoe = $prob_cg/($prob_c*$prob_g);

	    print join("\t", $seq_object->id(), $item->{start}, $item->{stop}, $item->{strand}, $num_c, $prob_c, $num_g, $prob_g, $num_cg, $prob_cg, $cpgoe), "\n";
	}
    }
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
