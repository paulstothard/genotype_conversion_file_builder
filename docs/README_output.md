# genotype\_conversion\_file\_builder

## Output

### Position file

The **position** file describes the location of each marker on the new
reference genome.

There is one data row per marker in the input manifest file.

The columns are as follows:

* **marker\_name** - the name of the marker, from the manifest file.
* **alt\_marker\_name** - the additional name of the marker, from the manifest
  file.
* **chromosome** - the chromosome containing the marker, determined using
  BLAST.
* **position** - the position of the marker on the chromosome, determined using
  BLAST.
* **VCF\_REF** - the allele observed on the forward strand of the reference
  genome at this position. This allele is extracted from the reference genome
sequence. In the vast majority of cases this allele matches one of the two
alleles described in the manifest file when they are transformed to the forward
strand of the reference genome (referred to as the PLUS format in the
conversion file).
* **VCF\_ALT** - the marker allele(s) described in the manifest file and
  transformed to the forward strand of the reference that are not observed in
the reference genome. In most cases there is one allele in this column,
corresponding to the marker allele not detected in the reference genome
sequence. In cases where neither allele is observed in the reference genome
sequence, both alleles appear here, separated by a forward slash, e.g. "A/G".

**Note**: Indel positions and alleles are described according to the [VCF
specification](https://samtools.github.io/hts-specs/VCFv4.2.pdf).

**Note**: In cases where the SNP aligns with a gap in the reference genome,
probe information in the manifest file is examined to determine whether the
base on the left or right side of the gap is assayed by the probe, and the
position and reference base are selected accordingly. In cases where probe
information is not available, the reference-genome bases to the left and right
of the gap(s) are examined. If the left base matches one of the
forward-strand-transformed SNP alleles, it is selected as **VCF\_REF** and its
position is used as the position value. If the left base does not match one of
the forward-strand-transformed SNP alleles but the right base does, the right
base is selected as **VCF\_REF** and its position is used. If neither the left
or right bases match, the left base and position are used. The optional
**alignment** file output can be viewed for any marker to see how position and
allele information were derived from the BLAST results and probe information.

#### Sample position file content

```
marker_name,alt_marker_name,chromosome,position,VCF_REF,VCF_ALT
ABCA12,ABCA12_r2-1_T_F_2277749139,2,103030489,T,C
APAF1,APAF1_dup-1_B_F_2327661418,5,62810245,C,T
ARS-BFGL-BAC-10172,ARS-BFGL-BAC-10172_dup-0_T_F_2328966397,14,5342658,C,T
ARS-BFGL-BAC-1020,ARS-BFGL-BAC-1020-0_B_R_1511662870,14,6889656,T,C
ARS-BFGL-BAC-10245,ARS-BFGL-BAC-10245-0_B_F_1511658502,14,30124134,G,A
ARS-BFGL-BAC-10345,ARS-BFGL-BAC-10345_dup-0_T_F_2328966403,14,5105727,T,G
ARS-BFGL-BAC-10375,ARS-BFGL-BAC-10375_dup-0_T_F_2328966405,14,5587750,G,A
ARS-BFGL-BAC-10591,ARS-BFGL-BAC-10591_dup-0_T_F_2328966407,14,15956824,A,G
ARS-BFGL-BAC-10867,ARS-BFGL-BAC-10867-0_B_F_1511658130,14,32554055,C,G
ARS-BFGL-BAC-10919,ARS-BFGL-BAC-10919-0_T_F_1511658221,14,29573682,T,C
```

### Conversion file

The **conversion** file describes how genotypes can be converted from one
format to another, including to the forward strand of the reference genome
(i.e. the PLUS format).

There are two data rows per marker.

One row contains the various representations of allele A ('allele A' referring
to 'allele A' in Illumina's A/B allele nomenclature), while the other contains
the various representations of allele B ('allele B' referring to 'allele B' in
Illumina's A/B allele nomenclature).

The columns are as follows:

* **marker\_name** - the name of the marker, from the manifest file.
* **alt\_marker\_name** - the additional name of the marker, from the manifest
  file.
* **AB** - the allele in Illumina's A/B format. This value is always **A** or
  **B** for SNPs.
* **TOP** - the allele in Illumina's TOP format.
* **FORWARD** - the allele in Illumina's FORWARD format.
* **DESIGN** - the allele in Illumina's DESIGN format.
* **PLUS** - the allele in Illumina's PLUS format. This value is not parsed
  from the manifest file but instead determined by a BLAST alignment between
the variant flanking sequence and the reference genome. This value represents
how the allele would appear following transformation to the forward strand of
the reference genome. Note that this value does not indicate whether the
reference genome sequence actually contains this allele.
* **VCF** - a value of **REF** in this column indicates that this allele
  appears on the forward strand of the reference genome, while a value of
**ALT** indicates that it does not.

**Note**: To transform a marker's genotype from one representation to another
(e.g. a genotype of 'GC' for marker 'ARS-BFGL-BAC-10867' in 'FORWARD' format to
'TOP' format):

1. Find the two rows for marker 'ARS-BFGL-BAC-10867'.
2. Examine the 'FORWARD' column in the two rows from step 1 to find the row
   where the value of 'FORWARD' is 'G': the 'TOP' transformation is simply the
value in the 'TOP' column of this row.
3. Examine the 'FORWARD' column in the two rows from step 1 to find the row
   where the value of 'FORWARD' is 'C': the 'TOP' transformation is simply the
value in the 'TOP' column of this row.

**Note**: the TOP, FORWARD, and DESIGN values are not provided for Affymetrix
panels.

**Note**: Indel alleles in the TOP, FORWARD, DESIGN, and PLUS columns are given
as D (deletion) or I (insertion).

#### Sample conversion file content

```
marker_name,alt_marker_name,AB,TOP,FORWARD,DESIGN,PLUS,VCF
ABCA12,ABCA12_r2-1_T_F_2277749139,A,A,A,A,T,REF
ABCA12,ABCA12_r2-1_T_F_2277749139,B,G,G,G,C,ALT
APAF1,APAF1_dup-1_B_F_2327661418,A,A,T,T,T,ALT
APAF1,APAF1_dup-1_B_F_2327661418,B,G,C,C,C,REF
ARS-BFGL-BAC-10172,ARS-BFGL-BAC-10172_dup-0_T_F_2328966397,A,A,A,A,T,ALT
ARS-BFGL-BAC-10172,ARS-BFGL-BAC-10172_dup-0_T_F_2328966397,B,G,G,G,C,REF
ARS-BFGL-BAC-1020,ARS-BFGL-BAC-1020-0_B_R_1511662870,A,A,A,T,T,REF
ARS-BFGL-BAC-1020,ARS-BFGL-BAC-1020-0_B_R_1511662870,B,G,G,C,C,ALT
ARS-BFGL-BAC-10245,ARS-BFGL-BAC-10245-0_B_F_1511658502,A,A,T,T,A,ALT
ARS-BFGL-BAC-10245,ARS-BFGL-BAC-10245-0_B_F_1511658502,B,G,C,C,G,REF
ARS-BFGL-BAC-10345,ARS-BFGL-BAC-10345_dup-0_T_F_2328966403,A,A,A,A,T,REF
ARS-BFGL-BAC-10345,ARS-BFGL-BAC-10345_dup-0_T_F_2328966403,B,C,C,C,G,ALT
ARS-BFGL-BAC-10375,ARS-BFGL-BAC-10375_dup-0_T_F_2328966405,A,A,A,A,A,ALT
ARS-BFGL-BAC-10375,ARS-BFGL-BAC-10375_dup-0_T_F_2328966405,B,G,G,G,G,REF
ARS-BFGL-BAC-10591,ARS-BFGL-BAC-10591_dup-0_T_F_2328966407,A,A,A,A,A,REF
ARS-BFGL-BAC-10591,ARS-BFGL-BAC-10591_dup-0_T_F_2328966407,B,G,G,G,G,ALT
ARS-BFGL-BAC-10867,ARS-BFGL-BAC-10867-0_B_F_1511658130,A,C,G,G,G,ALT
ARS-BFGL-BAC-10867,ARS-BFGL-BAC-10867-0_B_F_1511658130,B,G,C,C,C,REF
ARS-BFGL-BAC-10919,ARS-BFGL-BAC-10919-0_T_F_1511658221,A,A,A,A,T,REF
ARS-BFGL-BAC-10919,ARS-BFGL-BAC-10919-0_T_F_1511658221,B,G,G,G,C,ALT
```

### Wide file

The **wide** file describes the location of each marker on the new reference
genome, and provides the various representations of the A and B alleles.

There is one data row per marker in the input manifest file.

The columns are as follows:

* **marker\_name** - the name of the marker, from the manifest file.
* **alt\_marker\_name** - the additional name of the marker, from the manifest
  file.
* **chromosome** - the chromosome containing the marker, determined using
  BLAST.
* **position** - the position of the marker on the chromosome, determined using
  BLAST.
* **VCF\_REF** - the allele observed on the forward strand of the reference
  genome at this position. This allele is extracted from the reference genome
sequence. In the vast majority of cases this allele matches one of the two
alleles described in the manifest file when they are transformed to the forward
strand of the reference genome (referred to as the PLUS format in the
conversion file).
* **VCF\_ALT** - the marker allele(s) described in the manifest file and
  transformed to the forward strand of the reference that are not observed in
the reference genome. In most cases there is one allele in this column,
corresponding to the marker allele not detected in the reference genome
sequence. In cases where neither allele is observed in the reference genome
sequence, both alleles appear here, separated by a forward slash, e.g. "A/G".
* **AB_A** - the A allele in Illumina's A/B format. This value is always **A**
  for SNPs.
* **AB_B** - the B allele in Illumina's A/B format. This value is always **B**
  for SNPs.
* **TOP_A** - the A allele in Illumina's TOP format.
* **TOP_B** - the B allele in Illumina's TOP format.
* **FORWARD_A** - the A allele in Illumina's FORWARD format.
* **FORWARD_B** - the B allele in Illumina's FORWARD format.
* **DESIGN_A** - the A allele in Illumina's DESIGN format.
* **DESIGN_B** - the A allele in Illumina's DESIGN format.
* **PLUS_A** - the A allele in Illumina's PLUS format. This value is not parsed
  from the manifest file but instead determined by a BLAST alignment between
the variant flanking sequence and the reference genome. This value represents
how the allele would appear following transformation to the forward strand of
the reference genome. Note that this value does not indicate whether the
reference genome sequence actually contains this allele.
* **PLUS_B** - the B allele in Illumina's PLUS format. This value is not parsed
  from the manifest file but instead determined by a BLAST alignment between
the variant flanking sequence and the reference genome. This value represents
how the allele would appear following transformation to the forward strand of
the reference genome. Note that this value does not indicate whether the
reference genome sequence actually contains this allele.
* **VCF_A** - a value of **REF** in this column indicates that the A allele
  appears on the forward strand of the reference genome, while a value of
**ALT** indicates that it does not.
* **VCF_B** - a value of **REF** in this column indicates that the A allele
  appears on the forward strand of the reference genome, while a value of
**ALT** indicates that it does not.

**Note**: Indel positions and alleles are described according to the [VCF
specification](https://samtools.github.io/hts-specs/VCFv4.2.pdf).

**Note**: In cases where the SNP aligns with a gap in the reference genome,
probe information in the manifest file is examined to determine whether the
base on the left or right side of the gap is assayed by the probe, and the
position and reference base are selected accordingly. In cases where probe
information is not available, the reference-genome bases to the left and right
of the gap(s) are examined. If the left base matches one of the
forward-strand-transformed SNP alleles, it is selected as **VCF\_REF** and its
position is used as the position value. If the left base does not match one of
the forward-strand-transformed SNP alleles but the right base does, the right
base is selected as **VCF\_REF** and its position is used. If neither the left
or right bases match, the left base and position are used. The optional
**alignment** file output can be viewed for any marker to see how position and
allele information were derived from the BLAST results and probe information.

**Note**: To transform a marker's genotype from one representation to another
(e.g. a genotype of 'GC' for marker 'ARS-BFGL-BAC-10867' in 'FORWARD' format to
'TOP' format):

1. Find the row for marker 'ARS-BFGL-BAC-10867'.
2. Examine the 'FORWARD\_A' and 'FORWARD\_B' columns in the row from step 1 to
   determine which contains 'G': if it is the 'FORWARD\_A' column then the
'TOP' transformation is the value in the 'TOP\_A' column of this row; if it is
the 'FORWARD\_B' column then the 'TOP' transformation is the value given in the
'TOP\_B' column.
3. Examine the 'FORWARD\_A' and 'FORWARD\_B' columns in the row from step 1 to
   determine which contains 'C': if it is the 'FORWARD\_A' column then the
'TOP' transformation is the value in the 'TOP\_A' column of this row; if it is
the 'FORWARD\_B' column then the 'TOP' transformation is the value given in the
'TOP\_B' column.

Note: Indel alleles in the AB\_A, AB\_B, TOP\_A, TOP\_B, FORWARD\_A,
FORWARD\_B, DESIGN\_A, DESIGN\_B, PLUS\_A, and PLUS\_B columns are given as D
(deletion) or I (insertion).

#### Sample wide file content

```
marker_name,alt_marker_name,chromosome,position,VCF_REF,VCF_ALT,AB_A,AB_B,TOP_A,TOP_B,FORWARD_A,FORWARD_B,DESIGN_A,DESIGN_B,PLUS_A,PLUS_B,VCF_A,VCF_B
ABCA12,ABCA12_r2-1_T_F_2277749139,2,103030489,T,C,A,B,A,G,A,G,A,G,T,C,REF,ALT
APAF1,APAF1_dup-1_B_F_2327661418,5,62810245,C,T,A,B,A,G,T,C,T,C,T,C,ALT,REF
ARS-BFGL-BAC-10172,ARS-BFGL-BAC-10172_dup-0_T_F_2328966397,14,5342658,C,T,A,B,A,G,A,G,A,G,T,C,ALT,REF
ARS-BFGL-BAC-1020,ARS-BFGL-BAC-1020-0_B_R_1511662870,14,6889656,T,C,A,B,A,G,A,G,T,C,T,C,REF,ALT
ARS-BFGL-BAC-10245,ARS-BFGL-BAC-10245-0_B_F_1511658502,14,30124134,G,A,A,B,A,G,T,C,T,C,A,G,ALT,REF
ARS-BFGL-BAC-10345,ARS-BFGL-BAC-10345_dup-0_T_F_2328966403,14,5105727,T,G,A,B,A,C,A,C,A,C,T,G,REF,ALT
ARS-BFGL-BAC-10375,ARS-BFGL-BAC-10375_dup-0_T_F_2328966405,14,5587750,G,A,A,B,A,G,A,G,A,G,A,G,ALT,REF
ARS-BFGL-BAC-10591,ARS-BFGL-BAC-10591_dup-0_T_F_2328966407,14,15956824,A,G,A,B,A,G,A,G,A,G,A,G,REF,ALT
ARS-BFGL-BAC-10867,ARS-BFGL-BAC-10867-0_B_F_1511658130,14,32554055,C,G,A,B,C,G,G,C,G,C,G,C,ALT,REF
ARS-BFGL-BAC-10919,ARS-BFGL-BAC-10919-0_T_F_1511658221,14,29573682,T,C,A,B,A,G,A,G,A,G,T,C,REF,ALT
```

### Alignment file

The optional **alignment** file shows how BLAST alignments were parsed to
determine variant position and alleles for use in the other output files.

#### Sample alignment file content

The following alignment file content depicts several easy-to-parse alignments.

```
========================================================================================
ABCA12,ABCA12_r2-1_T_F_2277749139
ABCA12
Type: SNP
      QUERY ATAGCTGCCACAGGGAGGAAAATGGGGTCTAATGTATATTTTCACATGGAGAGTAGCAAGAGTTTCAATACAAGGAGCTCCTATGTAAATAACTTTACCATGTCGGGCAGCATCATATTTTGACATGTTAACTCGCAGGAGGAAATTATTCAGGCTGTTGAGGTAAGCTGGAAGGGAGNGATAGCCTTCTGGATCATACCATACCTGTAACATTCCAAAAGAAGACAAGATCAGTATGGTGTTCAAATAAATTAGGCAGTCTTTATATCTTACAGACTATATAATTTATATTTAAAATAAATGCACCAGTTTCCCCAGTAACTTATTCATCTTAGCAGATTATGAACCATCCACCAGAGT
    SUBJECT ATAGCTGCCACAGGGAGGAAAATGGGGTCTAATGTATATTTTCACATGGAGAGTAGCAAGAGTTTCAATACAAGGAGCTCCTATGTAAATAACTTTACCATGTCGGGCAGCATCATATTTTGACATGTTAACTCGCAGGAGGAAATTATTCAGGCTGTTGAGGTAAGCTGGAAGGGAGTGATAGCCTTCTGGATCATACCATACCTGTAACATTCCAAAAGAAGACAAGATCAGTATGGTGTTCAAATAAATTAGGCAGTCTTTATATCTTACAGACTATATAATTTATATTTAAAATAAATGCACCAGTTTCCCCAGTAACTTATTCATCTTAGCAGATTATGAACCATCCACCAGAGT
  103030311     .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |
    ALLELE1                                                                                                                                                                                   C
    ALLELE2                                                                                                                                                                                   T
   POSITION                                                                                                                                                                          103030489|
        REF                                                                                                                                                                                   T
    VCF_REF                                                                                                                                                                                   T
    VCF_ALT                                                                                                                                                                                   C
Determination type: ALIGNMENT_NO_GAPS
========================================================================================
APAF1,APAF1_dup-1_B_F_2327661418
APAF1
Type: SNP
      QUERY CCATTTCCTAATATTGTGCAACTGGGCCTCTGTGAACTGGAAACTTCAGAGGTTTATCGGNAAGCTAAGCTGCAGGCCAAGCAGGAGGTCGATAACGGAATGCTTTACCTGGAGTGGGTGT
    SUBJECT CCATTTCCTAATATTGTGCAACTGGGCCTCTGTGAACTGGAAACTTCAGAGGTTTATCGGCAAGCTAAGCTGCAGGCCAAGCAGGAGGTCGATAACGGAATGCTTTACCTGGAGTGGGTGT
   62810185 .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                             T
    ALLELE2                                                             C
   POSITION                                                     62810245|
        REF                                                             C
    VCF_REF                                                             C
    VCF_ALT                                                             T
Determination type: ALIGNMENT_NO_GAPS
========================================================================================
ARS-BFGL-BAC-10172,ARS-BFGL-BAC-10172_dup-0_T_F_2328966397
ARS-BFGL-BAC-10172
Type: SNP
      QUERY TTTCAATTGTTTTAAAAATTTCAATATTAACAAAAATATTACTAAAAGAATATTCTGGATNACTTGAGTGATGACTTACATAAGTAAGTGCTACCACATACTTTGGGGACCAACTTCTGAG
    SUBJECT TTTCAATTGTTTTAAAAATTTCAATATTAACAAAAATATTACTAAAAGAATATTCTGGATCACTTGAGTGATGACTTACATAAGTAAGTGCTACCACATACTTTGGGGACCAACTTCTGAG
    5342598   |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                             C
    ALLELE2                                                             T
   POSITION                                                      5342658|
        REF                                                             C
    VCF_REF                                                             C
    VCF_ALT                                                             T
Determination type: ALIGNMENT_NO_GAPS
========================================================================================
ARS-BFGL-BAC-1020,ARS-BFGL-BAC-1020-0_B_R_1511662870
ARS-BFGL-BAC-1020
Type: SNP
      QUERY TTTAGCTTTAGGATTTTCTTCAATGTTGTTTCAGTGGCATCCTTTATTTGACTGGAATAGNACTCAATGTTTGGGCTTCCCAGATGGCTCAGTGAGAAATCAGGAGACCTGAGTTCAATCC
    SUBJECT TTTAGCTTTAGGATTTTCTTCAATGTTGTTTCAGTGGCATCCTTTATTTGACTGGAATAGTACTCAATGTTTGGGCTTCCCAGATGGCTCAGTGAGAAATCAGGAGACCTGAGTTCAATCC
    6889596     |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                             C
    ALLELE2                                                             T
   POSITION                                                      6889656|
        REF                                                             T
    VCF_REF                                                             T
    VCF_ALT                                                             C
Determination type: ALIGNMENT_NO_GAPS
========================================================================================
ARS-BFGL-BAC-10245,ARS-BFGL-BAC-10245-0_B_F_1511658502
ARS-BFGL-BAC-10245
Type: SNP
      QUERY TCCTTTCTAGGAGGACAGGCCTGAGTGGGGGCCTGGGAGGGGAAGAGACACTGGTCACCANAGGGCAGAGAGAAAGAGAACAGGAAGAGAGAAGAAGAAAAACAGAAGGCGGGGAAGTGGG
    SUBJECT TCCTTTCTAGGAGGACAGGCCTGAGTGGGGGCCTGGGAGGGGAAGAGACACTGGTCACCAGAGGGCAGAGAGAAAGAGAACAGGAAGAGAGAAGAAGAAAAACAGAAGGCGGGGAAGTGGG
   30124074  .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |
    ALLELE1                                                             G
    ALLELE2                                                             A
   POSITION                                                     30124134|
        REF                                                             G
    VCF_REF                                                             G
    VCF_ALT                                                             A
Determination type: ALIGNMENT_NO_GAPS
========================================================================================
ARS-BFGL-BAC-10345,ARS-BFGL-BAC-10345_dup-0_T_F_2328966403
ARS-BFGL-BAC-10345
Type: SNP
      QUERY TACATCTTTTAACGGGGTTTTTAAAAAGTAGGGGTCAGGAAAACATGAGATGTTTTCTTTNTAGGTTTATTTGCAGGAGTACTTGAAGCACAAAGCAATAGAATGAATGGTGCCCTATACC
    SUBJECT TACATCTTTTAACGGGGTTTTTAAAAAGTAGGGGTCAGGAAAACATGAGATGTTTTCTTTTTAGGTTTATTTGCAGGAGTACTTGAAGCACAAAGCAATAGAATGAATGGTGCCCTATACC
    5105667    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                             G
    ALLELE2                                                             T
   POSITION                                                      5105727|
        REF                                                             T
    VCF_REF                                                             T
    VCF_ALT                                                             G
Determination type: ALIGNMENT_NO_GAPS
========================================================================================
ARS-BFGL-BAC-10375,ARS-BFGL-BAC-10375_dup-0_T_F_2328966405
ARS-BFGL-BAC-10375
Type: SNP
      QUERY TAAAAGCATTTTTAAAACAAAGATTGATGTATAAGTACCTTGATTGCAGCCTAATGCATANTAGATAGGATTGAAAAACAACAATCAAATATTATGCTGAATACAATCAAATATTATACAA
    SUBJECT TAAAAGCATTTTTAAAATAAAGATTGATGTATAAGTACCTTGATTGCAGCCTAATGCATAGTAGATAGGATTGAAAAACAACAATCAAATATTATGCTGAATACAATCAAATATTATACAA
    5587690 |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |
    ALLELE1                                                             A
    ALLELE2                                                             G
   POSITION                                                      5587750|
        REF                                                             G
    VCF_REF                                                             G
    VCF_ALT                                                             A
Determination type: ALIGNMENT_NO_GAPS
========================================================================================
ARS-BFGL-BAC-10591,ARS-BFGL-BAC-10591_dup-0_T_F_2328966407
ARS-BFGL-BAC-10591
Type: SNP
      QUERY AGTTCTTGCAAAAAAAGATGTTTATACAGTAATGCTTATTGTAGCACCATTTATAGTAGCNAAATAAATCAGAACAAAAATATCAGGGGCTAGTTAAATATTACATGATACATATCACATA
    SUBJECT AGTTCTTGCAAAAAAAGATGTTTATACAGTAATGCTTATTGTAGCACCATTTATAGTAGCAAAATAAATCAGAACAAAAATATCAGGGGCTAGTTAAATATTACATGATACATATCACATA
   15956764  .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |
    ALLELE1                                                             A
    ALLELE2                                                             G
   POSITION                                                     15956824|
        REF                                                             A
    VCF_REF                                                             A
    VCF_ALT                                                             G
Determination type: ALIGNMENT_NO_GAPS
========================================================================================
ARS-BFGL-BAC-10867,ARS-BFGL-BAC-10867-0_B_F_1511658130
ARS-BFGL-BAC-10867
Type: SNP
      QUERY ATATAACTCTTTAATATTTTTGATTGATTTATGCTGGAAATTTTCTCTTTGAAATGATCANAACATATTTAAAATTATAAGTTACAAGTAAGAGATTTTAAATTATTTTATGCATTGTTAA
    SUBJECT ATATAACTCTTTAATATTTTTGATTGATTTATGCTGGAAATTTTCTCTTTGAAATGATCACAACATATTTAAAATTATAAGTTACAAGTAAGAGATTTTAAATTATTTTATGCATTGTTAA
   32553995 .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                             C
    ALLELE2                                                             G
   POSITION                                                     32554055|
        REF                                                             C
    VCF_REF                                                             C
    VCF_ALT                                                             G
Determination type: ALIGNMENT_NO_GAPS
========================================================================================
ARS-BFGL-BAC-10919,ARS-BFGL-BAC-10919-0_T_F_1511658221
ARS-BFGL-BAC-10919
Type: SNP
      QUERY CTCAAGCTTGAACATGATAGTCCCGATGGCCAGAGTGCAGAGACTTCCTTGAACACCAAGNGCACTCAGTAAAGCTTCCGTCAAGATCATGACCTAGGAGTTTAGTACCAAACTTCACCAT
    SUBJECT CTCAAGCTTGAACATGATAGTCCCGATGGCCAGAGTGCAGAGACTTCCTTGAACACCAAGTGCACTCAGTAAAGCTTCCGTCAAGATCATGACCTAGGAGTTTAGTACCAAACTTCACCAT
   29573622    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |
    ALLELE1                                                             C
    ALLELE2                                                             T
   POSITION                                                     29573682|
        REF                                                             T
    VCF_REF                                                             T
    VCF_ALT                                                             C
Determination type: ALIGNMENT_NO_GAPS
```

The following alignment file content depicts more complex alignment results and
their parsing.

```
========================================================================================
ARS-BFGL-BAC-11000,ARS-BFGL-BAC-11000_dup-0_B_F_2328966422
ARS-BFGL-BAC-11000
Type: SNP
      QUERY TCATTGAAACTAAGTATAACTTAACTGTGAAATGTACAATCACCACATTGAAATCTGAGC-NCAAATGAAATTTGATTAGCTCGCCTGAGAATATATAGTTAACAAGAAAGTATTAGCTAA
    SUBJECT TCATTGAAACTAAGTATAACTTAACTGTGAAATGTACAATCACCACATTGAAATCTGAGCTGCAAATGAAATTTGATTAGCTCGCCTGAGAATATATAGTTAACAAGAAAGTATTAGCTAA
      PROBE           TAAGTATAACTTAACTGTGAAATGTACAATCACCACATTGAAATCTGAGC
   78907101     .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |
    ALLELE1                                                             T
    ALLELE2                                                             G
   POSITION                                                     78907161|
        REF                                                             T
    VCF_REF                                                             T
    VCF_ALT                                                             G
Determination type: LEFT_PROBE_MATCH
========================================================================================
ARS-BFGL-BAC-12552,ARS-BFGL-BAC-12552-0_B_R_1511662496
ARS-BFGL-BAC-12552
Type: SNP
      QUERY CCGGCGGCGGCGCGCACGTCATCCCAGCGGAAGTCCACCGGCCAGCCTCGGAAGTTGTA-NTGTAGTTGGCTGTCAGGTAGATCTTGAACACGTGCACCAGCGCTTTCACGAAGCAGCACC
    SUBJECT CCGGCGGCGGCGCGCACGTCATCCCAGCGGAAGTCCACCGGCCAGCCTCGGAAGTTGTAGGTGTAGTTGGCTGTCAGGTAGATCTTGAACACGTGCACCAGCGCTTTCACGAAGCAG-ACC
      PROBE                                                              TGTAGTTGGCTGTCAGGTAGATCTTGAACACGTGCACCAGCGCTTTCACG
   53958427    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |     .
    ALLELE1                                                             A
    ALLELE2                                                             G
   POSITION                                                     53958487|
        REF                                                             G
    VCF_REF                                                             G
    VCF_ALT                                                             A
Determination type: RIGHT_PROBE_MATCH
========================================================================================
ARS-BFGL-NGS-104590,ARS-BFGL-NGS-104590-0_T_F_1511670707
ARS-BFGL-NGS-104590
Type: SNP
      QUERY AGACACTTGTTGGATAAATGAATGCTCGACTGGGGTCAGGTCCCTCAGTGGAGCTGGCAGN-AACAGCTCGCAAGGGGCCACTTGCTGCCATGGGCCAGGCCAGGACAGAGAGACCCAGGCC
    SUBJECT AGACAC-T-TTGGATAAATGAATGCTCAACTGGGGTCAGGTCCCTCAGTGGAGCTGGCAGGAAACAGCTCGCAAGGGGCCACTTGCTGCCAGGGGCCAGGCCAGGACAGAGAGACCCAGGCC
      PROBE           TGGATAAATGAATGCTCGACTGGGGTCAGGTCCCTCAGTGGAGCTGGCAG
  107645848   |      .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                             A
    ALLELE2                                                             G
   POSITION                                                    107645906|
        REF                                                             G
    VCF_REF                                                             G
    VCF_ALT                                                             A
Determination type: LEFT_PROBE_PARTIAL_MATCH
========================================================================================
ARS-BFGL-NGS-117323,ARS-BFGL-NGS-117323_dup-0_T_R_2328978067
ARS-BFGL-NGS-117323
Type: SNP
      QUERY GGGTAGGTTTCTAGGGCCCCTGCTGCC-TTCTGCCCCTGGGCCTCTGGTTGATGCCCAGCTN-GGGGGTGGTCAGGTCTCACACGCATTTTGCGAATGGGAATGCTAGCTACGAGGGATGACC
    SUBJECT GGGTAGGTTTCTAGGGCCCCTGCTGCCTTTCTGCCCCTGGGCCTCTGGTTGATGCCCAGCTTCGGGGGTGGTCAGGTCTCGCACGCATTTTGCGAATGGGAATGCTAGCTACGAGGGATGACC
      PROBE                                                                GGGGGTGGTCAGGTCTCACACGCATTTTGCGAATGGGAATGCTAGCTACG
   48717031     .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |
    ALLELE1                                                               T
    ALLELE2                                                               C
   POSITION                                                       48717093|
        REF                                                               C
    VCF_REF                                                               C
    VCF_ALT                                                               T
Determination type: RIGHT_PROBE_PARTIAL_MATCH
========================================================================================
BTB-00361571,BTB-00361571_dup-0_T_R_2322071874
BTB-00361571
Type: SNP
      QUERY GCCAGGTGTGAGATGCTTCTGCAACAAGAGCATCATGGAGGCTCCTTTCCAAAGAAG-AAANGGTGATAAAAAATGAGAAAAAATTCAAGTGACAAAAAAAATTGAATAGAACAGGCTTTTT
    SUBJECT GCCAGGTGTGAGATGCTTCTGCAACAAGAGCAGCATGGAGGCTCCTTTCCAAAGAAGAAAAGGGTGATAAAAAATGAGAAAAAATTCAAGTGACAAAAAAAATTGAATAGAACAGGCTTTTT
   79617810 |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |
    ALLELE1                                                              G
    ALLELE2                                                              A
   POSITION                                                      79617871|
        REF                                                              G
    VCF_REF                                                              G
    VCF_ALT                                                              A
Determination type: GAPPED_ALIGNMENT
========================================================================================
BTB-00799479,BTB-00799479-0_T_R_1511584210
BTB-00799479
Type: SNP
      QUERY TCCCTTTATATCTGCCGTGCGCTTCACTTTACTGTTTTTGCAATCTATCATTTCAGCTTTNAAAAAAAAAAGGGGGATATTTCTTATTATCTGATCTTCCCTAGATGTACTTAACTTTGTG
    SUBJECT TCCCTTTATATCTGCCGTGCGCTTCACTTTACTG-TTTTGCAATCTATCATTTCAGCTTT-AAAAAAAAAA-GGGGATATTTCTTATTATCTGATCTTCCCTAGATGTACTTAACTTTGTG
   68543240 |    .    |    .    |    .    |     .    |    .    |    .     |    .     |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                              G
    ALLELE2                                                              A
   POSITION                                                      68543299|
        REF                                                              A
    VCF_REF                                                              A
    VCF_ALT                                                              G
Determination type: ALIGNMENT_TO_GAP_INFORMATIVE_ALLELES
========================================================================================
BTB-00891865,BTB-00891865-0_T_R_1511588380
BTB-00891865
Type: SNP
      QUERY ACTTTATTCTACTTTTACTATCCTAAGTCATCTATCAGTGAGTTAAACCTTTCTTTATGTNCCTAAAGAACGTATGTGCCATGTAATATTTCTACTA-TTTTTTCCTTTTTCTCTCTGAAAC
    SUBJECT ACTTTATTCTACTTTTACTATCCTAAGTCATCTATCAGTGAGTTAAACCTTTCTTTATGT-CCTAAAGAACGTATGTGCCATGTAATATTTCTACTACTTTTTTCCTTTTTCTCTCTGAAAC
   56070147    |    .    |    .    |    .    |    .    |    .    |    .     |    .    |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                            T
    ALLELE2                                                            C
   POSITION                                                    56070206|
        REF                                                            T
    VCF_REF                                                            T
    VCF_ALT                                                            C
Determination type: ALIGNMENT_TO_GAP_UNINFORMATIVE_ALLELES_BOTH_SIDES_CONSISTENT
========================================================================================
ARS-BFGL-NGS-64032,ARS-BFGL-NGS-64032-0_T_R_1511651499
ARS-BFGL-NGS-64032
Type: SNP
      QUERY CAGAGGAGTGGAGACGTGTCTTCAGCCTGCAAAGGCTGCAAAGGCCTGCAAAGGCCATCANCAGGGGAGTCACACTGAAAGCAGCCAACCAGAAAGCAGAGCTAGGAGCAGAGGGTGGATG
    SUBJECT CAGAGGAGTGGAGACGTGTCTTCAGCCTGCAAAGGCTGCAAAGGCCTGCAA--G----CA--AGGGGAGTCACACTGAAAGCAGCCAACCAGAAAGCAGAGCTAGGAGCAGAGGGTGGATG
   32267991     .    |    .    |    .    |    .    |    .    |            .    |    .    |    .    |    .    |    .    |    .    |
    ALLELE1                                                            T
    ALLELE2                                                            G
   POSITION                                                    32268044|
        REF                                                            A
    VCF_REF                                                            A
    VCF_ALT                                                          T/G
Determination type: ALIGNMENT_TO_GAP_UNINFORMATIVE_ALLELES_BOTH_SIDES_INCONSISTENT
========================================================================================
MC1R,MC1R-1_P_F_2276841238
MC1R
Type: INDEL
      QUERY TCTGCTGCCTGGCTGTGTCTGACTTGCTGGTGAGCGTCAGCAACGTGCTGGAGACGGCAGTCATGCTGCTGCTGGAGGCCNGTGTCCTGGCCACCCAGGCGGCCGTGGTGCAGCAGCTGGACAATGTCATCGACGTGCTCATCTGCGGATCCATGGTGTCC
    SUBJECT TCTGCTGCCTGGCTGTGTCTGACTTGCTGGTGAGCGTCAGCAACGTGCTGGAGACGGCAGTCATGCTGCTGCTGGAGGCCGGTGTCCTGGCCACCCAGGCGGCCGTGGTGCAGCAGCTGGACAATGTCATCGACGTGCTCATCTGCGGATCCATGGTGTCC
   14705605 .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                                                -
    ALLELE2                                                                                G
   POSITION                                                                        14705684|
        REF                                                                                I
    VCF_REF                                                                               CG
    VCF_ALT                                                                                C
Determination type: DETECTION_OF_INSERTION_ALLELE_AT_VARIANT_SITE
========================================================================================
MRC2_2,MRC2_2_r3-1_P_F_2277751605
MRC2_2
Type: INDEL
      QUERY TCACTTTTCACAGAGGACTGGGGGGACCAGAGGTGCACAACAGCCTTGCCTTACATCTGCAAGCGGCGCAACAGCACCAG-NAGCAGCAGCCCCCAGACCTGCCGCCCACAGGGGGCTGCCCCTCTGGCTGGAGCCAGTTCCTGAACAAGGTAGGGAGTAG
    SUBJECT TCACTTTTCACAGAGGACTGGGGGGACCAGAGGTGCACAACAGCCTTGCCTTACATCTGCAAGCGGCGCAACAGCACCAGAGAGCAGCAGCCCCCAGACCTGCCGCCCACAGGGGGCTGCCCCTCTGGCTGGAGCCAGTTCCTGAACAAGGTAGGGAGTAG
   47095066     |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                                              -
    ALLELE2                                                                             AG
   POSITION                                                                      47095143|
        REF                                                                              I
    VCF_REF                                                                            CAG
    VCF_ALT                                                                              C
Determination type: DETECTION_OF_INSERTION_ALLELE_AT_VARIANT_SITE
========================================================================================
TYR,TYR_dup-1_P_F_2327736495
TYR
Type: INDEL
      QUERY CAGCTTTATCCATGGAACCTGATTCATACTGGGTCAAACTCAGGCAAAACTCCACATCAGCCGAGGAGGGGAGCCTCGGGGNTCCTGGCTTTGTCGTGGTTTCCAGGATTGCGCAGTAATGGTCCCTCAGACGTCCCGTTGCATAAAGCCTGGCGACTGTTG
    SUBJECT CAGCTTTATCCATGGAACCTGATTCATACTGGGTCAAACTCAGGCAAAACTCCACATCAGCCGAGGAGGGGAGCCTCGGGG-TCCTGGCTTTGTCGTGGTTTCCAGGATTGCGCAGTAATGGTCCCTCAGACGTCCCGTTGCATAAAGCCTGGCGACTGTTG
    6424891     .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |     .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |
    ALLELE1                                                                             -
    ALLELE2                                                                             G
   POSITION                                                                      6424967|
        REF                                                                             D
    VCF_REF                                                                             C
    VCF_ALT                                                                            CG
Determination type: DETECTION_OF_DELETION_ALLELE_AT_VARIANT_SITE
========================================================================================
F11,F11_dup-1_M_R_2327729435
F11
Type: INDEL
      QUERY AGTCACCTAATGTGTTGCGTGTCTATAGCGGCATTTTGAATCAATCAGAAATAAAAGAGGATACATCTTTCTTTGGGGTTCAAGAAATAATAATTCANTGATCAATATGAAAAGGCAGAAAGTGGATATGACATTGCCTTGTTGAAACTAGAAA--GCAATGAATTATACAGGTATGGGAAACTTTAAACAGAACGTTGTCTACAGTGATGCCGGGCTTCACACTCCCA
    SUBJECT AGTCACCTAATGTGTTGCGTGTCTATAGCGGCATTTTGAATCAATCAGAAATAAAAGAGGATACATCTTTCTTTGGGGTTCAAGAAATAATAATTCA-TGATCAATATGAAAAGGCAGAAAGTGGATATGACATTGCCTTGTTGAAACTAGAAACGGCAATGAATTATACAGGTATGGGAAACTTTAAACAGAACGTTGTCTACAGTGATGCCGGGCTTCACACTCCCA
   16310249  |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .     |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .    |    .
    ALLELE1                                                                                                 -
    ALLELE2                      ATAAAAAAAAAAAAAAAAAAAAAAAAAAAATAAAGAAAAAAAAAAAAAAAAAAAAAAAAAAGGAAATAATAATTCA
   POSITION                                                                                         16310345|
        REF                                                                                                 D
    VCF_REF                                                                                                 A
    VCF_ALT                     AATAAAAAAAAAAAAAAAAAAAAAAAAAAAATAAAGAAAAAAAAAAAAAAAAAAAAAAAAAAGGAAATAATAATTCA
Determination type: DETECTION_OF_DELETION_ALLELE_AT_VARIANT_SITE
```

### Blast file

The optional **blast** file provides raw BLAST results that were generated by
the pipeline.

#### Sample blast file content

```
query id,query seq,subject id,subject titles,s. start,s. end,subject strand,subject seq
ABCA12,ACTCTGGTGGATGGTTCATAATCTGCTAAGATGAATAAGTTACTGGGGAAACTGGTGCATTTATTTTAAATATAAATTATATAGTCTGTAAGATATAAAGACTGCCTAATTTATTTGAACACCATACTGATCTTGTCTTCTTTTGGAATGTTACAGGTATGGTATGATCCAGAAGGCTATCNCTCCCTTCCAGCTTACCTCAACAGCCTGAATAATTTCCTCCTGCGAGTTAACATGTCAAAATATGATGCTGCCCGACATGGTAAAGTTATTTACATAGGAGCTCCTTGTATTGAAACTCTTGCTACTCTCCATGTGAAAATATACATTAGACCCCATTTTCCTCCCTGTGGCAGCTAT,2,2,103030670,103030311,minus,ACTCTGGTGGATGGTTCATAATCTGCTAAGATGAATAAGTTACTGGGGAAACTGGTGCATTTATTTTAAATATAAATTATATAGTCTGTAAGATATAAAGACTGCCTAATTTATTTGAACACCATACTGATCTTGTCTTCTTTTGGAATGTTACAGGTATGGTATGATCCAGAAGGCTATCACTCCCTTCCAGCTTACCTCAACAGCCTGAATAATTTCCTCCTGCGAGTTAACATGTCAAAATATGATGCTGCCCGACATGGTAAAGTTATTTACATAGGAGCTCCTTGTATTGAAACTCTTGCTACTCTCCATGTGAAAATATACATTAGACCCCATTTTCCTCCCTGTGGCAGCTAT
APAF1,CCATTTCCTAATATTGTGCAACTGGGCCTCTGTGAACTGGAAACTTCAGAGGTTTATCGGNAAGCTAAGCTGCAGGCCAAGCAGGAGGTCGATAACGGAATGCTTTACCTGGAGTGGGTGT,5,5,62810185,62810305,plus,CCATTTCCTAATATTGTGCAACTGGGCCTCTGTGAACTGGAAACTTCAGAGGTTTATCGGCAAGCTAAGCTGCAGGCCAAGCAGGAGGTCGATAACGGAATGCTTTACCTGGAGTGGGTGT
ARS-BFGL-BAC-10172,CTCAGAAGTTGGTCCCCAAAGTATGTGGTAGCACTTACTTATGTAAGTCATCACTCAAGTNATCCAGAATATTCTTTTAGTAATATTTTTGTTAATATTGAAATTTTTAAAACAATTGAAA,14,14,5342718,5342598,minus,CTCAGAAGTTGGTCCCCAAAGTATGTGGTAGCACTTACTTATGTAAGTCATCACTCAAGTGATCCAGAATATTCTTTTAGTAATATTTTTGTTAATATTGAAATTTTTAAAACAATTGAAA
ARS-BFGL-BAC-1020,GGATTGAACTCAGGTCTCCTGATTTCTCACTGAGCCATCTGGGAAGCCCAAACATTGAGTNCTATTCCAGTCAAATAAAGGATGCCACTGAAACAACATTGAAGAAAATCCTAAAGCTAAA,14,14,6889716,6889596,minus,GGATTGAACTCAGGTCTCCTGATTTCTCACTGAGCCATCTGGGAAGCCCAAACATTGAGTACTATTCCAGTCAAATAAAGGATGCCACTGAAACAACATTGAAGAAAATCCTAAAGCTAAA
ARS-BFGL-BAC-10245,CCCACTTCCCCGCCTTCTGTTTTTCTTCTTCTCTCTTCCTGTTCTCTTTCTCTCTGCCCTNTGGTGACCAGTGTCTCTTCCCCTCCCAGGCCCCCACTCAGGCCTGTCCTCCTAGAAAGGA,14,14,30124194,30124074,minus,CCCACTTCCCCGCCTTCTGTTTTTCTTCTTCTCTCTTCCTGTTCTCTTTCTCTCTGCCCTCTGGTGACCAGTGTCTCTTCCCCTCCCAGGCCCCCACTCAGGCCTGTCCTCCTAGAAAGGA
ARS-BFGL-BAC-10345,GGTATAGGGCACCATTCATTCTATTGCTTTGTGCTTCAAGTACTCCTGCAAATAAACCTANAAAGAAAACATCTCATGTTTTCCTGACCCCTACTTTTTAAAAACCCCGTTAAAAGATGTA,14,14,5105787,5105667,minus,GGTATAGGGCACCATTCATTCTATTGCTTTGTGCTTCAAGTACTCCTGCAAATAAACCTAAAAAGAAAACATCTCATGTTTTCCTGACCCCTACTTTTTAAAAACCCCGTTAAAAGATGTA
ARS-BFGL-BAC-10375,TAAAAGCATTTTTAAAACAAAGATTGATGTATAAGTACCTTGATTGCAGCCTAATGCATANTAGATAGGATTGAAAAACAACAATCAAATATTATGCTGAATACAATCAAATATTATACAA,14,14,5587690,5587810,plus,TAAAAGCATTTTTAAAATAAAGATTGATGTATAAGTACCTTGATTGCAGCCTAATGCATAGTAGATAGGATTGAAAAACAACAATCAAATATTATGCTGAATACAATCAAATATTATACAA
ARS-BFGL-BAC-10591,AGTTCTTGCAAAAAAAGATGTTTATACAGTAATGCTTATTGTAGCACCATTTATAGTAGCNAAATAAATCAGAACAAAAATATCAGGGGCTAGTTAAATATTACATGATACATATCACATA,14,14,15956764,15956884,plus,AGTTCTTGCAAAAAAAGATGTTTATACAGTAATGCTTATTGTAGCACCATTTATAGTAGCAAAATAAATCAGAACAAAAATATCAGGGGCTAGTTAAATATTACATGATACATATCACATA
ARS-BFGL-BAC-10867,ATATAACTCTTTAATATTTTTGATTGATTTATGCTGGAAATTTTCTCTTTGAAATGATCANAACATATTTAAAATTATAAGTTACAAGTAAGAGATTTTAAATTATTTTATGCATTGTTAA,14,14,32553995,32554115,plus,ATATAACTCTTTAATATTTTTGATTGATTTATGCTGGAAATTTTCTCTTTGAAATGATCACAACATATTTAAAATTATAAGTTACAAGTAAGAGATTTTAAATTATTTTATGCATTGTTAA
ARS-BFGL-BAC-10919,ATGGTGAAGTTTGGTACTAAACTCCTAGGTCATGATCTTGACGGAAGCTTTACTGAGTGCNCTTGGTGTTCAAGGAAGTCTCTGCACTCTGGCCATCGGGACTATCATGTTCAAGCTTGAG,14,14,29573742,29573622,minus,ATGGTGAAGTTTGGTACTAAACTCCTAGGTCATGATCTTGACGGAAGCTTTACTGAGTGCACTTGGTGTTCAAGGAAGTCTCTGCACTCTGGCCATCGGGACTATCATGTTCAAGCTTGAG
```

## Creating new output formats

The **wide** output format can easily be manipulated using standard
command-line utilities in order to generate other useful formats.

### To create a MAP file for PLINK

For example, the two commands below can be used to generate a MAP file for
PLINK.

The first command does the following: skip comment lines; skip the header row;
and, when position information is available, print the position, marker name,
'0', and chromosome:

    $ cat manifest.reference.wide.csv | grep -v '#' | tail -n +2 | awk -F, '{ if ($4 != "") { print $3,$1,'0',$4 } }' OFS="\t" > temp

The second command recodes chromosomes to integers (the specific recoding
needed will depend on the species and chromosome names obtained). Specifically,
it changes 'X' to '30', 'Y' to '31', 'MT' to '32', and any
non-integer-represented chromosomes remaining to '0':

    $ cat temp | awk '{ $1 = ($1 == "X" ? 30 : $1); $1 = ($1 == "Y" ? 31 : $1); $1 = ($1 == "MT" ? 32 : $1); $1 = (match($1, /[^0-9]/) ? 0 : $1 )}  1' OFS="\t" > manifest.reference.map

Using the sample **wide** file output above as input, these commands produce
the following:

```
2	ABCA12	0	103030489
5	APAF1	0	62810245
14	ARS-BFGL-BAC-10172	0	5342658
14	ARS-BFGL-BAC-1020	0	6889656
14	ARS-BFGL-BAC-10245	0	30124134
14	ARS-BFGL-BAC-10345	0	5105727
14	ARS-BFGL-BAC-10375	0	5587750
14	ARS-BFGL-BAC-10591	0	15956824
14	ARS-BFGL-BAC-10867	0	32554055
14	ARS-BFGL-BAC-10919	0	29573682
```
