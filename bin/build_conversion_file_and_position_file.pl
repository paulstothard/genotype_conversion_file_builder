#!/usr/bin/env perl
#Written by Paul Stothard
#stothard@ualberta.ca
#20200328

use warnings;
use strict;
use Data::Dumper;
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

    my $p = $options->{alignment_padding};

    my $query_seq     = $h->{query_seq};
    my $subject_seq   = $h->{subject_seq};
    my $subject_start = $h->{s_start};
    my $query_id      = $h->{query_id};
    my $allele1       = $h->{allele1};
    my $allele2       = $h->{allele2};
    my $left_probe_seq;
    my $right_probe_seq;

    if ( ( defined( $h->{probe_side} ) ) && ( $h->{probe_side} eq 'LEFT' ) ) {
        $left_probe_seq = $h->{probe_seq};
    }
    if ( ( defined( $h->{probe_side} ) ) && ( $h->{probe_side} eq 'RIGHT' ) ) {
        $right_probe_seq = $h->{probe_seq};
    }

    my $variant_type;
    if ( ( $allele1 ne '-' ) && ( $allele2 ne '-' ) ) {
        $variant_type = 'SNP';
    }
    else {
        $variant_type = 'INDEL';
    }

    my %column_hash  = ();
    my %subject_hash = ();

    my @query_seq   = split //, $query_seq;
    my @subject_seq = split //, $subject_seq;

    ( my $subject_seq_no_gaps = $subject_seq ) =~ s/\-//g;
    my $left_probe_match;
    my $right_probe_match;
    my $determination_type;

    my $subject_no_gaps_position_string = 0;
    my $subject_no_gaps_position_genome = $subject_start;
    my $N_column                        = undef;
    my $previous_gaps                   = 0;
    my $gaps_since_N                    = 0;
    for ( my $i = 0 ; $i < scalar(@subject_seq) ; $i++ ) {
        my %column = (
            gaps_linking_to_N               => undef,
            query_char                      => undef,
            query_base                      => undef,
            subject_char                    => undef,
            subject_base                    => undef,
            subject_no_gaps_position_string => undef,
            ruler_char                      => undef
        );
        my %subject =
          ( base => undef, position_chromosome => undef, column => undef );
        $column{subject_char} = $subject_seq[$i];
        $column{query_char}   = $query_seq[$i];

        if ( $subject_no_gaps_position_genome % 10 == 0 ) {
            $column{ruler_char} = '|';
        }
        elsif ( $subject_no_gaps_position_genome % 5 == 0 ) {
            $column{ruler_char} = '.';
        }
        else {
            $column{ruler_char} = ' ';
        }

        if ( $column{subject_char} =~ m/[A-Z]/i ) {
            $column{subject_base} = $column{subject_char};
            $column{subject_no_gaps_position_string} =
              $subject_no_gaps_position_string;
            $subject{base}                = $column{subject_char};
            $subject{position_chromosome} = $subject_no_gaps_position_genome;
            $subject{column}              = $i;
            $subject_hash{$subject_no_gaps_position_string} = \%subject;
            $subject_no_gaps_position_string++;
            $subject_no_gaps_position_genome++;
        }

        if ( $column{query_char} =~ m/[GATC]/i ) {
            $column{query_base} = $column{query_char};
            $previous_gaps = 0;
        }
        elsif ( $column{query_char} eq 'N' ) {
            $column{query_base} = $column{query_char};
            $N_column = $i;
            my $column_index   = $i - 1;
            my $number_of_gaps = $previous_gaps;
            while ( ( $number_of_gaps > 0 ) && ( $column_index >= 0 ) ) {
                $number_of_gaps--;
                $column_hash{$column_index}->{gaps_linking_to_N} =
                  $previous_gaps - $number_of_gaps;
                $column_index--;
            }
            $previous_gaps = 0;
        }
        else {
            $previous_gaps++;
            if (   ( defined($N_column) )
                && ( ( $i - $N_column ) == $previous_gaps ) )
            {
                $column{gaps_linking_to_N} = $previous_gaps;
            }
        }
        $column_hash{$i} = \%column;
    }

    my $subject_variant_position_string_coord;
    my $indel_ref;
    my $indel_alt;

    if ( !defined($N_column) ) {
        return \%result;
    }

    if ( $variant_type eq 'SNP' ) {
        if ( ( !( $subject_seq =~ m/\-/ ) ) && ( !( $query_seq =~ m/\-/ ) ) ) {
            $subject_variant_position_string_coord =
              $column_hash{$N_column}->{subject_no_gaps_position_string};
            $determination_type = 'ALIGNMENT_NO_GAPS';
        }

        if (   ( !defined($subject_variant_position_string_coord) )
            && ( defined($left_probe_seq) ) )
        {
            if ( $subject_seq_no_gaps =~ m/$left_probe_seq/ ) {
                $subject_variant_position_string_coord = $+[0];
                $left_probe_match                      = $+[0] - 1;
            }
            $determination_type = 'LEFT_PROBE_MATCH';
        }

        if (   ( !defined($subject_variant_position_string_coord) )
            && ( defined($right_probe_seq) ) )
        {
            if ( $subject_seq_no_gaps =~ m/$right_probe_seq/ ) {
                $subject_variant_position_string_coord = $-[0] - 1;
                $right_probe_match                     = $-[0];
            }
            $determination_type = 'RIGHT_PROBE_MATCH';
        }

        if (   ( !defined($subject_variant_position_string_coord) )
            && ( defined($left_probe_seq) ) )
        {
            my $min_probe_length = 3;
            my $partial_left_probe_seq =
              substr( $left_probe_seq, -1 * ( length($left_probe_seq) - 1 ) );
            while ( length($partial_left_probe_seq) >= $min_probe_length ) {
                while ( $subject_seq_no_gaps =~ m/$partial_left_probe_seq/g ) {
                    my $match_position = $+[0];
                    if ( $match_position < length($subject_seq_no_gaps) ) {
                        my $match_column =
                          $subject_hash{$match_position}->{column};
                        my $match_column_hash = $column_hash{$match_column};
                        if (
                            (
                                ( $match_column_hash->{query_char} eq 'N' )
                                || (
                                    defined(
                                        $match_column_hash->{gaps_linking_to_N}
                                    )
                                )
                            )
                            && ( $match_column <= $N_column )
                          )
                        {
                            $subject_variant_position_string_coord =
                              $match_position;
                            $left_probe_match   = $match_position - 1;
                            $determination_type = 'LEFT_PROBE_PARTIAL_MATCH';
                            last;
                        }
                    }
                }
                if ( defined($subject_variant_position_string_coord) ) {
                    last;
                }
                $partial_left_probe_seq = substr( $partial_left_probe_seq,
                    -1 * ( length($partial_left_probe_seq) - 1 ) );
            }
        }

        if (   ( !defined($subject_variant_position_string_coord) )
            && ( defined($right_probe_seq) ) )
        {
            my $min_probe_length = 3;
            my $partial_right_probe_seq = substr( $right_probe_seq, 0, -1 );
            while ( length($partial_right_probe_seq) >= $min_probe_length ) {
                while ( $subject_seq_no_gaps =~ m/$partial_right_probe_seq/g ) {
                    my $match_position = $-[0] - 1;
                    if ( $match_position >= 0 ) {
                        my $match_column =
                          $subject_hash{$match_position}->{column};
                        my $match_column_hash = $column_hash{$match_column};
                        if (
                            (
                                ( $match_column_hash->{query_char} eq 'N' )
                                || (
                                    defined(
                                        $match_column_hash->{gaps_linking_to_N}
                                    )
                                )
                            )
                            && ( $match_column >= $N_column )
                          )
                        {
                            $subject_variant_position_string_coord =
                              $match_position;
                            $right_probe_match  = $match_position + 1;
                            $determination_type = 'RIGHT_PROBE_PARTIAL_MATCH';
                            last;
                        }
                    }
                }
                if ( defined($subject_variant_position_string_coord) ) {
                    last;
                }
                $partial_right_probe_seq =
                  substr( $partial_right_probe_seq, 0, -1 );
            }
        }

        #N aligns with base
        if (   ( !defined($subject_variant_position_string_coord) )
            && ( $column_hash{$N_column}->{subject_char} ne '-' ) )
        {
            $subject_variant_position_string_coord =
              $column_hash{$N_column}->{subject_no_gaps_position_string};
            $determination_type = 'GAPPED_ALIGNMENT';
        }

        #N aligns with gap
        if (   ( !defined($subject_variant_position_string_coord) )
            && ( $column_hash{$N_column}->{subject_char} eq '-' ) )
        {
            my $column_to_check = $N_column;
            my $first_left_column_with_subject_base;
            while ( $column_to_check > 0 ) {
                $column_to_check--;
                if ( $column_hash{$column_to_check}->{subject_char} ne '-' ) {
                    $first_left_column_with_subject_base =
                      $column_hash{$column_to_check};
                    last;
                }
            }

            $column_to_check = $N_column;
            my $first_right_column_with_subject_base;
            while ( $column_to_check < scalar( keys(%column_hash) ) ) {
                $column_to_check++;
                if ( $column_hash{$column_to_check}->{subject_char} ne '-' ) {
                    $first_right_column_with_subject_base =
                      $column_hash{$column_to_check};
                    last;
                }
            }

            my $left_is_consistent  = 0;
            my $right_is_consistent = 0;

            if ( defined($first_left_column_with_subject_base) ) {
                my $left_reference_base =
                  $first_left_column_with_subject_base->{subject_base};
                if (   ( $left_reference_base eq $allele1 )
                    || ( $left_reference_base eq $allele2 ) )
                {
                    $left_is_consistent = 1;
                }
            }
            if ( defined($first_right_column_with_subject_base) ) {
                my $right_reference_base =
                  $first_right_column_with_subject_base->{subject_base};
                if (   ( $right_reference_base eq $allele1 )
                    || ( $right_reference_base eq $allele2 ) )
                {
                    $right_is_consistent = 1;
                }
            }
            if ( ($left_is_consistent) && ( !($right_is_consistent) ) ) {
                $subject_variant_position_string_coord =
                  $first_left_column_with_subject_base
                  ->{subject_no_gaps_position_string};
                $determination_type = 'ALIGNMENT_TO_GAP_INFORMATIVE_ALLELES';
            }
            elsif ( ($right_is_consistent) && ( !($left_is_consistent) ) ) {
                $subject_variant_position_string_coord =
                  $first_right_column_with_subject_base
                  ->{subject_no_gaps_position_string};
                $determination_type = 'ALIGNMENT_TO_GAP_INFORMATIVE_ALLELES';
            }
            elsif ( ($right_is_consistent) && ($left_is_consistent) ) {
                $subject_variant_position_string_coord =
                  $first_left_column_with_subject_base
                  ->{subject_no_gaps_position_string};
                $determination_type =
'ALIGNMENT_TO_GAP_UNINFORMATIVE_ALLELES_BOTH_SIDES_CONSISTENT';
            }
            elsif ( !($right_is_consistent) && ( !($left_is_consistent) ) ) {
                $subject_variant_position_string_coord =
                  $first_left_column_with_subject_base
                  ->{subject_no_gaps_position_string};
                $determination_type =
'ALIGNMENT_TO_GAP_UNINFORMATIVE_ALLELES_BOTH_SIDES_INCONSISTENT';
            }
        }
    }
    elsif ( $variant_type eq 'INDEL' ) {

        my $insertion_allele;

        #seach for match to insertion allele that overlaps with N in query
        if ( $allele1 ne '-' ) {
            $insertion_allele = $allele1;
        }
        elsif ( $allele2 ne '-' ) {
            $insertion_allele = $allele2;
        }
        my $insertion_match;
        while (( $subject_seq_no_gaps =~ m/$insertion_allele/g )
            && ( !defined($insertion_match) ) )
        {
            my $match_start_on_subject = $-[0];
            my $match_end_on_subject   = $+[0] - 1;

            my $match_start_column =
              $subject_hash{$match_start_on_subject}->{column};
            my $match_start_column_hash = $column_hash{$match_start_column};

            my $match_end_column =
              $subject_hash{$match_end_on_subject}->{column};
            my $match_end_column_hash = $column_hash{$match_end_column};

          #both start and end of match should align with N or gaps adjacent to N
            if (
                (
                    ( $match_start_column_hash->{query_char} eq 'N' )
                    || (
                        defined(
                            $match_start_column_hash->{gaps_linking_to_N}
                        )
                    )
                )
                && ( ( $match_end_column_hash->{query_char} eq 'N' )
                    || (
                        defined( $match_end_column_hash->{gaps_linking_to_N} ) )
                )
              )
            {
                $insertion_match = $match_start_column;
            }
        }
        if ( defined($insertion_match) ) {
            my $subject_seq_to_position_before_match =
              substr( $subject_seq_no_gaps, 0, $insertion_match );
            my $shift = 0;

            #left normalize
            if ( $subject_seq_to_position_before_match =~
                m/(($insertion_allele)+)[\-]?$/ )
            {
                $shift = length($1);
            }
            my $left_normalized_position = $insertion_match - $shift - 1;
            if ( $left_normalized_position >= 0 ) {
                $subject_variant_position_string_coord =
                  $left_normalized_position;
                $indel_ref =
                  $subject_hash{$subject_variant_position_string_coord}->{base}
                  . $insertion_allele;
                $indel_alt =
                  $subject_hash{$subject_variant_position_string_coord}->{base};
                $determination_type =
                  'DETECTION_OF_INSERTION_ALLELE_AT_VARIANT_SITE';
            }
        }

        #if insertion not detected, look for deletion
        if (   ( !defined($subject_variant_position_string_coord) )
            && ( $column_hash{$N_column}->{subject_char} eq '-' ) )
        {
            my $column_to_check = $N_column;
            my $first_left_column_with_subject_base;
            while ( $column_to_check > 0 ) {
                $column_to_check--;
                if ( $column_hash{$column_to_check}->{subject_char} ne '-' ) {
                    $first_left_column_with_subject_base =
                      $column_hash{$column_to_check};
                    last;
                }
            }
            if ( defined($first_left_column_with_subject_base) ) {
                my $string_index_of_first_left_column_with_subject_base =
                  $first_left_column_with_subject_base
                  ->{subject_no_gaps_position_string};
                my $subject_seq_to_position_before_match =
                  substr( $subject_seq_no_gaps, 0,
                    $string_index_of_first_left_column_with_subject_base + 1 );
                my $shift = 0;

                #left normalize
                if ( $subject_seq_to_position_before_match =~
                    m/(($insertion_allele)+)[\-]?$/ )
                {
                    $shift = length($1);
                }
                my $left_normalized_position =
                  $string_index_of_first_left_column_with_subject_base - $shift;
                if ( $left_normalized_position >= 0 ) {
                    $subject_variant_position_string_coord =
                      $left_normalized_position;
                    $indel_ref =
                      $subject_hash{$subject_variant_position_string_coord}
                      ->{base};
                    $indel_alt =
                      $subject_hash{$subject_variant_position_string_coord}
                      ->{base} . $insertion_allele;
                    $determination_type =
                      'DETECTION_OF_DELETION_ALLELE_AT_VARIANT_SITE';
                }
            }
        }

    }

    #padding to variant base
    my $c = $subject_hash{$subject_variant_position_string_coord}->{column} + 1;

    my @alignment = ();
    push @alignment, "$query_id\n";

    if ( $variant_type eq 'SNP' ) {
        push @alignment, "Type: SNP\n";
    }
    elsif ( $variant_type eq 'INDEL' ) {
        push @alignment, "Type: INDEL\n";
    }

    push @alignment, sprintf( "%${p}s", "QUERY " );
    push @alignment, "$query_seq\n";

    push @alignment, sprintf( "%${p}s", "SUBJECT " );
    push @alignment, "$subject_seq\n";

    if ( defined($left_probe_match) ) {
        my $left_probe_padding = $subject_hash{$left_probe_match}->{column} + 1;
        push @alignment, sprintf( "%${p}s", "PROBE " );
        push @alignment,
          sprintf( "%${left_probe_padding}s", "$left_probe_seq" );
        push @alignment, "\n";
    }

    if ( defined($right_probe_match) ) {
        my $right_probe_padding = $subject_hash{$right_probe_match}->{column};
        push @alignment, sprintf( "%${p}s", "PROBE " );
        push @alignment, "" . " " x ($right_probe_padding);
        push @alignment, "$right_probe_seq";
        push @alignment, "\n";
    }

    my @ruler = ();
    for ( my $i = 0 ; $i < scalar( keys(%column_hash) ) ; $i++ ) {
        push @ruler, $column_hash{$i}->{ruler_char};
    }

    push @alignment, sprintf( "%${p}s", "$subject_start " );
    push @alignment, sprintf( "%${p}s", join "", @ruler );
    push @alignment, "\n";

    #*******************************************
    #set alignment type and return alignment
    if ( !defined($subject_variant_position_string_coord) ) {
        push @alignment, "Determination type: 'UNDETERMINED'\n";
        $result{alignment} = join "", @alignment;
        return \%result;
    }

    my $reference_genome_position =
      $subject_hash{$subject_variant_position_string_coord}
      ->{position_chromosome};
    my $reference_genome_allele;

    if ( $variant_type eq 'SNP' ) {
        $reference_genome_allele =
          $subject_hash{$subject_variant_position_string_coord}->{base};
    }
    elsif ( $variant_type eq 'INDEL' ) {
        if ( length($indel_ref) > length($indel_alt) ) {
            $reference_genome_allele = 'I';
        }
        elsif ( length($indel_ref) < length($indel_alt) ) {
            $reference_genome_allele = 'D';
        }
    }

    push @alignment, sprintf( "%${p}s", "ALLELE1 " );
    push @alignment, sprintf( "%${c}s", "$allele1" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s", "ALLELE2 " );
    push @alignment, sprintf( "%${c}s", "$allele2" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s", "POSITION " );
    push @alignment, sprintf( "%${c}s", "$reference_genome_position|" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s", "REF " );
    push @alignment, sprintf( "%${c}s", "$reference_genome_allele" );
    push @alignment, "\n";

    my $VCF_REF;
    my $VCF_ALT;

    if ( $variant_type eq 'SNP' ) {
        if ( $reference_genome_allele eq $allele1 ) {
            $VCF_REF = $allele1;
            $VCF_ALT = $allele2;
        }
        elsif ( $reference_genome_allele eq $allele2 ) {
            $VCF_REF = $allele2;
            $VCF_ALT = $allele1;
        }
        else {
            $VCF_REF = $reference_genome_allele;
            $VCF_ALT = $allele1 . '/' . $allele2;
        }
    }
    elsif ( $variant_type eq 'INDEL' ) {
        $VCF_REF = $indel_ref;
        $VCF_ALT = $indel_alt;
    }

    push @alignment, sprintf( "%${p}s", "VCF_REF " );
    push @alignment, sprintf( "%${c}s", "$VCF_REF" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${p}s", "VCF_ALT " );
    push @alignment, sprintf( "%${c}s", "$VCF_ALT" );
    push @alignment, "\n";

    push @alignment, "Determination type: $determination_type\n";

    my $alignment = join "", @alignment;
    $result{position}       = $reference_genome_position;
    $result{reference_base} = $reference_genome_allele;
    $result{VCF_REF}        = $VCF_REF;
    $result{VCF_ALT}        = $VCF_ALT;
    $result{alignment}      = $alignment;

    return \%result;
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
            if ( scalar(@values) > scalar(@columns) ) {
                print Dumper(@values);
                die(
"Extra columns encountered when parsing line in file '$file'"
                );
            }
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
