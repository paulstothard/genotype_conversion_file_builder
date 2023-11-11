# genotype\_conversion\_file\_builder

## Converting genotypes using a conversion file

The R code below demonstrates the conversion of some Illumina genotypes in
FORWARD format to AB format and then to the forward strand of the reference
genome. The converted genotypes are written to a VCF file. 

#### Sample input genotypes

```text
[Header]
GSGT Version	2.0.4
Processing Date	6/14/2019 3:19 PM
Content		50kv3.bpm
Num SNPs	21
Total SNPs	21
Num Samples	10
Total Samples	10
[Data]
	Sample1	Sample2	Sample3	Sample4	Sample5	Sample6	Sample7	Sample8	Sample9	Sample10
ABCA12	AA	AA	AA	AA	AA	AA	AA	AA	AA	AA
APAF1	CC	CC	CC	CC	CC	CC	CC	CC	CC	CC
ARS-BFGL-BAC-10172	GG	GG	GG	GG	GG	GG	AG	AG	GG	GG
ARS-BFGL-BAC-1020	AA	GG	GG	GG	AG	AA	AA	GG	GG	GG
ARS-BFGL-BAC-10245	--	--	--	--	--	--	--	--	--	--
ARS-BFGL-BAC-10345	AC	AA	AA	AA	AA	AC	AA	AA	CC	CC
ARS-BFGL-BAC-10375	--	--	--	--	--	--	--	--	--	--
ARS-BFGL-BAC-10591	AA	AA	AG	AA	AA	AA	AA	AG	GG	AA
ARS-BFGL-BAC-10867	GC	GG	GC	GC	GC	GC	GC	GC	GG	GG
ARS-BFGL-BAC-10919	AG	AG	AA	AG	AA	AA	AA	GG	AG	AA
ARS-BFGL-BAC-10952	AA	AG	AG	AG	AA	AA	AG	AA	AA	AG
ARS-BFGL-BAC-10960	GG	GG	GG	AG	GG	GG	GG	GG	GG	AG
ARS-BFGL-BAC-10972	CC	CC	GG	CC	CC	GC	CC	CC	GC	CC
ARS-BFGL-BAC-10975	AA	AG	AG	AA	AG	AA	AG	AA	AG	AG
ARS-BFGL-BAC-10986	GG	GG	TG	TG	TG	GG	TG	GG	GG	GG
ARS-BFGL-BAC-10993	CC	CC	CC	CC	CC	CC	TT	TC	CC	CC
ARS-BFGL-BAC-11000	TT	TT	TG	GG	TG	TT	TG	TG	TT	TT
ARS-BFGL-BAC-11003	TC	TT	TT	TC	TC	TT	TC	TT	TT	TT
ARS-BFGL-BAC-11007	TT	TC	TC	TC	TC	TC	TC	CC	TC	TC
ARS-BFGL-BAC-11025	GG	TG	GG	TG	TG	TG	TG	GG	GG	GG
ARS-BFGL-BAC-11028	AA	AA	AA	AA	AA	AG	AA	AA	AA	AA
```

#### Sample **wide** file

```text
#SPECIES=bos_taurus
#REF=ARS-UCD1_2_Btau5_0_1Y
#PANEL=BovineSNP50_v3_A1
#
#Wide file generated on Monday April 13 03:31:46 2020.
#Using genotype_conversion_file_builder, written by Paul Stothard, stothard@ualberta.ca.
#
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
ARS-BFGL-BAC-10952,ARS-BFGL-BAC-10952-0_T_F_1511658173,10,19055444,A,G,A,B,A,G,A,G,A,G,A,G,REF,ALT
ARS-BFGL-BAC-10960,ARS-BFGL-BAC-10960-0_T_F_1511657561,10,20776707,T,C,A,B,A,G,A,G,A,G,T,C,REF,ALT
ARS-BFGL-BAC-10972,ARS-BFGL-BAC-10972-0_B_F_1511657864,10,20958739,C,G,A,B,C,G,G,C,G,C,C,G,REF,ALT
ARS-BFGL-BAC-10975,ARS-BFGL-BAC-10975-0_T_F_1511662923,10,21390531,C,T,A,B,A,G,A,G,A,G,T,C,ALT,REF
ARS-BFGL-BAC-10986,ARS-BFGL-BAC-10986-0_T_R_1511657699,10,26494631,G,T,A,B,A,C,T,G,A,C,T,G,ALT,REF
ARS-BFGL-BAC-10993,ARS-BFGL-BAC-10993_dup-0_T_R_2328966421,10,78170657,C,T,A,B,A,G,T,C,A,G,T,C,ALT,REF
ARS-BFGL-BAC-11000,ARS-BFGL-BAC-11000_dup-0_B_F_2328966422,10,78907161,T,G,A,B,A,C,T,G,T,G,T,G,REF,ALT
ARS-BFGL-BAC-11003,ARS-BFGL-BAC-11003-0_B_F_1511658066,10,80066858,A,G,A,B,A,G,T,C,T,C,A,G,REF,ALT
ARS-BFGL-BAC-11007,ARS-BFGL-BAC-11007_dup-0_B_F_2328966425,10,80433411,C,T,A,B,A,G,T,C,T,C,T,C,ALT,REF
ARS-BFGL-BAC-11025,ARS-BFGL-BAC-11025-0_B_F_1511663050,10,84139423,G,T,A,B,A,C,T,G,T,G,T,G,ALT,REF
ARS-BFGL-BAC-11028,ARS-BFGL-BAC-11028-0_T_F_1511657863,10,85258477,T,C,A,B,A,G,A,G,A,G,T,C,REF,ALT
```

#### R code converting FORWARD to AB and then AB to VCF

```r
library(tidyverse)

#read genotypes
genotypes <- read_tsv("50kv3_mFWD_14June2019.txt", skip = 9)

#get list of samples
sample_names <- names(genotypes)[-1]

#change first column to ID
genotypes %>% rename(ID = X1) ->
  genotypes

#read_conversion file
conversion <- read_csv("BovineSNP50_v3_A1.ARS-UCD1_2_Btau5_0_1Y.wide.csv.gz", comment = "#")

#change marker_name to ID
conversion <- rename(conversion, ID = marker_name)

#add columns from conversion file to genotypes
genotypes_with_conversion_info <- left_join(genotypes, conversion, by="ID")

#function to recode genotypes to AB
genotype_to_AB <- function (df, col, format) {
  df[[col]] <-
    ifelse(df[[col]] == paste(df[[paste(format, "A", sep = "_")]], df[[paste(format, "A", sep = "_")]], sep = ""),
           "AA",
           ifelse(
             df[[col]] == paste(df[[paste(format, "B", sep = "_")]], df[[paste(format, "B", sep = "_")]], sep = ""),
             "BB",
             ifelse(
               df[[col]] == paste(df[[paste(format, "A", sep = "_")]], df[[paste(format, "B", sep = "_")]], sep = ""),
               "AB",
               ifelse(df[[col]] == paste(df[[paste(format, "B", sep = "_")]], df[[paste(format, "A", sep = "_")]], sep = ""), "BA", df[[col]])
             )
           ))
  return(df)
}

#function to recode genotypes from AB
genotype_from_AB <- function (df, col, format) {
  df[[col]] <-
    ifelse(df[[col]] == "AA",
           paste(df[[paste(format, "A", sep = "_")]], df[[paste(format, "A", sep = "_")]], sep = ""),
           ifelse(
             df[[col]] == "BB",
             paste(df[[paste(format, "B", sep = "_")]], df[[paste(format, "B", sep = "_")]], sep = ""),
             ifelse(
               df[[col]] == "AB",
               paste(df[[paste(format, "A", sep = "_")]], df[[paste(format, "B", sep = "_")]], sep = ""),
               ifelse(df[[col]] == "BA", paste(df[[paste(format, "B", sep = "_")]], df[[paste(format, "A", sep = "_")]], sep = ""), df[[col]])
             )
           ))
  return(df)
}

#covert from FORWARD to AB and then AB to VCF
for (sample in sample_names) {
  genotypes_with_conversion_info <- genotype_to_AB(genotypes_with_conversion_info, sample, "FORWARD")
}

for (sample in sample_names) {
  genotypes_with_conversion_info <- genotype_from_AB(genotypes_with_conversion_info, sample, "VCF")
}

#recode REF and ALT as 0 and 1
genotypes_with_conversion_info %>% 
  mutate_at(
    vars(one_of(sample_names)),
    list(~case_when(
      . == "REFREF" ~ "0/0",
      . == "ALTALT" ~ "1/1",
      . == "REFALT" ~ "0/1",      
      . == "ALTREF" ~ "0/1",
      TRUE ~ './.'))) ->
  converted_genotypes

#add columns to VCF
vcf <- tibble(CHROM = converted_genotypes$chromosome)

vcf %>%
  add_column(POS = converted_genotypes$position) %>%
  add_column(ID = converted_genotypes$ID) %>%
  add_column(REF = converted_genotypes$VCF_REF) %>%  
  add_column(ALT = converted_genotypes$VCF_ALT) %>%
  add_column(QUAL = rep(".", length(vcf))) %>%
  add_column(FILTER = rep(".", length(vcf))) %>%
  add_column(INFO = rep(".", length(vcf))) %>%
  add_column(FORMAT = rep("GT", length(vcf))) ->
  vcf

#add genotypes to VCF
for (column_name in sample_names) {
  vcf %>%
    add_column(!!(column_name) := converted_genotypes[[column_name]]) ->
    vcf
}

#remove rows where POS is NA
vcf %>% drop_na(POS) ->
  vcf

#keep rows with single base in REF and ALT
vcf %>% 
  filter(str_detect(REF, "^[GATCN]$")) %>%
  filter(str_detect(ALT, "^[GATCN]$")) ->
  vcf

#add comment character
vcf <- rename(vcf, `#CHROM` = CHROM)

#add header info
writeLines(c("##fileformat=VCFv4.2", paste(names(vcf), collapse = "\t")), con = "genotypes.vcf")

#write vcf to file
write.table(vcf, file = "genotypes.vcf", row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t", append=TRUE)
```

#### VCF output

```text
##fileformat=VCFv4.2
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	Sample1	Sample2	Sample3	Sample4	Sample5	Sample6	Sample7	Sample8	Sample9	Sample10
2	103030489	ABCA12	T	C	.	.	.	GT	0/0	0/0	0/0	0/0	0/0	0/0	0/0	0/0	0/0	0/0
5	62810245	APAF1	C	T	.	.	.	GT	0/0	0/0	0/0	0/0	0/0	0/0	0/0	0/0	0/0	0/0
14	5342658	ARS-BFGL-BAC-10172	C	T	.	.	.	GT	0/0	0/0	0/0	0/0	0/0	0/0	0/1	0/1	0/0	0/0
14	6889656	ARS-BFGL-BAC-1020	T	C	.	.	.	GT	0/0	1/1	1/1	1/1	0/1	0/0	0/0	1/1	1/1	1/1
14	30124134	ARS-BFGL-BAC-10245	G	A	.	.	.	GT	./.	./.	./.	./.	./.	./.	./.	./.	./.	./.
14	5105727	ARS-BFGL-BAC-10345	T	G	.	.	.	GT	0/1	0/0	0/0	0/0	0/0	0/1	0/0	0/0	1/1	1/1
14	5587750	ARS-BFGL-BAC-10375	G	A	.	.	.	GT	./.	./.	./.	./.	./.	./.	./.	./.	./.	./.
14	15956824	ARS-BFGL-BAC-10591	A	G	.	.	.	GT	0/0	0/0	0/1	0/0	0/0	0/0	0/0	0/1	1/1	0/0
14	32554055	ARS-BFGL-BAC-10867	C	G	.	.	.	GT	0/1	1/1	0/1	0/1	0/1	0/1	0/1	0/1	1/1	1/1
14	29573682	ARS-BFGL-BAC-10919	T	C	.	.	.	GT	0/1	0/1	0/0	0/1	0/0	0/0	0/0	1/1	0/1	0/0
10	19055444	ARS-BFGL-BAC-10952	A	G	.	.	.	GT	0/0	0/1	0/1	0/1	0/0	0/0	0/1	0/0	0/0	0/1
10	20776707	ARS-BFGL-BAC-10960	T	C	.	.	.	GT	1/1	1/1	1/1	0/1	1/1	1/1	1/1	1/1	1/1	0/1
10	20958739	ARS-BFGL-BAC-10972	C	G	.	.	.	GT	1/1	1/1	0/0	1/1	1/1	0/1	1/1	1/1	0/1	1/1
10	21390531	ARS-BFGL-BAC-10975	C	T	.	.	.	GT	1/1	0/1	0/1	1/1	0/1	1/1	0/1	1/1	0/1	0/1
10	26494631	ARS-BFGL-BAC-10986	G	T	.	.	.	GT	0/0	0/0	0/1	0/1	0/1	0/0	0/1	0/0	0/0	0/0
10	78170657	ARS-BFGL-BAC-10993	C	T	.	.	.	GT	0/0	0/0	0/0	0/0	0/0	0/0	1/1	0/1	0/0	0/0
10	78907161	ARS-BFGL-BAC-11000	T	G	.	.	.	GT	0/0	0/0	0/1	1/1	0/1	0/0	0/1	0/1	0/0	0/0
10	80066858	ARS-BFGL-BAC-11003	A	G	.	.	.	GT	0/1	0/0	0/0	0/1	0/1	0/0	0/1	0/0	0/0	0/0
10	80433411	ARS-BFGL-BAC-11007	C	T	.	.	.	GT	1/1	0/1	0/1	0/1	0/1	0/1	0/1	0/0	0/1	0/1
10	84139423	ARS-BFGL-BAC-11025	G	T	.	.	.	GT	0/0	0/1	0/0	0/1	0/1	0/1	0/1	0/0	0/0	0/0
10	85258477	ARS-BFGL-BAC-11028	T	C	.	.	.	GT	0/0	0/0	0/0	0/0	0/0	0/1	0/0	0/0	0/0	0/0
```

The VCF can be further processed using Picard, to add a complete header:

```bash
#create the sequence dictionary for the reference genome
java -jar picard.jar CreateSequenceDictionary \
R=ARS-UCD1.2_Btau5.0.1Y.fa O=ARS-UCD1.2_Btau5.0.1Y.dict

#update the sequence dictionary in the VCF
java -jar picard.jar UpdateVcfSequenceDictionary \
--INPUT genotypes.vcf --OUTPUT genotypes_updated.vcf \
--SEQUENCE_DICTIONARY ARS-UCD1.2_Btau5.0.1Y.fa

#complete the VCF header
java -jar picard.jar FixVcfHeader \
I=genotypes_updated.vcf O=genotypes_updated_fixed.vcf

#sort the VCF
java -jar picard.jar SortVcf \
I=genotypes_updated_fixed.vcf O=genotypes_updated_fixed_sorted.vcf
```

Comparisons can be conducated against other VCF files, to assess concordance:

```bash
java -jar picard.jar GenotypeConcordance \
CALL_VCF=some_other.vcf CALL_SAMPLE=Sample1 \
TRUTH_VCF=genotypes_updated_fixed_sorted.vcf TRUTH_SAMPLE=Sample1 \
O=Sample1_concordance
```
