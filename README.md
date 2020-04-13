# genotype\_conversion\_file\_builder

The genotype\_conversion\_file\_builder is a pipeline for determining the genome location and transformation rules for the variants described in Illumina or Affymetrix genotype panel manifest files.

Briefly, the pipeline extracts the flanking sequence of each variant from the manifest file, and performs a BLAST search comparing each flanking sequence against a new reference genome of interest. Next, the resulting BLAST alignments are parsed in conjunction with the manifest file, to establish the position of each variant on the reference genome, and to generate simple transformation rules that can be used to convert genotpes between any of the standard formats (AB, TOP, FORWARD, DESIGN) and from any of the standard formats to the forward strand of the reference genome (PLUS). An indication of which allele is observed in the reference genome is also provided. The position information and transformation rules are written to separate files, referred to as **position** and **conversion** files, respectively. An additional **wide** file provides the position and conversion information together in a format that can be easily converted to files used by downstream tools like PLINK.

## Quick start 

Make sure you have installed the required dependencies listed at the end of this document. 

Install the Nextflow runtime by running the following command: 

    $ curl -fsSL get.nextflow.io | bash

When done, you can execute the genotype_conversion_file_builder pipeline by entering the following command:

    $ ./nextflow run genotype_conversion_file_builder

By default the pipeline is executed by using a small dataset included with the project. Check the *Pipeline parameters* section below to see how to process your input data.

## Input

The pipeline requires an Illumina or Affymetrix manifest file and reference genome as input.

#### Sample Illumina manifest file content

```
IlmnID,Name,IlmnStrand,SNP,AddressA_ID,AlleleA_ProbeSeq,AddressB_ID,AlleleB_ProbeSeq,GenomeBuild,Chr,MapInfo,Ploidy,Species,Source,SourceVersion,SourceStrand,SourceSeq,TopGenomicSeq,BeadSetID
ABCA12_r2-1_T_F_2277749139,ABCA12,TOP,[A/G],0059616496,CTTGTCTTCTTTTGGAATGTTACAGGTATGGTATGATCCAGAAGGCTATC,,,0,2,103548215,diploid,Bos taurus,UMD3.1,1,TOP,ACTCTGGTGGATGGTTCATAATCTGCTAAGATGAATAAGTTACTGGGGAAACTGGTGCATTTATTTTAAATATAAATTATATAGTCTGTAAGATATAAAGACTGCCTAATTTATTTGAACACCATACTGATCTTGTCTTCTTTTGGAATGTTACAGGTATGGTATGATCCAGAAGGCTATC[A/G]CTCCCTTCCAGCTTACCTCAACAGCCTGAATAATTTCCTCCTGCGAGTTAACATGTCAAAATATGATGCTGCCCGACATGGTAAAGTTATTTACATAGGAGCTCCTTGTATTGAAACTCTTGCTACTCTCCATGTGAAAATATACATTAGACCCCATTTTCCTCCCTGTGGCAGCTAT,ACTCTGGTGGATGGTTCATAATCTGCTAAGATGAATAAGTTACTGGGGAAACTGGTGCATTTATTTTAAATATAAATTATATAGTCTGTAAGATATAAAGACTGCCTAATTTATTTGAACACCATACTGATCTTGTCTTCTTTTGGAATGTTACAGGTATGGTATGATCCAGAAGGCTATC[A/G]CTCCCTTCCAGCTTACCTCAACAGCCTGAATAATTTCCTCCTGCGAGTTAACATGTCAAAATATGATGCTGCCCGACATGGTAAAGTTATTTACATAGGAGCTCCTTGTATTGAAACTCTTGCTACTCTCCATGTGAAAATATACATTAGACCCCATTTTCCTCCCTGTGGCAGCTAT,1241
APAF1_dup-1_B_F_2327661418,APAF1,BOT,[T/C],0041654401,ATATTGTGCAACTGGGCCTCTGTGAACTGGAAACTTCAGAGGTTTATCGG,,,0,5,63150400,diploid,Bos taurus,UMD3.1,1,BOT,CCATTTCCTAATATTGTGCAACTGGGCCTCTGTGAACTGGAAACTTCAGAGGTTTATCGG[T/C]AAGCTAAGCTGCAGGCCAAGCAGGAGGTCGATAACGGAATGCTTTACCTGGAGTGGGTGT,ACACCCACTCCAGGTAAAGCATTCCGTTATCGACCTCCTGCTTGGCCTGCAGCTTAGCTT[A/G]CCGATAAACCTCTGAAGTTTCCAGTTCACAGAGGCCCAGTTGCACAATATTAGGAAATGG,1241
ARS-BFGL-BAC-10172_dup-0_T_F_2328966397,ARS-BFGL-BAC-10172,TOP,[A/G],0072620471,GGTCCCCAAAGTATGTGGTAGCACTTACTTATGTAAGTCATCACTCAAGT,,,3,14,6371334,diploid,Bos taurus,UM3,0,TOP,CTCAGAAGTTGGTCCCCAAAGTATGTGGTAGCACTTACTTATGTAAGTCATCACTCAAGT[A/G]ATCCAGAATATTCTTTTAGTAATATTTTTGTTAATATTGAAATTTTTAAAACAATTGAAA,CTCAGAAGTTGGTCCCCAAAGTATGTGGTAGCACTTACTTATGTAAGTCATCACTCAAGT[A/G]ATCCAGAATATTCTTTTAGTAATATTTTTGTTAATATTGAAATTTTTAAAACAATTGAAA,1241
ARS-BFGL-BAC-1020-0_B_R_1511662870,ARS-BFGL-BAC-1020,BOT,[T/C],0064735382,GGATTTTCTTCAATGTTGTTTCAGTGGCATCCTTTATTTGACTGGAATAG,,,3,14,7928189,diploid,Bos taurus,UM3,0,TOP,GGATTGAACTCAGGTCTCCTGATTTCTCACTGAGCCATCTGGGAAGCCCAAACATTGAGT[A/G]CTATTCCAGTCAAATAAAGGATGCCACTGAAACAACATTGAAGAAAATCCTAAAGCTAAA,GGATTGAACTCAGGTCTCCTGATTTCTCACTGAGCCATCTGGGAAGCCCAAACATTGAGT[A/G]CTATTCCAGTCAAATAAAGGATGCCACTGAAACAACATTGAAGAAAATCCTAAAGCTAAA,1241
ARS-BFGL-BAC-10245-0_B_F_1511658502,ARS-BFGL-BAC-10245,BOT,[T/C],0022660301,CGCCTTCTGTTTTTCTTCTTCTCTCTTCCTGTTCTCTTTCTCTCTGCCCT,,,3,14,31819743,diploid,Bos taurus,UM3,0,BOT,CCCACTTCCCCGCCTTCTGTTTTTCTTCTTCTCTCTTCCTGTTCTCTTTCTCTCTGCCCT[T/C]TGGTGACCAGTGTCTCTTCCCCTCCCAGGCCCCCACTCAGGCCTGTCCTCCTAGAAAGGA,TCCTTTCTAGGAGGACAGGCCTGAGTGGGGGCCTGGGAGGGGAAGAGACACTGGTCACCA[A/G]AGGGCAGAGAGAAAGAGAACAGGAAGAGAGAAGAAGAAAAACAGAAGGCGGGGAAGTGGG,1241
ARS-BFGL-BAC-10345_dup-0_T_F_2328966403,ARS-BFGL-BAC-10345,TOP,[A/C],0030645323,ACCATTCATTCTATTGCTTTGTGCTTCAAGTACTCCTGCAAATAAACCTA,,,3,14,6133529,diploid,Bos taurus,UM3,0,TOP,GGTATAGGGCACCATTCATTCTATTGCTTTGTGCTTCAAGTACTCCTGCAAATAAACCTA[A/C]AAAGAAAACATCTCATGTTTTCCTGACCCCTACTTTTTAAAAACCCCGTTAAAAGATGTA,GGTATAGGGCACCATTCATTCTATTGCTTTGTGCTTCAAGTACTCCTGCAAATAAACCTA[A/C]AAAGAAAACATCTCATGTTTTCCTGACCCCTACTTTTTAAAAACCCCGTTAAAAGATGTA,1241
ARS-BFGL-BAC-10375_dup-0_T_F_2328966405,ARS-BFGL-BAC-10375,TOP,[A/G],0028627348,TTTAAAACAAAGATTGATGTATAAGTACCTTGATTGCAGCCTAATGCATA,,,3,14,6616434,diploid,Bos taurus,UM3,0,TOP,TAAAAGCATTTTTAAAACAAAGATTGATGTATAAGTACCTTGATTGCAGCCTAATGCATA[A/G]TAGATAGGATTGAAAAACAACAATCAAATATTATGCTGAATACAATCAAATATTATACAA,TAAAAGCATTTTTAAAACAAAGATTGATGTATAAGTACCTTGATTGCAGCCTAATGCATA[A/G]TAGATAGGATTGAAAAACAACAATCAAATATTATGCTGAATACAATCAAATATTATACAA,1241
ARS-BFGL-BAC-10591_dup-0_T_F_2328966407,ARS-BFGL-BAC-10591,TOP,[A/G],0070605481,AAAAAAGATGTTTATACAGTAATGCTTATTGTAGCACCATTTATAGTAGC,,,3,14,17544926,diploid,Bos taurus,UM3,0,TOP,AGTTCTTGCAAAAAAAGATGTTTATACAGTAATGCTTATTGTAGCACCATTTATAGTAGC[A/G]AAATAAATCAGAACAAAAATATCAGGGGCTAGTTAAATATTACATGATACATATCACATA,AGTTCTTGCAAAAAAAGATGTTTATACAGTAATGCTTATTGTAGCACCATTTATAGTAGC[A/G]AAATAAATCAGAACAAAAATATCAGGGGCTAGTTAAATATTACATGATACATATCACATA,1241
ARS-BFGL-BAC-10867-0_B_F_1511658130,ARS-BFGL-BAC-10867,BOT,[G/C],0058642429,TAATATTTTTGATTGATTTATGCTGGAAATTTTCTCTTTGAAATGATCAG,0015715398,TAATATTTTTGATTGATTTATGCTGGAAATTTTCTCTTTGAAATGATCAC,3,14,34639444,diploid,Bos taurus,UM3,0,BOT,ATATAACTCTTTAATATTTTTGATTGATTTATGCTGGAAATTTTCTCTTTGAAATGATCA[C/G]AACATATTTAAAATTATAAGTTACAAGTAAGAGATTTTAAATTATTTTATGCATTGTTAA,TTAACAATGCATAAAATAATTTAAAATCTCTTACTTGTAACTTATAATTTTAAATATGTT[C/G]TGATCATTTCAAAGAGAAAATTTCCAGCATAAATCAATCAAAAATATTAAAGAGTTATAT,1241
ARS-BFGL-BAC-10919-0_T_F_1511658221,ARS-BFGL-BAC-10919,TOP,[A/G],0031683470,TTGGTACTAAACTCCTAGGTCATGATCTTGACGGAAGCTTTACTGAGTGC,,,3,14,31267746,diploid,Bos taurus,UM3,0,TOP,ATGGTGAAGTTTGGTACTAAACTCCTAGGTCATGATCTTGACGGAAGCTTTACTGAGTGC[A/G]CTTGGTGTTCAAGGAAGTCTCTGCACTCTGGCCATCGGGACTATCATGTTCAAGCTTGAG,ATGGTGAAGTTTGGTACTAAACTCCTAGGTCATGATCTTGACGGAAGCTTTACTGAGTGC[A/G]CTTGGTGTTCAAGGAAGTCTCTGCACTCTGGCCATCGGGACTATCATGTTCAAGCTTGAG,1241
```

#### Sample Affymetrix manifest / annotation file content

```
Probe Set ID	Affy SNP ID	dbSNP RS ID	Chromosome	Physical Position	Strand	Flank	Allele A	Allele B	cust_snpid	ChrX pseudo-autosomal region 1	ChrX pseudo-autosomal region 2	Genetic Map
AX-116097640	Affx-114782366	---	---	---	+	GAGCACAGGACCTTAGTTTTATGCTGAGCTCATCA[C/T]TTTGTGAGCTACCTTGCATTTCAGGAGCTCTTTTG	T	C	"2""WU_10_2_1_286933"	---	---	---
AX-116097655	Affx-115251634	---	---	---	+	TGAGAAGACAGCAGAGCAGGAAACAACAGGAGCTG[A/C]TCTCTCTCCCTGTCTGGGCAACACTGGCACCTCCA	A	C	"2""WU_10_2_1_342481"	---	---	---
AX-116661926	Affx-114705997	---	---	---	+	CTAAACAAAGCCACCGACTCTGAGGAACTTCTCAC[A/G]AGCCCCACTTTTTGGCCTTTTGCGCTTTTTAGGAG	A	G	"2""WU_10_2_1_389876"	---	---	---
AX-116661927	Affx-114627059	---	---	---	+	GCATGCCAGGTGGACAGGTGGCTGCATAAGCTGAG[G/T]CTGGTCTGCATGCTCAGAAGGTGATTCGTAGTTTC	T	G	"2""WU_10_2_1_489855"	---	---	---
AX-116097685	Affx-114721431	---	---	---	+	CTGCTGGCCCCCAGCCTCGCCCCAAGTCTTCTGAC[A/G]CCTCCACCATCGAGACTGAATATCATGGAGCTGCC	A	G	"2""WU_10_2_1_538161"	---	---	---
AX-116661928	Affx-114634063	---	---	---	+	TCCGAGTTTTGAGCTGAACTCCTCCCGGCTCTGGA[C/T]GTGCCCGCGCCCCCCGTTCAGCTCCTGGTGGCGCC	T	C	"2""WU_10_2_1_565627"	---	---	---
AX-116661929	Affx-115288872	---	---	---	+	GTCCCGTCCGCCGGCCACAAGGCACAGAGGGAGGA[G/T]ATCTGACCGTGGGCACCGGCACCCGGAGCCTTCAG	T	G	"2""WU_10_2_1_573088"	---	---	---
AX-116097725	Affx-114721262	---	---	---	+	AGGCAACCAAGAAAGGCATGGGGACTTTTCTGGAA[A/G]ACAGGCCAGGGCGCCAGGCTGCTTTGGTGACGGCC	A	G	"2""WU_10_2_1_744240"	---	---	---
AX-116661930	Affx-115319167	---	---	---	+	GGGACCAGCTCCACCCCACTCCAGGGCCCGGTGAC[C/T]TTGTGGAGTCACCTTTCGTCACCAGGCTCAGGTGG	T	C	"2""WU_10_2_1_791056"	---	---	---
AX-116661931	Affx-114835802	---	---	---	+	GGAACTCGGCCAGCACCGATGGAGTCCCAGGTTTC[A/G]AAGCTCCTGCTGCATTGAGGAGACTGGTCCAAAGG	A	G	"2""WU_10_2_1_813652"	---	---	---
```

#### Sample reference genome file content

```
>1 dna:chromosome chromosome:Sscrofa11.1:1:1:274330532:1 REF
GCTTAATTTTTGTCATTTCTCACCCCTGCTCTTGAGAGCTTTTGTTGATAATGTTGTTAT
TGCTTTCATTCTGCTTTTATTTTGTAAGCCCTGCACTCATTCATCGCTGTACCCGAATAT
GAGGTAAGGAGTGGTAAAGAAAGACTGGACATAAAAGAGGAATTAGCATGTGCACTCTTC
AGATATAAATGCCATCAGTATTTTCCTATTAAAATGAAGCTTGTTTTCATCTCAGTGGAA
ATCTGTGGCTAAAGTACAACAATAGTAATGATAATGGTGAGGCTGTTGTACTTCACATCT
ATAAAATCTTGCATCAATAATTTGGTGACGATTCCTTTGGGTAGGCCTACGTTTTCTGTC
AGAGACACAGGAATACTTTATAAATAAAATTGTTAATGTCTGTTGATCTTTTTTCATTGG
AAGAGGGTGACCAGTTTACCTTTTGAAAAAAAACTTTCCTAATTTGGGCTTTTTTTTTTT
TTTCCTTTTTAGGGCTGTACCCATGGCATATGAAAGTTCCTGTGCTAAGGGTTGATCAGA
GCTGCAGCTGCCAGCTTACGCTACAGCAACACCAGATCCAGTTGTATCTGTGGCCTTTGC
```

## Output

### Position file

The **position** file describes the location of each marker on the new reference genome.

There is one data row per marker in the input manifest file.

The columns are as follows:

* marker\_name - the name of the marker, from the manifest file.
* alt\_marker\_name - the additional name of the marker, from the manifest file.
* chromosome - the chromosome containing the marker, determined using BLAST.
* position - the position of the marker on the chromosome, determined using BLAST.
* VCF\_REF - the allele observed on the forward strand of the reference genome at this position. This allele usually matches on of the two alleles described in the manifest file (when they are transformed to the forward strand of the reference), but not always.
* VCF\_ALT - one or both of the allele described in the manifest file, transformed to the forward strand of the reference genome. In most cases, there is one allele in this column, as the other matches the allele in the VCF_REF column and thus is not considered an alternate (i.e. non-reference) allele. However, in cases where neither allele is observed in the reference genome sequence, both alleles appear here, separated by a forward slash, e.g. "A/G". 

Note: Indel positions and alleles are described according to the [VCF specification](https://samtools.github.io/hts-specs/VCFv4.2.pdf).

Note: In cases where the SNP aligns with a gap in the reference genome, probe information in the manifest file is examined to determine whether the base on the left or right side of the gap is assayed by the probe, and the position and reference base are selected accordingly. In cases where probe information is not available, the reference bases to the left and right are examined. If the left base matches one of the SNP alleles, it is selected as VCF\_REF and its position is used as the position value. If the left base does not match one of the SNP alleles but the right base does, the right base is selected as VCF\_REF and its position is used. If neither the left or right bases match one of the alleles, the left base and position are used.

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

The **conversion** file describes how genotypes can be converted from one format to another, including to the forward strand of the new reference genome (the PLUS format).

There are two data rows per marker in the manifest file.

One row contains the various representations of allele A ('allele A' referring to 'allele A' in Illumina's A/B allele nomenclature), while the other contains the various representations of allele B ('allele B' referring to 'allele B' in Illumina's A/B allele nomenclature).

To transform a marker's genotype from one representation to another (e.g. a genotype of 'GC' for marker 'ARS-BFGL-BAC-10867' in 'FORWARD' format to 'TOP' format):

1. Find the two rows for marker 'ARS-BFGL-BAC-10867'.
2. Examine the 'FORWARD' column in the two rows from step 1 to find the row where the value of 'FORWARD' is 'G': the 'TOP' transformation is simply the value in the 'TOP' column of this row.
3. Examine the 'FORWARD' column in the two rows from step 1 to find the row where the value of 'FORWARD' is 'C': the 'TOP' transformation is simply the value in the 'TOP' column of this row.

Note that TOP, FORWARD, and DESIGN values are not provided for Affymetrix panels.

The columns are as follows:

* marker\_name - the name of the marker, from the manifest file.
* alt\_marker\_name - the additional name of the marker, from the manifest file.
* AB - the allele in Illumina's A/B format.
* TOP - the allele in Illumina's TOP format.
* FORWARD - the allele in Illumina's FORWARD format.
* DESIGN - the allele in Illumina's DESIGN format.
* PLUS - the allele in Illumina's PLUS format. This value is not parsed from the manifest file but instead determined by a BLAST alignment between the variant flanking sequence and the reference genome. This value represents how the allele would appear following transformation to the forward strand of the reference genome. Note that this value does not indicate whether the reference genome sequence actually contains this allele.
* VCF - a value of 'REF' in this column indicates that this allele appears on the forward strand of the reference genome, while a value of 'ALT' indicates that it does not.

Note: Indel alleles in the TOP, FORWARD, DESIGN, and PLUS columns are given as D (deletion) or I (insertion).

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

The **wide** file describes the location of each marker on the new reference genome, and provides the various representations of the A and B alleles. 

There is one data row per marker in the input manifest file.

The columns are as follows:

* marker\_name - the name of the marker, from the manifest file.
* alt\_marker\_name - the additional name of the marker, from the manifest file.
* chromosome - the chromosome containing the marker, determined using BLAST.
* position - the position of the marker on the chromosome, determined using BLAST.
* VCF\_REF - the allele observed on the forward strand of the reference genome at this position. This allele usually matches on of the two alleles described in the manifest file (when they are transformed to the forward strand of the reference), but not always.
* VCF\_ALT - one or both of the allele described in the manifest file, transformed to the forward strand of the reference genome. In most cases, there is one allele in this column, as the other matches the allele in the VCF_REF column and thus is not considered an alternate (i.e. non-reference) allele. However, in cases where neither allele is observed in the reference genome sequence, both alleles appear here, separated by a forward slash, e.g. "A/G". 
* AB_A - the A allele in Illumina's A/B format.
* AB_B - the B allele in Illumina's A/B format.
* TOP_A - the A allele in Illumina's TOP format.
* TOP_B - the B allele in Illumina's TOP format.
* FORWARD_A - the A allele in Illumina's FORWARD format.
* FORWARD_B - the B allele in Illumina's FORWARD format.
* DESIGN_A - the A allele in Illumina's DESIGN format.
* DESIGN_B - the A allele in Illumina's DESIGN format.
* PLUS_A - the A allele in Illumina's PLUS format. This value is not parsed from the manifest file but instead determined by a BLAST alignment between the variant flanking sequence and the reference genome. This value represents how the allele would appear following transformation to the forward strand of the reference genome. Note that this value does not indicate whether the reference genome sequence actually contains this allele.
* PLUS_B - the B allele in Illumina's PLUS format. This value is not parsed from the manifest file but instead determined by a BLAST alignment between the variant flanking sequence and the reference genome. This value represents how the allele would appear following transformation to the forward strand of the reference genome. Note that this value does not indicate whether the reference genome sequence actually contains this allele.
* VCF_A - a value of 'REF' in this column indicates that the A allele appears on the forward strand of the reference genome, while a value of 'ALT' indicates that it does not.
* VCF_B - a value of 'REF' in this column indicates that the A allele appears on the forward strand of the reference genome, while a value of 'ALT' indicates that it does not.

Note: Indel positions and alleles (in the VCF\_REF and VCF\_ALT columns) are described according to the [VCF specification](https://samtools.github.io/hts-specs/VCFv4.2.pdf).

Note: In cases where the SNP aligns with a gap in the reference genome, probe information in the manifest file is examined to determine whether the base on the left or right side of the gap is assayed by the probe, and the position and reference base are selected accordingly. In cases where probe information is not available, the reference bases to the left and right are examined. If the left base matches one of the SNP alleles, it is selected as VCF\_REF and its position is used as the position value. If the left base does not match one of the SNP alleles but the right base does, the right base is selected as VCF\_REF and its position is used. If neither the left or right bases match one of the alleles, the left base and position are used.

Note: Indel alleles in the TOP, FORWARD, DESIGN, and PLUS columns are given as D (deletion) or I (insertion).

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

The optional **aligment** file shows how BLAST alignments were parsed to determine variant position and alleles for use in the other output files.

#### Sample alignment file content

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

## Creating new output formats

The **wide** output format can easily be manipulated using standard command-line utilites in order to generate other useful formats.

### To create a MAP file for PLINK

For example, the two commands below can be used to generate a MAP file for PLINK. 

The first command does the following: skip comment lines; skip the header row; and, when position information is available, print the position, marker name, '0', and chromosome:

    $ cat manifest.reference.wide.csv | grep -v '#' | tail -n +2 | awk -F, '{ if ($4 != "") { print $3,$1,'0',$4 } }' OFS="\t" > temp

The second command recodes chromosomes to integers (the specific recoding needed will depend on the species and chromosome names obtained). Specifically, it changes 'X' to '30', 'Y' to '31', 'MT' to '32', and any non-integer-represented chromosomes remaining to '0':

    $ cat temp | awk '{ $1 = ($1 == "X" ? 30 : $1); $1 = ($1 == "Y" ? 31 : $1); $1 = ($1 == "MT" ? 32 : $1); $1 = (match($1, /[^0-9]/) ? 0 : $1 )}  1' OFS="\t" > manifest.reference.map
    
Using the sample **wide** file output above as input, these commands produce the following:

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

## Pipeline parameters

##### --manifest

  * The manifest file (default: genotype\_conversion\_file\_builder/data/manifest.csv).

##### --reference

  * The reference genome (default: genotype\_conversion\_file\_builder/data/reference.fa).

##### --species

  * Name of the species (used for organizing output files) (default: all).

##### --outdir

  * Output directory to hold the results (default: genotype\_conversion\_file\_builder/results).

##### --chunksize

  * Number of variant sequences to process per BLAST job (default: 10000).

##### --dev 

  * Whether to process a small number of markers and then exit (default: false).

##### --align

  * Whether to include an alignment file in the output directory showing how BLAST alignments were parsed to determine position, allele, and strand information (default: false).

##### --blast   

  * Whether to include a BLAST results file in the output directory (default: false).

##### Sample commands

    $ ./nextflow run genotype_conversion_file_builder \
    --manifest BovineSNP50_v3_A1.csv \
    --reference ARS-UCD1.2_Btau5.0.1Y.fa \
    --species bos_taurus \
    --outdir results 


## Output folder structure

```
outdir
  ├── species                     
      ├── reference             
          ├── manifest.reference.conversion.csv
          ├── manifest.reference.position.csv
          ├── manifest.reference.wide.csv
          ├── manifest.reference.alignment.txt
          ├── manifest.reference.blast.csv
```

## Dependencies

* Nextflow (20.01.0 or higher)
* Perl
* BLAST+
