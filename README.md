# genotype\_conversion\_file\_builder

The genotype\_conversion\_file\_builder is a pipeline for determining the
genomic location and transformation rules for the variants described in
Illumina or Affymetrix genotype panel manifest files.

Briefly, the pipeline extracts the flanking sequence of each variant from the
manifest file, and performs a BLAST search comparing each flanking sequence
against a new reference genome of interest. Next, the resulting BLAST
alignments are parsed in conjunction with the manifest file, to establish the
position of each variant on the reference genome, and to generate simple
transformation rules that can be used to convert genotypes between any of the
standard formats (AB, TOP, FORWARD, DESIGN) and from any of the standard
formats to the forward strand of the reference genome (PLUS). An indication of
which allele is observed in the reference genome is also provided. The position
information and transformation rules are written to separate files, referred to
as **position** and **conversion** files, respectively. An additional **wide**
file provides the position and conversion information together in a format that
can be easily converted to files used by downstream tools like PLINK. See the
[output file documentation](docs/README_output.md) for detailed descriptions of
the output files and sample output. See the [conversion
example documentation](docs/README_conversion.md) for an example of using a
conversion file.

## Quick start

Create and activate a conda environment with the required dependencies, e.g.:

```bash
conda create -y -c conda-forge -c bioconda --name gcfb perl blast nextflow=20.01.0
conda activate gcfb
```

You can then execute the pipeline from within the project directory:

```bash
nextflow run main.nf
```

By default the pipeline is executed by using a small data set included with the
project and writes the results to the `output` directory.

If Nextflow reports an error about the version of Java being used, you may need
to set the `JAVA_CMD` and `JAVA_HOME` environment variables to point to the Java
installation in the conda environment before running the pipeline. For example:

```bash
conda activate gcfb
export CONDA_PREFIX=$(conda info --base)/envs/gcfb
export JAVA_CMD="$CONDA_PREFIX/lib/jvm/bin/java"
export JAVA_HOME="$CONDA_PREFIX/lib/jvm"
nextflow run main.nf
```

## Input

The pipeline requires an Illumina or Affymetrix manifest file and reference
genome as input.

### Sample Illumina manifest file content

```text
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

### Sample Affymetrix manifest / annotation file content

```text
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

### Sample reference genome file content

```text
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

The default output consists of two CSV files: one **conversion** file
describing for each marker how to convert genotypes from one format into
another, including to the forward strand of the reference genome; and one
**position** file giving the position of each marker on the reference genome
along with an indication of which, if any, allele is found in the reference
genome and which would be classified as an alternate allele (i.e.
non-reference-genome) allele. An optional **wide** CSV file contains the
combined information from the **conversion** and **position** files. An
optional **alignment** file contains annotated sequence alignments generated as
part of the BLAST results parsing process. Lastly, an optional **blast** file
displays raw BLAST results generated by the pipeline. More detailed
descriptions and sample output are available in the [output file
README](docs/README_output.md).

## Pipeline parameters

### --manifest

- The manifest file (required).

### --reference

- The reference genome (required).

### --species

- Name of the species (used for organizing output files) (default: all).

### --outdir

- Output directory to hold the results (default: output).

### --chunksize

- Number of variant sequences to process per BLAST job (default: 10000).

### --dev

- Process a small number of markers and then exit.

### --align

- Include an alignment file in the output directory showing how BLAST
  alignments were parsed to determine position, allele, and strand
  information.

### --blast

- Include a BLAST results file in the output directory.

### Sample command

```bash
nextflow main.nf \
--manifest data/manifest.csv \
--reference data/reference.fa \
--species bos_taurus \
--align \
--blast \
--outdir test_output
```

## Output folder structure

The above command will create the following folder structure:

```text
output
└── bos_taurus
    └── reference
        ├── manifest.reference.alignment.txt
        ├── manifest.reference.blast.csv
        ├── manifest.reference.conversion.csv
        ├── manifest.reference.position.csv
        └── manifest.reference.wide.csv
```

## Dependencies

- Nextflow version 20.01.0
- Perl
- BLAST+
