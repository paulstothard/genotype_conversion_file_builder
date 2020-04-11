#!/usr/bin/env perl
#Written by Paul Stothard
#stothard@ualberta.ca
#20200328

use warnings;
use strict;
use Data::Dumper;
use File::Temp;
use Getopt::Long;

#initialize options
my %options = (
    blast      => undef,
    manifest   => undef,
    position   => undef,
    conversion => undef,
    wide       => undef,
    alignment  => undef,
    info       => undef,
    help       => undef
);

#get command line options
GetOptions(
    'b|blast=s'      => \$options{blast},
    'm|manifest=s'   => \$options{manifest},
    'p|position=s'   => \$options{position},
    'c|conversion=s' => \$options{conversion},
    'w|wide=s'       => \$options{wide},
    'a|alignment=s'  => \$options{alignment},
    'i|info=s@{,}'   => \$options{info},
    'h|help'         => \$options{help}
);

if ( defined( $options{help} ) ) {
    print_usage();
    exit(0);
}

if (   !( defined( $options{blast} ) )
    or !( defined( $options{manifest} ) )
    or !( defined( $options{position} ) )
    or !( defined( $options{conversion} ) ) )
{
    print_usage();
    exit(1);
}

$options{alignment_padding} = 12;

my $manifest_array_of_hashes = csv_to_array_of_hashes( $options{manifest} );
my $blast_array_of_hashes    = csv_to_array_of_hashes( $options{blast} );

my %blast_hash_of_hashes = ();
foreach my $blast_entry ( @{$blast_array_of_hashes} ) {
    $blast_hash_of_hashes{ $blast_entry->{query_id} } = $blast_entry;
}

my @output = ();
foreach my $manifest_entry ( @{$manifest_array_of_hashes} ) {
    if (   ( defined( $manifest_entry->{SourceSeq} ) )
        && ( $manifest_entry->{SourceSeq} eq '.' ) )
    {
        next;
    }
    if (   ( defined( $manifest_entry->{Affy_SNP_ID} ) )
        && ( $manifest_entry->{Affy_SNP_ID} eq '.' ) )
    {
        next;
    }
    my $genotype_conversion_hash =
      get_genotype_conversion_hash( \%options, $manifest_entry,
        \%blast_hash_of_hashes );

    push( @output, $genotype_conversion_hash );
}

write_output_files( \%options, \@output );

sub write_output_files {
    my $options = shift;
    my $output  = shift;

    my $time  = get_time();
    my $delim = ',';

    #write position file
    open( my $POSFILE, '>', $options->{position} )
      or die("Cannot open file '$options->{position}': $!");

    if ( defined( $options->{info} ) ) {
        foreach my $info ( @{ $options->{info} } ) {
            print $POSFILE "#$info\n";
        }
    }
    print $POSFILE "#\n";
    print $POSFILE "#Variant position file generated on " . $time . ".\n";
    print $POSFILE
"#Using genotype_conversion_file_builder, written by Paul Stothard, stothard\@ualberta.ca.\n";
    print $POSFILE "#\n";

    print $POSFILE join $delim,
      @{
        [
            'marker_name', 'alt_marker_name',
            'chromosome',  'position',
            'VCF_REF',     'VCF_ALT'
        ]
      };

    print $POSFILE "\n";

    foreach my $variant ( @{$output} ) {
        my $values = get_column_values(
            $delim, $variant,
            [
                'Name',             'Alternative_Name',
                'BLAST_chromosome', 'BLAST_position',
                'VCF_REF',          'VCF_ALT'
            ]
        );
        print $POSFILE join $delim, @{$values};
        print $POSFILE "\n";
    }
    close($POSFILE) or die("Cannot close file : $!");

    #write conversion file
    open( my $CONFILE, '>', $options->{conversion} )
      or die("Cannot open file '$options->{conversion}': $!");

    if ( defined( $options->{info} ) ) {
        foreach my $info ( @{ $options->{info} } ) {
            print $CONFILE "#$info\n";
        }
    }
    print $CONFILE "#\n";
    print $CONFILE "#Genotype conversion file generated on " . $time . ".\n";
    print $CONFILE
"#Using genotype_conversion_file_builder, written by Paul Stothard, stothard\@ualberta.ca.\n";
    print $CONFILE "#\n";

    print $CONFILE join $delim,
      @{
        [
            'marker_name', 'alt_marker_name',
            'AB',          'TOP',
            'FORWARD',     'DESIGN',
            'PLUS',        'VCF'
        ]
      };

    print $CONFILE "\n";

    foreach my $variant ( @{$output} ) {
        my $values_A = get_column_values(
            $delim, $variant,
            [
                'Name',      'Alternative_Name',
                'A',         'TOP_A',
                'FORWARD_A', 'DESIGN_A',
                'PLUS_A',    'VCF_A'
            ]
        );
        print $CONFILE join $delim, @{$values_A};
        print $CONFILE "\n";

        my $values_B = get_column_values(
            $delim, $variant,
            [
                'Name',      'Alternative_Name',
                'B',         'TOP_B',
                'FORWARD_B', 'DESIGN_B',
                'PLUS_B',    'VCF_B'
            ]
        );
        print $CONFILE join $delim, @{$values_B};
        print $CONFILE "\n";
    }

    close($CONFILE) or die("Cannot close file : $!");

    if ( defined( $options->{wide} ) ) {

        #write wide file
        open( my $WIDEFILE, '>', $options->{wide} )
          or die("Cannot open file '$options->{wide}': $!");

        if ( defined( $options->{info} ) ) {
            foreach my $info ( @{ $options->{info} } ) {
                print $WIDEFILE "#$info\n";
            }
        }
        print $WIDEFILE "#\n";
        print $WIDEFILE "#Wide file generated on " . $time . ".\n";
        print $WIDEFILE
"#Using genotype_conversion_file_builder, written by Paul Stothard, stothard\@ualberta.ca.\n";
        print $WIDEFILE "#\n";

        print $WIDEFILE join $delim,
          @{
            [
                'marker_name', 'alt_marker_name',
                'chromosome',  'position',
                'VCF_REF',     'VCF_ALT',
                'AB_A',        'AB_B',
                'TOP_A',       'TOP_B',
                'FORWARD_A',   'FORWARD_B',
                'DESIGN_A',    'DESIGN_B',
                'PLUS_A',      'PLUS_B',
                'VCF_A',       'VCF_B'
            ]
          };

        print $WIDEFILE "\n";

        foreach my $variant ( @{$output} ) {
            my $values = get_column_values(
                $delim, $variant,
                [
                    'Name',             'Alternative_Name',
                    'BLAST_chromosome', 'BLAST_position',
                    'VCF_REF',          'VCF_ALT',
                    'A',                'B',
                    'TOP_A',            'TOP_B',
                    'FORWARD_A',        'FORWARD_B',
                    'DESIGN_A',         'DESIGN_B',
                    'PLUS_A',           'PLUS_B',
                    'VCF_A',            'VCF_B'
                ]
            );
            print $WIDEFILE join $delim, @{$values};
            print $WIDEFILE "\n";
        }
        close($WIDEFILE) or die("Cannot close file : $!");

    }

    if ( defined( $options->{alignment} ) ) {

        #write alignment file
        open( my $ALIGNFILE, '>', $options->{alignment} )
          or die("Cannot open file '$options->{alignment}': $!");

        if ( defined( $options->{info} ) ) {
            foreach my $info ( @{ $options->{info} } ) {
                print $ALIGNFILE "#$info\n";
            }
        }
        print $ALIGNFILE "#\n";
        print $ALIGNFILE "#Alignment file generated on " . $time . ".\n";
        print $ALIGNFILE
"#Using genotype_conversion_file_builder, written by Paul Stothard, stothard\@ualberta.ca.\n";
        print $ALIGNFILE "#\n";

        foreach my $variant ( @{$output} ) {
            my $values = get_column_values( $delim, $variant,
                [ 'Name', 'Alternative_Name' ] );

            print $ALIGNFILE
"========================================================================================\n";
            print $ALIGNFILE join $delim, @{$values};
            print $ALIGNFILE "\n";

            if ( defined( $variant->{alignment} ) ) {
                my $alignment = $variant->{alignment};
                $alignment =~ s/\s+$//g;
                print $ALIGNFILE $alignment . "\n";
            }
            else {
                print $ALIGNFILE "No alignment obtained." . "\n";
            }
        }
        close($ALIGNFILE) or die("Cannot close file : $!");

    }

}

sub get_column_values {
    my $delim   = shift;
    my $variant = shift;
    my $keys    = shift;
    my @values  = ();

    foreach my $key ( @{$keys} ) {
        if ( ( defined( $variant->{$key} ) ) && ( $variant->{$key} ne '?' ) ) {
            my $value = $variant->{$key};
            $value =~ s/$delim//g;
            push @values, $value;
        }
        else {
            push @values, '';
        }
    }
    return \@values;
}

sub get_genotype_conversion_hash {
    my $options              = shift;
    my $manifest_entry       = shift;
    my $blast_hash_of_hashes = shift;
    my %output_hash          = (
        'Name'                            => undef,
        'Alternative_Name'                => undef,
        'SNP'                             => undef,
        'BLAST_chromosome'                => undef,
        'BLAST_position'                  => undef,
        'BLAST_strand'                    => undef,
        'Reference_allele_forward_strand' => undef,
        'DESIGN_A'                        => undef,
        'DESIGN_B'                        => undef,
        'FORWARD_A'                       => undef,
        'FORWARD_B'                       => undef,
        'PLUS_A'                          => undef,
        'PLUS_B'                          => undef,
        'TOP_A'                           => undef,
        'TOP_B'                           => undef,
        'BOT_A'                           => undef,
        'BOT_B'                           => undef,
        'AB_A'                            => undef,
        'AB_B'                            => undef,
        'SourceSeq_A'                     => undef,
        'SourceSeq_B'                     => undef,
        'Probe_to_SourceSeq'              => undef,
        'IlmnID_TBPM_FR'                  => undef,
        'is_indel'                        => undef,
        'is_snp'                          => undef,
        'flanking'                        => undef,
        'REFERENCE_A'                     => undef,
        'REFERENCE_B'                     => undef,
        'probe_sequence'                  => undef,
        'first_allele_from_flank'         => undef,
        'second_allele_from_flank'        => undef,
        'VCF_REF'                         => undef,
        'VCF_ALT'                         => undef,
        'VCF_A'                           => undef,
        'VCF_B'                           => undef,
        'A'                               => 'A',
        'B'                               => 'B',
        'alignment'                       => undef
    );

    if ( defined( $manifest_entry->{IlmnID} ) ) {
        return populate_conversion_hash_illumina( $options, $manifest_entry,
            $blast_hash_of_hashes, \%output_hash );
    }
    elsif ( defined( $manifest_entry->{Affy_SNP_ID} ) ) {
        return populate_conversion_hash_affymetrix( $options, $manifest_entry,
            $blast_hash_of_hashes, \%output_hash );
    }

    return \%output_hash;
}

sub populate_conversion_hash_illumina {
    my $options              = shift;
    my $manifest_entry       = shift;
    my $blast_hash_of_hashes = shift;
    my $output_hash          = shift;

    $output_hash->{Name}             = $manifest_entry->{Name};
    $output_hash->{Alternative_Name} = $manifest_entry->{IlmnID};
    $output_hash->{SNP}              = $manifest_entry->{SNP};

    $output_hash->{flanking} = $manifest_entry->{SourceSeq};

    if ( $output_hash->{flanking} =~ m/\[([^\/]*)\/([^\/]*)\]/ ) {
        $output_hash->{first_allele_from_flank}  = $1;
        $output_hash->{second_allele_from_flank} = $2;
    }

    $output_hash->{probe_sequence} = $manifest_entry->{AlleleA_ProbeSeq};

    #If AlleleA_ProbSeq and AlleleB_ProbSeq are defined then last
    #base overlaps with allele site.
    #If only AlleleA_ProbSeq defined then last base is next to
    #allele site (state determined by single-base extension).
    #The following removes overlapping base to simplify viewing of alignments.
    if (   ( $manifest_entry->{AlleleA_ProbeSeq} ne '.' )
        && ( $manifest_entry->{AlleleB_ProbeSeq} ne '.' ) )
    {
        $output_hash->{probe_sequence} = substr $output_hash->{probe_sequence},
          0, ( length( $output_hash->{probe_sequence} ) - 1 );
    }

    #A and B allele
    if ( $manifest_entry->{SNP} =~ m/\[([^\]]+)\]/ ) {
        my $allele_string = $1;
        my @alleles = split( /\//, $allele_string );
        $output_hash->{AB_A} = $alleles[0];
        $output_hash->{AB_B} = $alleles[1];
    }
    else {
        die("couldn't parse alleles from $manifest_entry->{SNP}");
    }

    #need IlmnID top / bottom / plus / minus - forward / reverse designation
    #ARS-BFGL-BAC-10172-0_T_F_1511662585
    if ( $manifest_entry->{IlmnID} =~
        m/\Q$manifest_entry->{Name}\E\-\d_([TBMP]_[FR])/ )
    {
        $output_hash->{IlmnID_TBPM_FR} = $1;
    }
    elsif ( $manifest_entry->{IlmnID} =~ m/([TBMP]_[FR])_\d+$/ ) {
        $output_hash->{IlmnID_TBPM_FR} = $1;
    }
    elsif ( $manifest_entry->{IlmnID} =~ m/([TBMP]_[FR])/ ) {
        $output_hash->{IlmnID_TBPM_FR} = $1;
    }
    else {
        die("couldn't parse 'IlmnID_TBPM_FR' from $manifest_entry->{IlmnID}");
    }

    if ( $manifest_entry->{SourceStrand} eq $manifest_entry->{IlmnStrand} ) {
        $output_hash->{Probe_to_SourceSeq} = 'FORWARD';
    }
    elsif ( $manifest_entry->{SourceStrand} ne $manifest_entry->{IlmnStrand} ) {
        $output_hash->{Probe_to_SourceSeq} = 'REVERSE';
    }

    #next do BLAST-based values
    my $basic_blast_results =
      get_basic_blast_results( $options, $blast_hash_of_hashes, $output_hash );

    $output_hash->{BLAST_chromosome} = $basic_blast_results->{chromosome};
    $output_hash->{BLAST_strand}     = $basic_blast_results->{strand};
    $output_hash->{BLAST_position}   = $basic_blast_results->{position};
    $output_hash->{Reference_allele_forward_strand} =
      $basic_blast_results->{reference_base_forward_strand};
    $output_hash->{VCF_REF}   = $basic_blast_results->{VCF_REF};
    $output_hash->{VCF_ALT}   = $basic_blast_results->{VCF_ALT};
    $output_hash->{alignment} = $basic_blast_results->{alignment};

    if ( ( $output_hash->{AB_A} eq 'I' ) || ( $output_hash->{AB_A} eq 'D' ) ) {
        $output_hash->{is_indel} = 1;
        populate_conversion_hash_illumina_indel( $options, $manifest_entry,
            $output_hash );
    }
    else {
        $output_hash->{is_snp} = 1;
        populate_conversion_hash_illumina_snp( $options, $manifest_entry,
            $output_hash );
    }
    set_vcf_a_and_b($output_hash);
    return $output_hash;
}

sub populate_conversion_hash_illumina_snp {
    my $options        = shift;
    my $manifest_entry = shift;
    my $output_hash    = shift;

    if ( $manifest_entry->{IlmnStrand} eq 'TOP' ) {
        $output_hash->{TOP_A} = $output_hash->{AB_A};
        $output_hash->{TOP_B} = $output_hash->{AB_B};
        $output_hash->{BOT_A} = rc( $output_hash->{AB_A} );
        $output_hash->{BOT_B} = rc( $output_hash->{AB_B} );
    }
    elsif ( $manifest_entry->{IlmnStrand} eq 'BOT' ) {
        $output_hash->{TOP_A} = rc( $output_hash->{AB_A} );
        $output_hash->{TOP_B} = rc( $output_hash->{AB_B} );
        $output_hash->{BOT_A} = $output_hash->{AB_A};
        $output_hash->{BOT_B} = $output_hash->{AB_B};
    }

    if ( $manifest_entry->{SourceStrand} eq 'TOP' ) {
        $output_hash->{SourceSeq_A} = $output_hash->{TOP_A};
        $output_hash->{SourceSeq_B} = $output_hash->{TOP_B};
    }
    elsif ( $manifest_entry->{SourceStrand} eq 'BOT' ) {
        $output_hash->{SourceSeq_A} = $output_hash->{BOT_A};
        $output_hash->{SourceSeq_B} = $output_hash->{BOT_B};
    }

    if ( $manifest_entry->{SourceStrand} eq $manifest_entry->{IlmnStrand} ) {
        $output_hash->{DESIGN_A} = $output_hash->{SourceSeq_A};
        $output_hash->{DESIGN_B} = $output_hash->{SourceSeq_B};
    }
    elsif ( $manifest_entry->{SourceStrand} ne $manifest_entry->{IlmnStrand} ) {
        $output_hash->{DESIGN_A} = rc( $output_hash->{SourceSeq_A} );
        $output_hash->{DESIGN_B} = rc( $output_hash->{SourceSeq_B} );

    }

    if (   ( $manifest_entry->{IlmnStrand} eq 'TOP' )
        && ( $output_hash->{IlmnID_TBPM_FR} eq 'T_F' ) )
    {
        $output_hash->{FORWARD_A} = $output_hash->{TOP_A};
        $output_hash->{FORWARD_B} = $output_hash->{TOP_B};
    }
    elsif (( $manifest_entry->{IlmnStrand} eq 'TOP' )
        && ( $output_hash->{IlmnID_TBPM_FR} eq 'T_R' ) )
    {
        $output_hash->{FORWARD_A} = $output_hash->{BOT_A};
        $output_hash->{FORWARD_B} = $output_hash->{BOT_B};
    }
    elsif (( $manifest_entry->{IlmnStrand} eq 'BOT' )
        && ( $output_hash->{IlmnID_TBPM_FR} eq 'B_F' ) )
    {
        $output_hash->{FORWARD_A} = $output_hash->{BOT_A};
        $output_hash->{FORWARD_B} = $output_hash->{BOT_B};
    }
    elsif (( $manifest_entry->{IlmnStrand} eq 'BOT' )
        && ( $output_hash->{IlmnID_TBPM_FR} eq 'B_R' ) )
    {
        $output_hash->{FORWARD_A} = $output_hash->{TOP_A};
        $output_hash->{FORWARD_B} = $output_hash->{TOP_B};
    }

    #use the BLAST results to determine PLUS_A and PLUS_B
    if ( defined( $output_hash->{BLAST_strand} ) ) {

        if ( $output_hash->{BLAST_strand} eq 'plus' ) {
            $output_hash->{PLUS_A} = $output_hash->{SourceSeq_A};
            $output_hash->{PLUS_B} = $output_hash->{SourceSeq_B};
        }
        elsif ( $output_hash->{BLAST_strand} eq 'minus' ) {
            $output_hash->{PLUS_A} = rc( $output_hash->{SourceSeq_A} );
            $output_hash->{PLUS_B} = rc( $output_hash->{SourceSeq_B} );
        }
    }
}

sub populate_conversion_hash_illumina_indel {
    my $options        = shift;
    my $manifest_entry = shift;
    my $output_hash    = shift;

    #an insertion is an insertion regardless of strand
    $output_hash->{TOP_A} = $output_hash->{AB_A};
    $output_hash->{TOP_B} = $output_hash->{AB_B};
    $output_hash->{BOT_A} = $output_hash->{AB_A};
    $output_hash->{BOT_B} = $output_hash->{AB_B};

    $output_hash->{SourceSeq_A} = $output_hash->{AB_A};
    $output_hash->{SourceSeq_B} = $output_hash->{AB_B};

    $output_hash->{DESIGN_A} = $output_hash->{AB_A};
    $output_hash->{DESIGN_B} = $output_hash->{AB_B};

    $output_hash->{PLUS_A}    = $output_hash->{AB_A};
    $output_hash->{PLUS_B}    = $output_hash->{AB_B};
    $output_hash->{FORWARD_A} = $output_hash->{AB_A};
    $output_hash->{FORWARD_B} = $output_hash->{AB_B};

}

sub populate_conversion_hash_affymetrix {
    my $options              = shift;
    my $manifest_entry       = shift;
    my $blast_hash_of_hashes = shift;
    my $output_hash          = shift;

    $output_hash->{Name}             = $manifest_entry->{Probe_Set_ID};
    $output_hash->{Alternative_Name} = $manifest_entry->{Affy_SNP_ID};
    $output_hash->{SNP} =
        '['
      . $manifest_entry->{Allele_A} . '/'
      . $manifest_entry->{Allele_B} . ']';

    $output_hash->{flanking} = $manifest_entry->{Flank};

    if ( $output_hash->{flanking} =~ m/\[([^\/]*)\/([^\/]*)\]/ ) {
        $output_hash->{first_allele_from_flank}  = $1;
        $output_hash->{second_allele_from_flank} = $2;
    }

    $output_hash->{AB_A} = $manifest_entry->{Allele_A};
    $output_hash->{AB_B} = $manifest_entry->{Allele_B};

    #next do BLAST-based values
    my $basic_blast_results =
      get_basic_blast_results( $options, $blast_hash_of_hashes, $output_hash );

    $output_hash->{BLAST_chromosome} = $basic_blast_results->{chromosome};
    $output_hash->{BLAST_strand}     = $basic_blast_results->{strand};
    $output_hash->{BLAST_position}   = $basic_blast_results->{position};
    $output_hash->{Reference_allele_forward_strand} =
      $basic_blast_results->{reference_base_forward_strand};
    $output_hash->{alignment} = $basic_blast_results->{alignment};

    $output_hash->{VCF_REF} = $basic_blast_results->{VCF_REF};
    $output_hash->{VCF_ALT} = $basic_blast_results->{VCF_ALT};

    if ( ( $output_hash->{AB_A} eq 'I' ) || ( $output_hash->{AB_A} eq 'D' ) ) {
        $output_hash->{is_indel} = 1;
        populate_conversion_hash_affymetrix_indel( $options, $manifest_entry,
            $output_hash );
    }
    else {
        $output_hash->{is_snp} = 1;
        populate_conversion_hash_affymetrix_snp( $options, $manifest_entry,
            $output_hash );
    }
    set_vcf_a_and_b($output_hash);
    return $output_hash;
}

sub populate_conversion_hash_affymetrix_snp {
    my $options        = shift;
    my $manifest_entry = shift;
    my $output_hash    = shift;

    $output_hash->{FORWARD_A} = $manifest_entry->{Allele_A};
    $output_hash->{FORWARD_B} = $manifest_entry->{Allele_B};

    #use the BLAST results to determine PLUS_A and PLUS_B
    if ( defined( $output_hash->{BLAST_strand} ) ) {

        if ( $output_hash->{BLAST_strand} eq 'plus' ) {
            $output_hash->{PLUS_A} = $output_hash->{FORWARD_A};
            $output_hash->{PLUS_B} = $output_hash->{FORWARD_B};
        }
        elsif ( $output_hash->{BLAST_strand} eq 'minus' ) {
            $output_hash->{PLUS_A} = rc( $output_hash->{FORWARD_A} );
            $output_hash->{PLUS_B} = rc( $output_hash->{FORWARD_B} );
        }
    }
}

sub populate_conversion_hash_affymetrix_indel {
    my $options        = shift;
    my $manifest_entry = shift;
    my $output_hash    = shift;

}

sub set_vcf_a_and_b {
    my $output_hash = shift;

    if ( $output_hash->{is_snp} ) {
        if (   ( defined( $output_hash->{Reference_allele_forward_strand} ) )
            && ( defined( $output_hash->{VCF_REF} ) ) )
        {

            if ( $output_hash->{PLUS_A} eq $output_hash->{VCF_REF} ) {
                $output_hash->{VCF_A} = 'REF';
                $output_hash->{VCF_B} = 'ALT';
            }
            elsif ( $output_hash->{PLUS_B} eq $output_hash->{VCF_REF} ) {
                $output_hash->{VCF_B} = 'REF';
                $output_hash->{VCF_A} = 'ALT';
            }
            else {
                $output_hash->{VCF_B} = 'ALT';
                $output_hash->{VCF_A} = 'ALT';
            }
        }
    }
    elsif ( $output_hash->{is_indel} ) {
        if (   ( defined( $output_hash->{Reference_allele_forward_strand} ) )
            && ( defined( $output_hash->{VCF_REF} ) ) )
        {
            if ( $output_hash->{PLUS_A} eq
                $output_hash->{Reference_allele_forward_strand} )
            {
                $output_hash->{VCF_A} = 'REF';
                $output_hash->{VCF_B} = 'ALT';
            }
            elsif ( $output_hash->{PLUS_B} eq
                $output_hash->{Reference_allele_forward_strand} )
            {
                $output_hash->{VCF_B} = 'REF';
                $output_hash->{VCF_A} = 'ALT';
            }
            else {
                $output_hash->{VCF_B} = 'ALT';
                $output_hash->{VCF_A} = 'ALT';
            }
        }
    }

}

sub get_basic_blast_results {
    my $options              = shift;
    my $blast_hash_of_hashes = shift;
    my $output_hash          = shift;

    my %results = (
        chromosome                    => undef,
        strand                        => undef,
        position                      => undef,
        reference_base_forward_strand => undef,
        VCF_REF                       => undef,
        VCF_ALT                       => undef,
        alignment                     => undef
    );

    #look for hit by Alternative_Name then Name
    my @blast_queries =
      ( $output_hash->{Alternative_Name}, $output_hash->{Name} );
    my $blast_result_hash =
      get_blast_record_hash( $options, \@blast_queries, $blast_hash_of_hashes );
    if ( !( defined($blast_result_hash) ) ) {
        return \%results;
    }

    $results{chromosome} = parse_chromosome(
        $blast_result_hash->{subject_id},
        $blast_result_hash->{subject_titles}
    );
    $results{strand} = $blast_result_hash->{subject_strand};

    my %h = ();
    $h{query_id} = $blast_result_hash->{query_id};

    #if strand is plus it means the provided flanking sequence
    #is from the forward strand of the reference genome
    my $alignment_result;
    if ( $results{strand} eq 'plus' ) {
        $h{query_seq}   = $blast_result_hash->{query_seq};
        $h{subject_seq} = $blast_result_hash->{subject_seq};
        $h{s_start}     = $blast_result_hash->{'s._start'};
        $h{s_end}       = $blast_result_hash->{'s._end'};
        $h{allele1}     = $output_hash->{first_allele_from_flank};
        $h{allele2}     = $output_hash->{second_allele_from_flank};

        #provide probe sequence
        if (   ( defined( $output_hash->{Probe_to_SourceSeq} ) )
            && ( $output_hash->{Probe_to_SourceSeq} eq 'FORWARD' ) )
        {
            $h{probe_seq}  = $output_hash->{probe_sequence};
            $h{probe_side} = 'LEFT';
        }
        elsif (( defined( $output_hash->{Probe_to_SourceSeq} ) )
            && ( $output_hash->{Probe_to_SourceSeq} eq 'REVERSE' ) )
        {
            $h{probe_seq}  = rc( $output_hash->{probe_sequence} );
            $h{probe_side} = 'RIGHT';
        }
    }
    elsif ( $results{strand} eq 'minus' ) {
        $h{query_seq}   = rc( $blast_result_hash->{query_seq} );
        $h{subject_seq} = rc( $blast_result_hash->{subject_seq} );
        $h{s_start}     = $blast_result_hash->{'s._end'};
        $h{s_end}       = $blast_result_hash->{'s._start'};
        $h{allele1}     = rc( $output_hash->{second_allele_from_flank} );
        $h{allele2}     = rc( $output_hash->{first_allele_from_flank} );

        #provide probe sequence
        if (   ( defined( $output_hash->{Probe_to_SourceSeq} ) )
            && ( $output_hash->{Probe_to_SourceSeq} eq 'FORWARD' ) )
        {
            $h{probe_seq}  = rc( $output_hash->{probe_sequence} );
            $h{probe_side} = 'RIGHT';
        }
        elsif (( defined( $output_hash->{Probe_to_SourceSeq} ) )
            && ( $output_hash->{Probe_to_SourceSeq} eq 'REVERSE' ) )
        {
            $h{probe_seq}  = $output_hash->{probe_sequence};
            $h{probe_side} = 'LEFT';
        }

    }

    $h{query_seq}   = uc( $h{query_seq} );
    $h{subject_seq} = uc( $h{subject_seq} );
    $h{allele1}     = uc( $h{allele1} );
    $h{allele2}     = uc( $h{allele2} );

    $alignment_result = build_alignment( $options, \%h );

    $results{position} = $alignment_result->{position};
    $results{reference_base_forward_strand} =
      $alignment_result->{reference_base};
    $results{VCF_REF}   = $alignment_result->{VCF_REF};
    $results{VCF_ALT}   = $alignment_result->{VCF_ALT};
    $results{alignment} = $alignment_result->{alignment};
    return \%results;
}

sub parse_chromosome {
    my $subject_id     = shift;
    my $subject_titles = shift;

    my $chromosome = undef;

    if ( $subject_id =~ m/^([\dA-Z]{1,2})$/ ) {
        $chromosome = $1;
    }
    elsif ( $subject_titles =~ m/Chromosome_([\dA-Z]{1,2})_/ ) {
        $chromosome = $1;
    }
    elsif ( $subject_id =~ m/^([^\|]{5,})$/ ) {
        $chromosome = $1;
    }
    elsif ( $subject_titles =~ m/_([^\|]{5,})$/ ) {
        $chromosome = $1;
    }
    else {
        $chromosome = $subject_id;
    }
    return $chromosome;
}

sub get_assayed_position_by_left_probe {
    my $subject       = shift;
    my $subject_start = shift;
    my $probe         = shift;

    $subject =~ s/\-//g;
    my $position;

    if ( $subject =~ m/$probe/ ) {
        $position = $subject_start + $+[0];
    }
    return $position;
}

sub get_assayed_position_by_left_probe_partial {
    my $subject       = shift;
    my $subject_start = shift;
    my $probe         = shift;

    my $min_probe_length = 5;
    my $position;
    while ( length($probe) >= $min_probe_length ) {
        $position =
          get_assayed_position_by_left_probe( $subject, $subject_start,
            $probe );
        if ( defined($position) ) {
            return $position;
        }
        $probe = substr( $probe, -1 * ( length($probe) - 1 ) );
    }
    return $position;
}

sub get_assayed_position_by_right_probe {
    my $subject       = shift;
    my $subject_start = shift;
    my $probe         = shift;

    $subject =~ s/\-//g;
    my $position;

    if ( $subject =~ m/$probe/ ) {
        $position = $subject_start + $-[0] - 1;
    }
    return $position;
}

sub get_assayed_position_by_right_probe_partial {
    my $subject       = shift;
    my $subject_start = shift;
    my $probe         = shift;

    my $min_probe_length = 5;
    my $position;
    while ( length($probe) >= $min_probe_length ) {
        $position =
          get_assayed_position_by_right_probe( $subject, $subject_start,
            $probe );
        if ( defined($position) ) {
            return $position;
        }
        $probe = substr( $probe, 0, -1 );
    }
    return $position;
}

sub convert_subject_position_to_alignment_position {
    my $subject       = shift;
    my $subject_start = shift;
    my $position      = shift;

    my $current_position = $subject_start - 1;
    my $char_count       = 0;
    for my $c ( split //, $subject ) {
        $char_count++;
        if ( $c =~ m/[GATCN]/i ) {
            $current_position++;
        }
        if ( $current_position == $position ) {
            return $char_count;
        }
    }
}

sub convert_alignment_position_to_subject_position {
    my $subject       = shift;
    my $subject_start = shift;
    my $position      = shift;

    my $current_position = $subject_start - 1;
    my $char_count       = 0;
    for my $c ( split //, $subject ) {
        $char_count++;
        if ( $c =~ m/[GATCN]/i ) {
            $current_position++;
        }
        if ( $char_count == $position ) {
            return $current_position;
        }
    }
}

sub get_subject_char_at_subject_position {
    my $subject       = shift;
    my $subject_start = shift;
    my $position      = shift;

    $subject =~ s/\-//g;
    my $current_position = $subject_start - 1;
    for my $c ( split //, $subject ) {
        $current_position++;
        if ( $current_position == $position ) {
            return $c;
        }
    }
}

sub get_subject_char_at_alignment_position {
    my $subject       = shift;
    my $subject_start = shift;
    my $position      = shift;

    my $current_position = 0;
    for my $c ( split //, $subject ) {
        $current_position++;
        if ( $current_position == $position ) {
            return $c;
        }
    }
}

sub get_query_char_at_alignment_position {
    my $query    = shift;
    my $position = shift;

    my $current_position = 0;
    for my $c ( split //, $query ) {
        $current_position++;
        if ( $current_position == $position ) {
            return $c;
        }
    }
}

sub padding_to_base_before_subject_position {
    my $subject       = shift;
    my $subject_start = shift;
    my $position      = shift;

    my $alignment_position =
      convert_subject_position_to_alignment_position( $subject, $subject_start,
        $position );

    my $alignment_position_to_left = $alignment_position;
    my $aligned_char               = '-';
    while (( $aligned_char eq '-' )
        && ( $alignment_position_to_left > 0 ) )
    {
        $alignment_position_to_left--;
        $aligned_char =
          get_subject_char_at_alignment_position( $subject, $subject_start,
            $alignment_position_to_left );
    }

    return $alignment_position_to_left;
}

sub spaces_to_base_after_subject_position {
    my $subject       = shift;
    my $subject_start = shift;
    my $position      = shift;

    my $alignment_position =
      convert_subject_position_to_alignment_position( $subject, $subject_start,
        $position );
    my $alignment_position_to_right = $alignment_position;
    my $aligned_char                = '-';
    while (( $aligned_char eq '-' )
        && ( $alignment_position_to_right <= length($subject) ) )
    {
        $alignment_position_to_right++;
        $aligned_char =
          get_subject_char_at_alignment_position( $subject, $subject_start,
            $alignment_position_to_right );
    }

    return $alignment_position_to_right - 1;
}

sub padding_to_subject_position {
    my $subject       = shift;
    my $subject_start = shift;
    my $position      = shift;

    my $alignment_position =
      convert_subject_position_to_alignment_position( $subject, $subject_start,
        $position );

    return $alignment_position;
}

sub add_formatted_snp_alignment {
    my $options        = shift;
    my $h              = shift;
    my $result         = shift;
    my $alignment_info = shift;

    my $p = $options->{alignment_padding};

    my @alignment = ();

    push @alignment, "$h->{query_id}\n";
    push @alignment, "Type: SNP\n";

    push @alignment, sprintf( "%${p}s", "QUERY " );
    push @alignment, "$h->{query_seq}\n";

    push @alignment, sprintf( "%${p}s", "SUBJECT " );
    push @alignment, "$h->{subject_seq}\n";

    if ( defined( $alignment_info->{left_probe_sequence} ) ) {
        my $padding_to_base_before_subject_position =
          padding_to_base_before_subject_position( $h->{subject_seq},
            $h->{s_start}, $alignment_info->{assayed_position} );
        push @alignment, sprintf( "%${p}s", "PROBE " );
        push @alignment,
          sprintf( "%${padding_to_base_before_subject_position}s",
            "$alignment_info->{left_probe_sequence}" );
        push @alignment, "\n";
    }

    if ( defined( $alignment_info->{right_probe_sequence} ) ) {
        my $spaces_to_base_after_subject_position =
          spaces_to_base_after_subject_position( $h->{subject_seq},
            $h->{s_start}, $alignment_info->{assayed_position} );

        push @alignment, sprintf( "%${p}s", "PROBE " );
        push @alignment, "" . " " x ($spaces_to_base_after_subject_position);
        push @alignment, "$alignment_info->{right_probe_sequence}";
        push @alignment, "\n";
    }

    #add ruler
    my $ruler_position = $h->{s_start};
    my @ruler          = ();

    for my $c ( split //, $h->{subject_seq} ) {
        if ( ( $ruler_position % 10 == 0 ) && ( $c =~ m/[GATCN]/i ) ) {
            push @ruler, "|";
        }
        else {
            push @ruler, " ";
        }
        if ( $c =~ m/[GATCN]/i ) {
            $ruler_position++;
        }
    }

    push @alignment, sprintf( "%${p}s", "$h->{s_start} " );
    push @alignment, sprintf( "%${p}s", join "", @ruler );
    push @alignment, "\n";

    #stop here if no position available
    if ( !( defined( $alignment_info->{assayed_position} ) ) ) {
        push @alignment, "Determination type: UNDETERMINED_SNP\n";
        $result->{alignment} = join "", @alignment;
        return;
    }

    my $padding_to_subject_position =
      padding_to_subject_position( $h->{subject_seq}, $h->{s_start},
        $alignment_info->{assayed_position} );

    my $subject_char =
      get_subject_char_at_subject_position( $h->{subject_seq}, $h->{s_start},
        $alignment_info->{assayed_position} );

    push @alignment, sprintf( "%${p}s", "ALLELE1 " );
    push @alignment,
      sprintf( "%${padding_to_subject_position}s", "$h->{allele1}" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s", "ALLELE2 " );
    push @alignment,
      sprintf( "%${padding_to_subject_position}s", "$h->{allele2}" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s", "POSITION " );
    push @alignment,
      sprintf( "%${padding_to_subject_position}s",
        "$alignment_info->{assayed_position}|" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s", "REF " );
    push @alignment,
      sprintf( "%${padding_to_subject_position}s", "$subject_char" );
    push @alignment, "\n";

    if ( $subject_char eq $h->{allele1} ) {
        $result->{VCF_REF} = $h->{allele1};
        $result->{VCF_ALT} = $h->{allele2};
    }
    elsif ( $subject_char eq $h->{allele2} ) {
        $result->{VCF_REF} = $h->{allele2};
        $result->{VCF_ALT} = $h->{allele1};
    }
    else {
        $result->{VCF_REF} = $subject_char;
        $result->{VCF_ALT} = $h->{allele1} . '/' . $h->{allele2};
    }

    push @alignment, sprintf( "%${p}s", "VCF_REF " );
    push @alignment,
      sprintf( "%${padding_to_subject_position}s", "$result->{VCF_REF}" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s", "VCF_ALT " );
    push @alignment,
      sprintf( "%${padding_to_subject_position}s", "$result->{VCF_ALT}" );
    push @alignment, "\n";

    push @alignment,
      "Determination type: $alignment_info->{determination_type}\n";

    $result->{alignment}      = join "", @alignment;
    $result->{position}       = $alignment_info->{assayed_position};
    $result->{reference_base} = $subject_char;
}

sub build_alignment_snp {
    my $options = shift;
    my $h       = shift;
    my $result  = shift;

    #use left probe
    if ( ( defined( $h->{probe_seq} ) ) && ( $h->{probe_side} eq 'LEFT' ) ) {

        my $assayed_position_by_left_probe =
          get_assayed_position_by_left_probe( $h->{subject_seq}, $h->{s_start},
            $h->{probe_seq} );
        if ( defined($assayed_position_by_left_probe) ) {
            my %alignment_info = ();
            $alignment_info{assayed_position} = $assayed_position_by_left_probe;
            $alignment_info{left_probe_sequence} = $h->{probe_seq};
            $alignment_info{determination_type}  = 'LEFT_PROBE_SNP';
            add_formatted_snp_alignment( $options, $h, $result,
                \%alignment_info );
            return $result;
        }
    }

    #use right probe
    if ( ( defined( $h->{probe_seq} ) ) && ( $h->{probe_side} eq 'RIGHT' ) ) {
        my $assayed_position_by_right_probe =
          get_assayed_position_by_right_probe( $h->{subject_seq},
            $h->{s_start}, $h->{probe_seq} );
        if ( defined($assayed_position_by_right_probe) ) {
            my %alignment_info = ();
            $alignment_info{assayed_position} =
              $assayed_position_by_right_probe;
            $alignment_info{right_probe_sequence} = $h->{probe_seq};
            $alignment_info{determination_type}   = 'RIGHT_PROBE_SNP';
            add_formatted_snp_alignment( $options, $h, $result,
                \%alignment_info );
            return $result;
        }
    }

    #use alignment with no gaps
    if (   ( !( $h->{subject_seq} =~ m/\-/ ) )
        && ( !( $h->{query_seq} =~ m/\-/ ) ) )
    {
        if ( $h->{query_seq} =~ m/^([^N]*)N/i ) {
            my $alignment_position_variant = length($1) + 1;
            my %alignment_info             = ();
            $alignment_info{assayed_position} =
              convert_alignment_position_to_subject_position( $h->{subject_seq},
                $h->{s_start}, $alignment_position_variant );
            $alignment_info{determination_type} = 'UNAMBIGUOUS_ALIGNMENT_SNP';
            add_formatted_snp_alignment( $options, $h, $result,
                \%alignment_info );
            return $result;
        }
    }

    #use shortened left probe to allow more matches
    if ( ( defined( $h->{probe_seq} ) ) && ( $h->{probe_side} eq 'LEFT' ) ) {
        my $assayed_position_by_left_probe =
          get_assayed_position_by_left_probe_partial( $h->{subject_seq},
            $h->{s_start}, $h->{probe_seq} );

        if ( defined($assayed_position_by_left_probe) ) {

            my $alignment_position =
              convert_subject_position_to_alignment_position( $h->{subject_seq},
                $h->{s_start}, $assayed_position_by_left_probe );
            my $query_base =
              get_query_char_at_alignment_position( $h->{query_seq},
                $alignment_position );
            if ( ( $query_base eq 'N' ) || ( $query_base eq '-' ) ) {
                my %alignment_info = ();
                $alignment_info{assayed_position} =
                  $assayed_position_by_left_probe;
                $alignment_info{left_probe_sequence} = $h->{probe_seq};
                $alignment_info{determination_type}  = 'PARTIAL_LEFT_PROBE_SNP';
                add_formatted_snp_alignment( $options, $h, $result,
                    \%alignment_info );
                return $result;
            }
        }
    }

    #use shortened right probe to allow more matches
    if ( ( defined( $h->{probe_seq} ) ) && ( $h->{probe_side} eq 'RIGHT' ) ) {
        my $assayed_position_by_right_probe =
          get_assayed_position_by_right_probe_partial( $h->{subject_seq},
            $h->{s_start}, $h->{probe_seq} );
        if ( defined($assayed_position_by_right_probe) ) {

            my $alignment_position =
              convert_subject_position_to_alignment_position( $h->{subject_seq},
                $h->{s_start}, $assayed_position_by_right_probe );
            my $query_base =
              get_query_char_at_alignment_position( $h->{query_seq},
                $alignment_position );
            if ( ( $query_base eq 'N' ) || ( $query_base eq '-' ) ) {
                my %alignment_info = ();
                $alignment_info{assayed_position} =
                  $assayed_position_by_right_probe;
                $alignment_info{right_probe_sequence} = $h->{probe_seq};
                $alignment_info{determination_type} = 'PARTIAL_RIGHT_PROBE_SNP';
                add_formatted_snp_alignment( $options, $h, $result,
                    \%alignment_info );
                return $result;
            }
        }
    }

#use alignment where variant aligns with subject base but there are some gaps in alignment
    if ( $h->{query_seq} =~ m/^([^N]*)N/i ) {
        my $alignment_position_variant = length($1) + 1;
        my $subject_char_at_alignment_position =
          get_subject_char_at_alignment_position( $h->{subject_seq},
            $h->{s_start}, $alignment_position_variant );
        if ( $subject_char_at_alignment_position ne '-' ) {
            my %alignment_info = ();
            $alignment_info{assayed_position} =
              convert_alignment_position_to_subject_position( $h->{subject_seq},
                $h->{s_start}, $alignment_position_variant );
            $alignment_info{determination_type} = 'GAPPED_ALIGNMENT_SNP';
            add_formatted_snp_alignment( $options, $h, $result,
                \%alignment_info );
            return $result;
        }
    }

    #alignments where variant aligns with gap
    if ( $h->{query_seq} =~ m/^([^N]*)N/i ) {
        my $alignment_position_variant = length($1) + 1;
        my $subject_char_at_alignment_position =
          get_subject_char_at_alignment_position( $h->{subject_seq},
            $h->{s_start}, $alignment_position_variant );

        if ( $subject_char_at_alignment_position eq '-' ) {

            #find first subject base to left
            my $position_to_left = $alignment_position_variant;
            my $base_to_left     = '-';

            while (( $position_to_left > 0 )
                && ( $base_to_left eq '-' ) )
            {
                $position_to_left--;
                $base_to_left =
                  get_subject_char_at_alignment_position( $h->{subject_seq},
                    $h->{s_start}, $position_to_left );
            }

            my $position_to_right = $alignment_position_variant;
            my $base_to_right     = '-';

            while (( $position_to_right <= length( $h->{subject_seq} ) )
                && ( $base_to_right eq '-' ) )
            {
                $position_to_right++;
                $base_to_right =
                  get_subject_char_at_alignment_position( $h->{subject_seq},
                    $h->{s_start}, $position_to_right );
            }

            #Compare reference bases to the alleles
            my $left_is_consistent  = 0;
            my $right_is_consistent = 0;

            if (   ( $base_to_left eq $h->{allele1} )
                || ( $base_to_left eq $h->{allele2} ) )
            {
                $left_is_consistent = 1;
            }
            if (   ( $base_to_right eq $h->{allele1} )
                || ( $base_to_right eq $h->{allele2} ) )
            {
                $right_is_consistent = 1;
            }

            if ( ($left_is_consistent) && ( !($right_is_consistent) ) ) {
                my %alignment_info = ();
                $alignment_info{assayed_position} =
                  convert_alignment_position_to_subject_position(
                    $h->{subject_seq}, $h->{s_start}, $position_to_left );
                $alignment_info{determination_type} =
                  'ALIGNMENT_TO_GAP_INFORMATIVE_ALLELES_SNP';
                add_formatted_snp_alignment( $options, $h, $result,
                    \%alignment_info );
                return $result;
            }
            elsif ( ($right_is_consistent) && ( !($left_is_consistent) ) ) {
                my %alignment_info = ();
                $alignment_info{assayed_position} =
                  convert_alignment_position_to_subject_position(
                    $h->{subject_seq}, $h->{s_start}, $position_to_right );
                $alignment_info{determination_type} =
                  'ALIGNMENT_TO_GAP_INFORMATIVE_ALLELES_SNP';
                add_formatted_snp_alignment( $options, $h, $result,
                    \%alignment_info );
                return $result;
            }
            elsif ( ($right_is_consistent) && ($left_is_consistent) ) {
                my %alignment_info = ();
                $alignment_info{assayed_position} =
                  convert_alignment_position_to_subject_position(
                    $h->{subject_seq}, $h->{s_start}, $position_to_left );
                $alignment_info{determination_type} =
'ALIGNMENT_TO_GAP_UNINFORMATIVE_ALLELES_BOTH_SIDES_CONSISTENT_SNP';
                add_formatted_snp_alignment( $options, $h, $result,
                    \%alignment_info );
                return $result;
            }
            elsif ( !($right_is_consistent) && ( !($left_is_consistent) ) ) {
                my %alignment_info = ();
                $alignment_info{assayed_position} =
                  convert_alignment_position_to_subject_position(
                    $h->{subject_seq}, $h->{s_start}, $position_to_left );
                $alignment_info{determination_type} =
'ALIGNMENT_TO_GAP_UNINFORMATIVE_ALLELES_BOTH_SIDES_INCONSISTENT_SNP';
                add_formatted_snp_alignment( $options, $h, $result,
                    \%alignment_info );
                return $result;
            }

        }
    }

    my %alignment_info = ();
    $alignment_info{determination_type} = 'UNDETERMINED_SNP';
    add_formatted_snp_alignment( $options, $h, $result, \%alignment_info );

    return $result;
}

sub build_alignment {
    my $options = shift;
    my $h       = shift;

    my %result = (
        position       => undef,
        reference_base => undef,    #D/I for indel, base for SNP
        VCF_REF        => undef,
        VCF_ALT        => undef,
        alignment      => undef
    );

    if ( ( $h->{allele1} ne '-' ) && ( $h->{allele2} ne '-' ) ) {
        return build_alignment_snp( $options, $h, \%result );
    }
    else {
        return build_alignment_indel( $options, $h, \%result );
    }

}

sub build_alignment_indel {
    my $options = shift;
    my $h       = shift;
    my $result  = shift;

    my $p = $options->{alignment_padding};

    my @alignment = ();

    push @alignment, "$h->{query_id}\n";
    push @alignment, "Type: INDEL\n";

    push @alignment, sprintf( "%${p}s", "QUERY " );
    push @alignment, "$h->{query_seq}\n";

    push @alignment, sprintf( "%${p}s", "SUBJECT " );
    push @alignment, "$h->{subject_seq}\n";

    #add ruler
    my $ruler_position = $h->{s_start};
    my @ruler          = ();

    for my $c ( split //, $h->{subject_seq} ) {
        if ( ( $ruler_position % 10 == 0 ) && ( $c =~ m/[GATCN]/i ) ) {
            push @ruler, "|";
        }
        else {
            push @ruler, " ";
        }
        if ( $c =~ m/[GATCN]/i ) {
            $ruler_position++;
        }
    }

    push @alignment, sprintf( "%${p}s", "$h->{s_start} " );
    push @alignment, sprintf( "%${p}s", join "", @ruler );
    push @alignment, "\n";

    if ( !( $h->{query_seq} =~ m/N/i ) ) {
        push @alignment, "Determination type: UNDETERMINED_INDEL\n";
        $result->{alignment} = join "", @alignment;
        return $result;
    }

    #count from the left
    my $query_chars_from_left = 0;
    if ( $h->{query_seq} =~ m/^([^N]*)N/i ) {
        $query_chars_from_left = length($1);
    }
    my $subject_bases_from_left = 0;
    if ( $h->{subject_seq} =~ m/^(.{$query_chars_from_left})/ ) {
        my $chars = $1;
        $chars =~ s/\-//g;
        $subject_bases_from_left = length($chars);
    }

    my $subject_position_left_of_variant =
      $h->{s_start} + $subject_bases_from_left - 1;

    my $position;
    my $reference_base;

    my $subject_base_aligned_with_variant =
      substr( $h->{subject_seq}, $query_chars_from_left, 1 );

    my $determination_type;

    if ( $subject_base_aligned_with_variant =~ m/[GATCN]/ ) {

        #ref genome probably has insertion allele
        $reference_base = 'I';

        #position is tricky, use the first base to the left of the variant
        $position = $subject_position_left_of_variant;
        my $char_pos = $query_chars_from_left;

        my $subject_chars_to_and_including_n =
          substr( $h->{subject_seq}, 0, $query_chars_from_left + 1 );
        my $shift_left = left_normalize( $h->{allele1}, $h->{allele2},
            $subject_chars_to_and_including_n );

        $position = $position - $shift_left;

        $determination_type = 'REFERENCE_INSERTION_INDEL';

    }
    elsif ( $subject_base_aligned_with_variant eq '-' ) {

        #ref genome probably has deletion allele
        $reference_base = 'D';

        #position is tricky, use the first base to the left of the variant
        $position = $subject_position_left_of_variant;
        my $char_pos = $query_chars_from_left;

        my $subject_chars_to_and_including_n =
          substr( $h->{subject_seq}, 0, $query_chars_from_left + 1 );
        my $shift_left = left_normalize( $h->{allele1}, $h->{allele2},
            $subject_chars_to_and_including_n );

        $position = $position - $shift_left;

        $determination_type = 'REFERENCE_DELETION_INDEL';

    }

    if ( !( defined($position) ) ) {
        push @alignment, "Determination type: UNDETERMINED_INDEL\n";
        $result->{alignment} = join "", @alignment;
        return $result;
    }

    my $subject_bases_from_left_to_position = $position - $h->{s_start} + 1;
    my $char_count                          = 0;
    my $base_count                          = 0;
    my $current_position                    = $h->{s_start};
    my $ref_base_at_position                = undef;
    for my $c ( split //, $h->{subject_seq} ) {
        $char_count++;
        if ( $c =~ m/[GATCN]/i ) {
            $base_count++;
            $current_position++;
        }
        if ( $base_count == $subject_bases_from_left_to_position ) {
            $ref_base_at_position = $c;
            last;
        }
    }

    push @alignment, sprintf( "%${p}s",          "ALLELE1 " );
    push @alignment, sprintf( "%${char_count}s", "$h->{allele1}" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s",          "ALLELE2 " );
    push @alignment, sprintf( "%${char_count}s", "$h->{allele2}" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s",          "POSITION " );
    push @alignment, sprintf( "%${char_count}s", "$position|" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s",          "REF " );
    push @alignment, sprintf( "%${char_count}s", "$reference_base" );
    push @alignment, "\n";

    my $d_allele;
    my $i_allele;
    if ( $h->{allele1} =~ m/\-/ ) {
        $d_allele = $h->{allele1};
        $i_allele = $h->{allele2};
    }
    elsif ( $h->{allele2} =~ m/\-/ ) {
        $d_allele = $h->{allele2};
        $i_allele = $h->{allele1};
    }
    if ( $reference_base eq 'D' ) {
        $result->{VCF_REF} = $ref_base_at_position;
        $result->{VCF_ALT} = $ref_base_at_position . $i_allele;
    }
    elsif ( $reference_base eq 'I' ) {
        $result->{VCF_REF} = $ref_base_at_position . $i_allele;
        $result->{VCF_ALT} = $ref_base_at_position;
    }

    push @alignment, sprintf( "%${p}s",          "VCF_REF " );
    push @alignment, sprintf( "%${char_count}s", "$result->{VCF_REF}" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s",          "VCF_ALT " );
    push @alignment, sprintf( "%${char_count}s", "$result->{VCF_ALT}" );
    push @alignment, "\n";

    push @alignment, "Determination type: $determination_type\n";

    $result->{alignment}      = join "", @alignment;
    $result->{position}       = $position;
    $result->{reference_base} = $reference_base;

    return $result;
}

sub left_normalize {
    my $allele1 = shift;
    my $allele2 = shift;
    my $s_seq   = shift;

    my $allele_to_shift;
    if ( $allele1 =~ m/[GATCN]/ ) {
        $allele_to_shift = $allele1;
    }
    elsif ( $allele2 =~ m/[GATCN]/ ) {
        $allele_to_shift = $allele2;
    }
    if ( $s_seq =~ m/(($allele_to_shift)+)[\-]?$/ ) {

        my $shift = length($1);

        #if right-most char is not gap then reduce shift by 1
        if ( $s_seq =~ /[GATCN]$/i ) {
            $shift = $shift - 1;
        }

        return $shift;
    }
    return 0;
}

sub get_blast_record_hash {
    my $options              = shift;
    my $names_list           = shift;
    my $blast_hash_of_hashes = shift;

    foreach my $name ( @{$names_list} ) {
        if ( defined( $blast_hash_of_hashes->{$name} ) ) {
            return $blast_hash_of_hashes->{$name};
        }
    }
    return undef;
}

sub csv_to_array_of_hashes {
    my $file          = shift;
    my @data_rows     = ();
    my @columns       = undef;
    my $columns_found = 0;
    open( my $INFILE, $file )
      or die("Cannot open file '$file': $!");
    while ( my $line = <$INFILE> ) {

        #process header
        if (
            ( !($columns_found) )
            && ( $line =~
m/(IlmnID,Name,IlmnStrand|"Probe Set ID","Affy SNP ID"|query id,query seq|Probe Set ID\s+Affy SNP ID)/
            )
          )
        {
            @columns       = @{ _split($line) };
            $columns_found = 1;
            next;
        }
        elsif ( !($columns_found) ) {
            next;
        }
        my %hash   = ();
        my @values = @{ _split($line) };

        if ( scalar(@values) ne scalar(@columns) ) {
            print "skipping this record because it is length "
              . scalar(@values)
              . " while I expect length "
              . scalar(@columns) . "\n";
            print Dumper (@values);
            next;
        }

        for ( my $i = 0 ; $i < scalar(@columns) ; $i++ ) {
            $hash{ $columns[$i] } = $values[$i];
        }
        push( @data_rows, \%hash );
    }
    close($INFILE) or die("Cannot close file : $!");
    return \@data_rows;
}

sub _split {
    my $line   = shift;
    my @values = ();
    if ( $line =~ m/\t/ ) {
        @values = split( /\t/, $line );
    }
    else {
        #      @values = split( /\,/, $line );
        @values = @{ _split_comma($line) };
    }
    foreach (@values) {
        $_ = clean_value($_);
    }
    return \@values;
}

sub _split_comma {
    my $text = shift;
    my @new  = ();
    push( @new, $+ ) while $text =~ m{
                  "([^\"\\]*(?:\\.[^\"\\]*)*)",? # groups the phrase inside the quotes
                | ([^,]+),?
                | ,
          }gx;
    push( @new, undef ) if substr( $text, -1, 1 ) eq ',';
    return \@new;
}

sub clean_value {
    my $value = shift;
    if ( !defined($value) ) {
        return ".";
    }
    if ( $value =~ m/^\s*$/ ) {
        return ".";
    }
    $value =~ s/^\s+//g;
    $value =~ s/\s+$//g;
    $value =~ s/\"|\'//g;
    $value =~ s/\s/_/g;
    return $value;
}

sub rc {
    my $sequence = shift;
    $sequence =~
      tr/gatcryswkmbdhvnGATCRYSWKMBDHVN/ctagyrswmkvhdbnCTAGYRSWMKVHDBN/;
    $sequence = reverse($sequence);
    return $sequence;
}

sub get_time {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    $year += 1900;

    my @days = (
        'Sunday',   'Monday', 'Tuesday', 'Wednesday',
        'Thursday', 'Friday', 'Saturday'
    );
    my @months = (
        'January',   'February', 'March',    'April',
        'May',       'June',     'July',     'August',
        'September', 'October',  'November', 'December'
    );
    my $time =
        $days[$wday] . " "
      . $months[$mon] . " "
      . sprintf( "%02d", $mday ) . " "
      . sprintf( "%02d", $hour ) . ":"
      . sprintf( "%02d", $min ) . ":"
      . sprintf( "%02d", $sec ) . " "
      . sprintf( "%04d", $year );
    return $time;
}

sub print_usage {
    print <<BLOCK;
USAGE:
   perl build_conversion_file_and_position_file.pl -b FILE -m FILE -p FILE -c FILE [Options]

DESCRIPTION:
   Accepts an Illumina or Affymetrix manifest file and BLAST results for variant flanking
   sequences and generates a file describing the position of each variant (position file)
   and a file describing how to convert between genotype formats (conversion file).

REQUIRED ARGUMENTS:
   -b, --blast [FILE]
      Input file containing BLAST results for the variants in the manifest file.
   -m, --manifest [File]
      Input Illumina or Affymetrix manifest file.
   -p, --position [FILE]
      Output CSV file to create describing variant positions determined by BLAST.
   -c, --conversion [FILE]
      Output CSV file to create describing how to convert between genotype formats.
      
OPTIONAL ARGUMENTS:
   -w, --wide [FILE]
      Output CSV file to create describing position and conversion information.
   -a, --alignment [FILE]
      Output text file showing how BLAST alignments were used to determine variant 
      position and alleles.
   -i, --info [STRINGS]
      Additional text to appear in the header of output files.
   -h, --help
      Show this message.

EXAMPLE:
   perl build_conversion_file_and_position_file.pl -b blast_results.csv \
   -m BovineSNP50_v3_A1.csv -p position.csv -c conversion.csv \
   -i 'REF=ARS-UCD1.2' 'PANEL=SNP50_v3'

BLOCK
}
