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

#subject_id is text before first white space, or text before second | character
#salltitles is text after subject_id in FASTA title
#Example FASTA titles (note that white space will be replaced by underscore)
#>gnl|UMD3.1|GJ057971.1 GPS_000342411.1 NW_003098716.1
#>NKLS02000031.1 Bos taurus breed Hereford isolate L1 Dominette 01449 registration number 42190680 Leftover_ScbfJmS_1, whole genome shotgun sequence
#>JH118944.1 dna:scaffold scaffold:Sscrofa10.2:JH118944.1:1:594937:1 REF
#>9 dna:chromosome chromosome:Sscrofa10.2:9:1:153670197:1 REF
#>MT dna:chromosome chromosome:Sscrofa10.2:MT:1:16613:1 REF
#>X dna:primary_assembly primary_assembly:USMARCv1.0:X:1:126604238:1 REF
#>Y dna:primary_assembly primary_assembly:USMARCv1.0:Y:1:36677040:1 REF
#>NPJO01000021.1 dna:primary_assembly primary_assembly:USMARCv1.0:NPJO01000021.1:1:3171300:1 REF
#>gnl|UMD3.1|GK000007.2 Chromosome 7 AC_000164.1
#>gnl|UMD3.1|GK000008.2 Chromosome 8 AC_000165.1
#>gnl|UMD3.1|GK000009.2 Chromosome 9 AC_000166.1
#>gnl|UMD3.1|AY526085.1 Chromosome MT NC_006853.1
#>gnl|UMD3.1|GJ057185.1 GPS_000341625.1 NW_003097930.1
#>gnl|UMD3.1|GJ057186.1 GPS_000341626.1 NW_003097931.1
#>gnl|UMD3.1|GJ057187.1 GPS_000341627.1 NW_003097932.1

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

    my $is_snp;
    if ( ( $h->{allele1} ne '-' ) && ( $h->{allele2} ne '-' ) ) {
        $is_snp = 1;
    }
    else {
        $is_snp = 0;
    }

#if the query does not contain the SNP site then the position cannot be determined
    if ( !( $h->{query_seq} =~ m/N/i ) ) {
        return \%result;
    }

    my $column_width = 12;

    my @alignment = ();

    push @alignment, "$h->{query_id}\n";

    if ($is_snp) {
        push @alignment, "Type: SNP\n";
    }
    else {
        push @alignment, "Type: INDEL\n";
    }

    push @alignment, sprintf( "%${column_width}s", "QUERY " );
    push @alignment, "$h->{query_seq}\n";

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

    #Determining position counting from the left side, not counting N
    #>>>>>>>>>N
    #1234567890
    #=Start + Length - 1 = 1 + 9 - 1 = 9
    my $subject_position_left_of_variant =
      $h->{s_start} + $subject_bases_from_left - 1;

    push @alignment, sprintf( "%${column_width}s", "TO LEFT " );
    push @alignment,
      sprintf( "%${query_chars_from_left}s",
        "${subject_position_left_of_variant}|" );
    push @alignment, "\n";

    push @alignment, sprintf( "%${column_width}s", "$h->{s_start} " );
    push @alignment, "$h->{subject_seq} ";
    push @alignment, "$h->{s_end}\n";

    if ( defined( $h->{probe_seq} ) ) {
        if ( $h->{probe_side} eq 'LEFT' ) {
            $h->{probe_seq} = ">>>";
            push @alignment, sprintf( "%${column_width}s", "PROBE " );
            push @alignment,
              sprintf( "%${query_chars_from_left}s", "$h->{probe_seq}" );
            push @alignment, "\n";
        }
        elsif ( $h->{probe_side} eq 'RIGHT' ) {
            $h->{probe_seq} = "<<<";
            push @alignment, sprintf( "%${column_width}s", "PROBE " );
            push @alignment, "" . " " x ( $query_chars_from_left + 1 );
            push @alignment, "$h->{probe_seq}\n";
        }
    }

    my $position       = '?';
    my $reference_base = '?';

    my $subject_base_aligned_with_variant =
      substr( $h->{subject_seq}, $query_chars_from_left, 1 );

    if ($is_snp) {
        if ( $subject_base_aligned_with_variant =~ m/[GATCN]/ ) {

#ARS-BFGL-NGS-107346
#Type: SNP
#      QUERY CTCTACCATCTCCCTCACCCGCTCAGCCCTTTGAGGCCTTTGTATATAAGGTTCACCTGGNAAACAGGGGTATAGCGACTCAACTTACAGCACTGCCCATGATGGAGCTTTTGTTTCTCCA
#    TO LEFT                                                    48625185|
#   48625126 CTCTACCATCTCCCTCACCCGCTCAGCCCTTTGAGGCCTTTGTATATAAGGTTCACCTGGGAAACAGGGGTATAGCGACTCAACTTACAGCACTGCCCATGATGGAGCTTTTGTTTCTCCA 48625246
#      PROBE                                                              <<<
#      RULER     |         |         |         |         |         |
#    ALLELE1                                                             A
#    ALLELE2                                                             G
#   POSITION                                                     48625186|
#        REF                                                             G
#    VCF_REF                                                             G
#    VCF_ALT                                                             A

            $position       = $subject_position_left_of_variant + 1;
            $reference_base = $subject_base_aligned_with_variant;
        }
        elsif ( $subject_base_aligned_with_variant eq '-' ) {

            if ( defined( $h->{probe_side} ) ) {

                if ( $h->{probe_side} eq 'LEFT' ) {

#Hapmap44331-BTA-99326
#Type: SNP
#      QUERY CTGGGAATCTGGCCTGAGGAGCCTTGCTCTTAAATTCTAGAGAATGAATGGAGCAAGTAANAAATTTGGCATAATAATTTATTTCATAGTGGTCTTATTGCAGAGCCTCAGAGAAATGTGG
#    TO LEFT                                                     8063025|
#    8062966 CTGGGAATCTGGCCTGAGGAGCCTTGCTCTTAAATTCTAGAGAATGAATGGAGCAAGTAA-AAATTTGGCATAATAATTTATTTCATAGTGGTCTTATTGCAGAGCCTCAGAGAAATGTGG 8063085
#      PROBE                                                          >>>
#      RULER     |         |         |         |         |         |
#    ALLELE1                                                              G
#    ALLELE2                                                              A
#   POSITION                                                       8063026|
#        REF                                                              A
#    VCF_REF                                                              A
#    VCF_ALT                                                              G

             #probe could be assaying base 3' to current position (to the right)
                    $position = $subject_position_left_of_variant + 1;

                    #scan along subject until next non-gap is obtained
                    my $char_pos = $query_chars_from_left;
                    while (( $reference_base eq '?' )
                        && ( $char_pos < length( $h->{subject_seq} ) ) )
                    {
                        $char_pos++;
                        if ( substr( $h->{subject_seq}, $char_pos, 1 ) ne '-' )
                        {
                            $reference_base =
                              substr( $h->{subject_seq}, $char_pos, 1 );
                            last;
                        }
                    }

                }

                if ( $h->{probe_side} eq 'RIGHT' ) {

#BTA-01291-no-rs
#Type: SNP
#      QUERY GAGCCATCTGTGAAGGAGACACGCCAAATACATATTTTATATGAGTTGTTTTTTTTTTTTNCCTTTTTAAAGGAATATGACAACTCAACCAAAAGTGTGCGGGATCAGTTAAAAGAACTGT
#    TO LEFT                                                    49751560|
#   49751501 GAGCCATCTGTGAAGGAGACACGCCAAATACATATTTTATATGAGTTGTTTTTTTTTTTT-CCTTTTTAAAGGAATATGACAACTCAACCAAAAGTGTGCGGGATCAGTTAAAAGAACTGT 49751620
#      PROBE                                                              <<<
#      RULER          |         |         |         |         |         |
#    ALLELE1                                                            C
#    ALLELE2                                                            T
#   POSITION                                                    49751560|
#        REF                                                            T
#    VCF_REF                                                            T
#    VCF_ALT                                                            C

              #probe could be assaying base 3' to current position (to the left)
                    $position = $subject_position_left_of_variant;
                    my $char_pos = $query_chars_from_left;
                    while (( $reference_base eq '?' )
                        && ( $char_pos > 0 ) )
                    {
                        $char_pos--;
                        if ( substr( $h->{subject_seq}, $char_pos, 1 ) ne '-' )
                        {
                            $reference_base =
                              substr( $h->{subject_seq}, $char_pos, 1 );
                            last;
                        }
                    }

                }

            }
            else {
                #No probe information

                #Examine base to the right and base to the left
                #Then choose the position that gives most consistent genotype
                my $position_to_the_right =
                  $subject_position_left_of_variant + 1;
                my $reference_base_to_the_right = '?';
                my $position_to_the_left = $subject_position_left_of_variant;
                my $reference_base_to_the_left = '?';
                my $char_pos;

                #Position to the right
                $char_pos = $query_chars_from_left;
                while (( $reference_base_to_the_right eq '?' )
                    && ( $char_pos < length( $h->{subject_seq} ) ) )
                {
                    $char_pos++;
                    if ( substr( $h->{subject_seq}, $char_pos, 1 ) ne '-' ) {
                        $reference_base_to_the_right =
                          substr( $h->{subject_seq}, $char_pos, 1 );
                        last;
                    }
                }

                #Position to the left
                $char_pos = $query_chars_from_left;
                while (( $reference_base_to_the_left eq '?' )
                    && ( $char_pos > 0 ) )
                {
                    $char_pos--;
                    if ( substr( $h->{subject_seq}, $char_pos, 1 ) ne '-' ) {
                        $reference_base_to_the_left =
                          substr( $h->{subject_seq}, $char_pos, 1 );
                        last;
                    }
                }

                #Compare reference bases to the alleles
                my $left_is_consistent  = 0;
                my $right_is_consistent = 0;
                if (   ( $reference_base_to_the_left eq $h->{allele1} )
                    || ( $reference_base_to_the_left eq $h->{allele2} ) )
                {
                    $left_is_consistent = 1;
                }
                if (   ( $reference_base_to_the_right eq $h->{allele1} )
                    || ( $reference_base_to_the_right eq $h->{allele2} ) )
                {
                    $right_is_consistent = 1;
                }

                if ($left_is_consistent) {
                    $position       = $position_to_the_left;
                    $reference_base = $reference_base_to_the_left;
                }
                elsif ($right_is_consistent) {
                    $position       = $position_to_the_right;
                    $reference_base = $reference_base_to_the_right;
                }
                else {
                    $position       = $position_to_the_left;
                    $reference_base = $reference_base_to_the_left;
                }
            }
        }
    }

#Is indel
#For indels report the position as the base immediately before the insertion or deletion.
#Also, consider equivalent insertions or deletions and choose the leftmost.
#For example consider this sequence:
#TACGGGGTACC
#A single-base deletion of 'G' could occur at any of the four Gs.
#However, from a DNA-interpretation standpoint they are all eqivalent because they yield the same molecule.
#To reflect this equivalence, report the deletion as involving the leftmost 'G'.
#Further, to be consistent with positioning in the VCF file, report the position as the base to the left of the event.
    else {

        if ( $subject_base_aligned_with_variant =~ m/[GATCN]/ ) {

#MC1R
#Type: INDEL
#      QUERY TCTGCTGCCTGGCTGTGTCTGACTTGCTGGTGAGCGTCAGCAACGTGCTGGAGACGGCAGTCATGCTGCTGCTGGAGGCCNGTGTCCTGGCCACCCAGGCGGCCGTGGTGCAGCAGCTGGACAATGTCATCGACGTGCTCATCTGCGGATCCATGGTGTCC
#    TO LEFT                                                                        14705684|
#   14705605 TCTGCTGCCTGGCTGTGTCTGACTTGCTGGTGAGCGTCAGCAACGTGCTGGAGACGGCAGTCATGCTGCTGCTGGAGGCCGGTGTCCTGGCCACCCAGGCGGCCGTGGTGCAGCAGCTGGACAATGTCATCGACGTGCTCATCTGCGGATCCATGGTGTCC 14705765
#      PROBE                                                                              >>>
#      RULER      |         |         |         |         |         |         |         |
#    ALLELE1                                                                                -
#    ALLELE2                                                                                G
#   POSITION                                                                        14705684|
#        REF                                                                                I
#    VCF_REF                                                                               CG
#    VCF_ALT                                                                                C

#MRC2_2
#Type: INDEL
#      QUERY TCACTTTTCACAGAGGACTGGGGGGACCAGAGGTGCACAACAGCCTTGCCTTACATCTGCAAGCGGCGCAACAGCACCAG-NAGCAGCAGCCCCCAGACCTGCCGCCCACAGGGGGCTGCCCCTCTGGCTGGAGCCAGTTCCTGAACAAGGTAGGGAGTAG
#    TO LEFT                                                                         47095146|
#   47095066 TCACTTTTCACAGAGGACTGGGGGGACCAGAGGTGCACAACAGCCTTGCCTTACATCTGCAAGCGGCGCAACAGCACCAGAGAGCAGCAGCCCCCAGACCTGCCGCCCACAGGGGGCTGCCCCTCTGGCTGGAGCCAGTTCCTGAACAAGGTAGGGAGTAG 47095226
#      PROBE                                                                               >>>
#      RULER     |         |         |         |         |         |         |         |
#    ALLELE1                                                                              -
#    ALLELE2                                                                             AG
#   POSITION                                                                      47095143|
#        REF                                                                              I
#    VCF_REF                                                                            CAG
#    VCF_ALT                                                                              C

#PMEL_1
#Type: INDEL
#      QUERY AGAGTCTTTGGTTGCTGGAAGGAAGAACAGGATGGATCTGGTGCTGAGAAAATACCTTCTCCATGTGGCTCTGATGGGTG--NTTCTGGCTGTAGGGACCACAGAAGGTGAGTGTGGGATGTTGGACATGAACAAGTGTGAATTTGGGGTTGCACACCTGC
#    TO LEFT                                                                          57345302|
#   57345221 AGAGTCTTTGGTTGCTGGAAGGAAGAACAGGATGGATCTGGTGCTGAGAAAATACCTTCTCCATGTGGCTCTGATGGGTGTTCTTCTGGCTGTAGGGACCACAGAAGGTGAGTGTGGGATGTTGGACATGAACAAGTGTGAATTTGGGGTTGCACACCTGC 57345381
#      PROBE                                                                                >>>
#      RULER          |         |         |         |         |         |         |         |
#    ALLELE1                                                                                -
#    ALLELE2                                                                              TTC
#   POSITION                                                                        57345300|
#        REF                                                                                I
#    VCF_REF                                                                             GTTC
#    VCF_ALT                                                                                G

            #ref genome probably has insertion allele
            $reference_base = 'I';

            #position is tricky, use the first base to the left of the variant
            $position = $subject_position_left_of_variant;
            my $char_pos = $query_chars_from_left;
            while (( $reference_base eq '?' )
                && ( $char_pos > 0 ) )
            {
                $char_pos--;
                if ( substr( $h->{subject_seq}, $char_pos, 1 ) ne '-' ) {
                    $reference_base = substr( $h->{subject_seq}, $char_pos, 1 );
                    last;
                }
            }
            my $subject_chars_to_and_including_n =
              substr( $h->{subject_seq}, 0, $query_chars_from_left + 1 );
            my $shift_left = left_normalize( $h->{allele1}, $h->{allele2},
                $subject_chars_to_and_including_n );

            $position = $position - $shift_left;

        }
        elsif ( $subject_base_aligned_with_variant eq '-' ) {

#TYR
#Type: INDEL
#      QUERY CAGCTTTATCCATGGAACCTGATTCATACTGGGTCAAACTCAGGCAAAACTCCACATCAGCCGAGGAGGGGAGCCTCGGGGNTCCTGGCTTTGTCGTGGTTTCCAGGATTGCGCAGTAATGGTCCCTCAGACGTCCCGTTGCATAAAGCCTGGCGACTGTTG
#    TO LEFT                                                                          6424971|
#    6424891 CAGCTTTATCCATGGAACCTGATTCATACTGGGTCAAACTCAGGCAAAACTCCACATCAGCCGAGGAGGGGAGCCTCGGGG-TCCTGGCTTTGTCGTGGTTTCCAGGATTGCGCAGTAATGGTCCCTCAGACGTCCCGTTGCATAAAGCCTGGCGACTGTTG 6425051
#      PROBE                                                                               >>>
#      RULER          |         |         |         |         |         |         |
#    ALLELE1                                                                             -
#    ALLELE2                                                                             G
#   POSITION                                                                      6424967|
#        REF                                                                             D
#    VCF_REF                                                                             C
#    VCF_ALT                                                                            CG

#F11
#Type: INDEL
#      QUERY AGTCACCTAATGTGTTGCGTGTCTATAGCGGCATTTTGAATCAATCAGAAATAAAAGAGGATACATCTTTCTTTGGGGTTCAAGAAATAATAATTCANTGATCAATATGAAAAGGCAGAAAGTGGATATGACATTGCCTTGTTGAAACTAGAAA--GCAATGAATTATACAGGTATGGGAAACTTTAAACAGAACGTTGTCTACAGTGATGCCGGGCTTCACACTCCCA
#    TO LEFT                                                                                         16310345|
#   16310249 AGTCACCTAATGTGTTGCGTGTCTATAGCGGCATTTTGAATCAATCAGAAATAAAAGAGGATACATCTTTCTTTGGGGTTCAAGAAATAATAATTCA-TGATCAATATGAAAAGGCAGAAAGTGGATATGACATTGCCTTGTTGAAACTAGAAACGGCAATGAATTATACAGGTATGGGAAACTTTAAACAGAACGTTGTCTACAGTGATGCCGGGCTTCACACTCCCA 16310476
#      PROBE                                                                                                   <<<
#      RULER  |         |         |         |         |         |         |         |         |         |
#    ALLELE1                                                                                                 -
#    ALLELE2                      ATAAAAAAAAAAAAAAAAAAAAAAAAAAAATAAAGAAAAAAAAAAAAAAAAAAAAAAAAAAGGAAATAATAATTCA
#   POSITION                                                                                         16310345|
#        REF                                                                                                 D
#    VCF_REF                                                                                                 A
#    VCF_ALT                     AATAAAAAAAAAAAAAAAAAAAAAAAAAAAATAAAGAAAAAAAAAAAAAAAAAAAAAAAAAAGGAAATAATAATTCA

            #ref genome probably has deletion allele
            $reference_base = 'D';

            #position is tricky, use the first base to the left of the variant
            $position = $subject_position_left_of_variant;
            my $char_pos = $query_chars_from_left;
            while (( $reference_base eq '?' )
                && ( $char_pos > 0 ) )
            {
                $char_pos--;
                if ( substr( $h->{subject_seq}, $char_pos, 1 ) ne '-' ) {
                    $reference_base = substr( $h->{subject_seq}, $char_pos, 1 );
                    last;
                }
            }

            my $subject_chars_to_and_including_n =
              substr( $h->{subject_seq}, 0, $query_chars_from_left + 1 );
            my $shift_left = left_normalize( $h->{allele1}, $h->{allele2},
                $subject_chars_to_and_including_n );

            $position = $position - $shift_left;
        }

    }

    if ( $position ne '?' ) {

        my $subject_bases_from_left_to_position = $position - $h->{s_start} + 1;
        my $char_count                          = 0;
        my $base_count                          = 0;
        my $current_position                    = $h->{s_start};
        my @ruler                               = ();
        my $ref_base_at_position                = undef;
        for my $c ( split //, $h->{subject_seq} ) {
            $char_count++;
            if ( $current_position % 10 == 0 ) {
                push @ruler, "|";
            }
            else {
                push @ruler, " ";
            }
            if ( $c =~ m/[GATCN]/i ) {
                $base_count++;
                $current_position++;
            }
            if ( $base_count == $subject_bases_from_left_to_position ) {
                $ref_base_at_position = $c;
                last;
            }
        }

        push @alignment, sprintf( "%${column_width}s", "RULER " );
        push @alignment, sprintf( "%${char_count}s", join "", @ruler );
        push @alignment, "\n";

        push @alignment, sprintf( "%${column_width}s", "ALLELE1 " );
        push @alignment, sprintf( "%${char_count}s",   "$h->{allele1}" );
        push @alignment, "\n";

        push @alignment, sprintf( "%${column_width}s", "ALLELE2 " );
        push @alignment, sprintf( "%${char_count}s",   "$h->{allele2}" );
        push @alignment, "\n";

        push @alignment, sprintf( "%${column_width}s", "POSITION " );
        push @alignment, sprintf( "%${char_count}s",   "$position|" );
        push @alignment, "\n";

        push @alignment, sprintf( "%${column_width}s", "REF " );
        push @alignment, sprintf( "%${char_count}s",   "$reference_base" );
        push @alignment, "\n";

        #store alleles as they would appear in VCF, as VCF_REF and VCF_ALT
        if ($is_snp) {
            if ( $reference_base eq $h->{allele1} ) {
                $result{VCF_REF} = $h->{allele1};
                $result{VCF_ALT} = $h->{allele2};
            }
            elsif ( $reference_base eq $h->{allele2} ) {
                $result{VCF_REF} = $h->{allele2};
                $result{VCF_ALT} = $h->{allele1};
            }
            else {
                $result{VCF_REF} = $reference_base;
                $result{VCF_ALT} = $h->{allele1} . '/' . $h->{allele2};
            }
        }

      #for indels determine VCF_REF and VCF_ALT, which represent alleles as they
      #would appear in VCF
        elsif ( !($is_snp) ) {
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
                $result{VCF_REF} = $ref_base_at_position;
                $result{VCF_ALT} = $ref_base_at_position . $i_allele;
            }
            elsif ( $reference_base eq 'I' ) {
                $result{VCF_REF} = $ref_base_at_position . $i_allele;
                $result{VCF_ALT} = $ref_base_at_position;
            }
        }

        push @alignment, sprintf( "%${column_width}s", "VCF_REF " );
        push @alignment, sprintf( "%${char_count}s",   "$result{VCF_REF}" );
        push @alignment, "\n";

        push @alignment, sprintf( "%${column_width}s", "VCF_ALT " );
        push @alignment, sprintf( "%${char_count}s",   "$result{VCF_ALT}" );
        push @alignment, "\n";

    }
    else {
        push @alignment, sprintf( "%${column_width}s", "POSITION " );
        push @alignment, "?\n";

        push @alignment, sprintf( "%${column_width}s", "REF " );
        push @alignment, "?\n";

    }

    $result{alignment} = join "", @alignment;

    $result{position}       = $position;
    $result{reference_base} = $reference_base;

    return \%result;
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
        @values = split( /\,/, $line );
    }
    foreach (@values) {
        $_ = clean_value($_);
    }
    return \@values;
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
