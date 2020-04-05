# Test data files

The test dataset consists of the following:

reference.fa - a single random DNA sequence 1000 bases in length:

```
>1 random_1000_bases
gtttcaaactgtccaggtctaatggtgtgaagcgatactgtttgatgcctggttggtgca
actggcggcaaaacggcttaaagctccagatgccacattagtgaggacctggtgtattac
gttggattaccctgtgacagctcaggcacacaccaggattaggaaattagcatcgtaaga
ctagtccgtacaaacaaaaacaaaaaatagaagtttcaagtggttcccgttgttggagcg
cgtaagggatacgtaataataggtcaggtcagaaagaagcggcttggagccccatttata
tctttaacatcgggagaatcatccgtcgaccttgtggcacggtttgccggcgcgaatagg
gtggacgtagatattagacggagacggttgaagcttacctcgtagctgggaactctatgg
agtggctaccctatggacttcctccggcagcgcaggtttcaaaatgagcaatcagcaatt
cctaggatgaagccgcgagctaaaaacttcagcgcttccgcatgcgttactgtcctggag
agttttaatcgggtgtctgtcacacacctcggatctcgcccactgcgtgagccttagata
cgcagtgatgcaatggatgtaggtctctagcgaagccaagtctagtcgcgcctccgcgcg
caagtctgcgataatgggcaagtgcctgcagtctaagtataactcgtcgccagatgcggc
ataggattatgagcgtttcccctgcgcgttatggtacccggaccgggcccgcgacacacg
gtgcacaggtagagctagttaggcgtaacgacgccagaattatgtttattatttacctgt
gacgcaagctaacagtagtgccccggggtgctagtaagtaagcagagaactgggatgtag
ccgtcaaaggtcttttgccgagatgactactacaaccgtatagacaaagcgtgcacatta
catggggagtacctacttccagaacctgtgtcttcctagt
```

manifest.csv - an artifical Illumina manifest file describing five SNPs: 

```
IlmnID,Name,IlmnStrand,SNP,AddressA_ID,AlleleA_ProbeSeq,AddressB_ID,AlleleB_ProbeSeq,GenomeBuild,Chr,MapInfo,Ploidy,Species,Source,SourceVersion,SourceStrand,SourceSeq,TopGenomicSeq,BeadSetID
SNP1-0_T_F_1511658221,SNP1,TOP,[A/G],0031683470,ACAAAAAATAGAAGTTTCAAGTGGTTCCCGTTGTTGGAGCGCGTAAGGGATACGTAATAATAGGTCAGGTCAGAAAGAAGCGGCTTGGAGCCCCATTTAT,,,3,14,31267746,diploid,Bos taurus,UM3,0,TOP,ACAAAAAATAGAAGTTTCAAGTGGTTCCCGTTGTTGGAGCGCGTAAGGGATACGTAATAATAGGTCAGGTCAGAAAGAAGCGGCTTGGAGCCCCATTTAT[A/G]TCTTTAACATCGGGAGAATCATCCGTCGACCTTGTGGCACGGTTTGCCGGCGCGAATAGGGTGGACGTAGATATTAGACGGAGACGGTTGAAGCTTACCT,ACAAAAAATAGAAGTTTCAAGTGGTTCCCGTTGTTGGAGCGCGTAAGGGATACGTAATAATAGGTCAGGTCAGAAAGAAGCGGCTTGGAGCCCCATTTAT[A/G]TCTTTAACATCGGGAGAATCATCCGTCGACCTTGTGGCACGGTTTGCCGGCGCGAATAGGGTGGACGTAGATATTAGACGGAGACGGTTGAAGCTTACCT,1241
SNP2-0_B_F_1511663050,SNP2,BOT,[T/G],0017649448,ACGCAGTGATGCAATGGATGTAGGTCTCTAGCGAAGCCAAGTCTAGTCGCGCCTCCGCGCGCAAGTCTGCGATAATGGGCAAGTGCCTGCAGTCTAAGTA,,,3,10,84516867,diploid,Bos taurus,UM3,0,BOT,ACGCAGTGATGCAATGGATGTAGGTCTCTAGCGAAGCCAAGTCTAGTCGCGCCTCCGCGCGCAAGTCTGCGATAATGGGCAAGTGCCTGCAGTCTAAGTA[T/G]AACTCGTCGCCAGATGCGGCATAGGATTATGAGCGTTTCCCCTGCGCGTTATGGTACCCGGACCGGGCCCGCGACACACGGTGCACAGGTAGAGCTAGTT,AACTAGCTCTACCTGTGCACCGTGTGTCGCGGGCCCGGTCCGGGTACCATAACGCGCAGGGGAAACGCTCATAATCCTATGCCGCATCTGGCGACGAGTT[A/C]TACTTAGACTGCAGGCACTTGCCCATTATCGCAGACTTGCGCGCGGAGGCGCGACTAGACTTGGCTTCGCTAGAGACCTACATCCATTGCATCACTGCGT,1241
SNP3-0_B_F_1511657910,SNP3,BOT,[T/G],0047747431,TAGGCGTAACGACGCCAGAATTATGTTTATTATTTACCTGTGACGCAAGCTAACAGTAGTGCCCCGGGGTGCTAGTAAGTAAGCAGAGAACTGGGATGTA,,,3,11,22201316,diploid,Bos taurus,UM3,0,BOT,TAGGCGTAACGACGCCAGAATTATGTTTATTATTTACCTGTGACGCAAGCTAACAGTAGTGCCCCGGGGTGCTAGTAAGTAAGCAGAGAACTGGGATGTA[T/G]CCGTCAAAGGTCTTTTGCCGAGATGACTACTACAACCGTATAGACAAAGCGTGCACATTACATGGGGAGTACCTACTTCCAGAACCTGTGTCTTCCTAGT,ACTAGGAAGACACAGGTTCTGGAAGTAGGTACTCCCCATGTAATGTGCACGCTTTGTCTATACGGTTGTAGTAGTCATCTCGGCAAAAGACCTTTGACGG[A/C]TACATCCCAGTTCTCTGCTTACTTACTAGCACCCCGGGGCACTACTGTTAGCTTGCGTCACAGGTAAATAATAAACATAATTCTGGCGTCGTTACGCCTA,1241
SNP4_dup-0_B_F_2328966441,SNP4,BOT,[T/C],0039612441,TATAAATGGGGCTCCAAGCCGCTTCTTTCTGACCTGACCTATTATTACGTATCCCTTACGCGCTCCAACAACGGGAACCACTTGAAACTTCTATTTTTTG,,,3,1,134030804,diploid,Bos taurus,UM3,0,BOT,TATAAATGGGGCTCCAAGCCGCTTCTTTCTGACCTGACCTATTATTACGTATCCCTTACGCGCTCCAACAACGGGAACCACTTGAAACTTCTATTTTTTG[T/C]TTTTGTTTGTACGGACTAGTCTTACGATGCTAATTTCCTAATCCTGGTGTGTGCCTGAGCTGTCACAGGGTAATCCAACGTAATACACCAGGTCCTCACT,AGTGAGGACCTGGTGTATTACGTTGGATTACCCTGTGACAGCTCAGGCACACACCAGGATTAGGAAATTAGCATCGTAAGACTAGTCCGTACAAACAAAA[A/G]CAAAAAATAGAAGTTTCAAGTGGTTCCCGTTGTTGGAGCGCGTAAGGGATACGTAATAATAGGTCAGGTCAGAAAGAAGCGGCTTGGAGCCCCATTTATA,1241
SNP5-0_T_R_1511657699,SNP5,TOP,[A/C],0032703444,CTACATCCCAGTTCTCTGCTTACTTACTAGCACCCCGGGGCACTACTGTTAGCTTGCGTCACAGGTAAATAATAAACATAATTCTGGCGTCGTTACGCCT,,,3,10,26527257,diploid,Bos taurus,UM3,0,BOT,TAACTCGTCGCCAGATGCGGCATAGGATTATGAGCGTTTCCCCTGCGCGTTATGGTACCCGGACCGGGCCCGCGACACACGGTGCACAGGTAGAGCTAGT[T/G]AGGCGTAACGACGCCAGAATTATGTTTATTATTTACCTGTGACGCAAGCTAACAGTAGTGCCCCGGGGTGCTAGTAAGTAAGCAGAGAACTGGGATGTAG,CTACATCCCAGTTCTCTGCTTACTTACTAGCACCCCGGGGCACTACTGTTAGCTTGCGTCACAGGTAAATAATAAACATAATTCTGGCGTCGTTACGCCT[A/C]ACTAGCTCTACCTGTGCACCGTGTGTCGCGGGCCCGGTCCGGGTACCATAACGCGCAGGGGAAACGCTCATAATCCTATGCCGCATCTGGCGACGAGTTA,1241
```

The flanking sequence of each SNP was derived from the reference.fa sequence such that the locations of the SNPs are as follows:

* SNP1: position 300 on the forward strand
* SNP2: position 700 on the forward strand
* SNP3: position 900 on the forward strand
* SNP4: position 200 on the reverse strand
* SNP5: position 800 on the reverse strand

```
      1       2   3   Forward strand SNP positions
  a a a t c a t t g t Forward strand bases     
0_1_2_3_4_5_6_7_8_9_0 Base positions (100 bases)
  t t t a g t a a c a Reverse strand bases
    4           5     Reverse strand SNP positions
```

The expected **position** file content for this test data is as follows:

```
marker_name,alt_marker_name,chromosome,position,VCF_REF,VCF_ALT
SNP1,SNP1-0_T_F_1511658221,1,300,A,G
SNP2,SNP2-0_B_F_1511663050,1,700,T,G
SNP3,SNP3-0_B_F_1511657910,1,900,G,T
SNP4,SNP4_dup-0_B_F_2328966441,1,200,A,G
SNP5,SNP5-0_T_R_1511657699,1,800,T,G
```

The expected **conversion** file content for this test data is as follows:

```
marker_name,alt_marker_name,AB,TOP,FORWARD,DESIGN,PLUS,VCF
SNP1,SNP1-0_T_F_1511658221,A,A,A,A,A,REF
SNP1,SNP1-0_T_F_1511658221,B,G,G,G,G,ALT
SNP2,SNP2-0_B_F_1511663050,A,A,T,T,T,REF
SNP2,SNP2-0_B_F_1511663050,B,C,G,G,G,ALT
SNP3,SNP3-0_B_F_1511657910,A,A,T,T,T,ALT
SNP3,SNP3-0_B_F_1511657910,B,C,G,G,G,REF
SNP4,SNP4_dup-0_B_F_2328966441,A,A,T,T,A,REF
SNP4,SNP4_dup-0_B_F_2328966441,B,G,C,C,G,ALT
SNP5,SNP5-0_T_R_1511657699,A,A,T,A,T,REF
SNP5,SNP5-0_T_R_1511657699,B,C,G,C,G,ALT
```

The expected **wide** file content for this test data is as follows:

```
marker_name,alt_marker_name,chromosome,position,VCF_REF,VCF_ALT,AB_A,AB_B,TOP_A,TOP_B,FORWARD_A,FORWARD_B,DESIGN_A,DESIGN_B,PLUS_A,PLUS_B,VCF_A,VCF_B
SNP1,SNP1-0_T_F_1511658221,1,300,A,G,A,B,A,G,A,G,A,G,A,G,REF,ALT
SNP2,SNP2-0_B_F_1511663050,1,700,T,G,A,B,A,C,T,G,T,G,T,G,REF,ALT
SNP3,SNP3-0_B_F_1511657910,1,900,G,T,A,B,A,C,T,G,T,G,T,G,ALT,REF
SNP4,SNP4_dup-0_B_F_2328966441,1,200,A,G,A,B,A,G,T,C,T,C,A,G,REF,ALT
SNP5,SNP5-0_T_R_1511657699,1,800,T,G,A,B,A,C,T,G,A,C,T,G,REF,ALT
```

The expected optional **alignment** file content for this test data is as follows (to generate this file, use the --align option):

```
========================================================================================
SNP1,SNP1-0_T_F_1511658221
SNP1
Type: SNP
      QUERY ACAAAAAATAGAAGTTTCAAGTGGTTCCCGTTGTTGGAGCGCGTAAGGGATACGTAATAATAGGTCAGGTCAGAAAGAAGCGGCTTGGAGCCCCATTTATNTCTTTAACATCGGGAGAATCATCCGTCGACCTTGTGGCACGGTTTGCCGGCGCGAATAGGGTGGACGTAGATATTAGACGGAGACGGTTGAAGCTTACCT
    TO LEFT                                                                                                 299|
        200 ACAAAAAATAGAAGTTTCAAGTGGTTCCCGTTGTTGGAGCGCGTAAGGGATACGTAATAATAGGTCAGGTCAGAAAGAAGCGGCTTGGAGCCCCATTTATATCTTTAACATCGGGAGAATCATCCGTCGACCTTGTGGCACGGTTTGCCGGCGCGAATAGGGTGGACGTAGATATTAGACGGAGACGGTTGAAGCTTACCT 400
      PROBE                                                                                                  >>>
      RULER |         |         |         |         |         |         |         |         |         |         |
    ALLELE1                                                                                                     A
    ALLELE2                                                                                                     G
   POSITION                                                                                                  300|
        REF                                                                                                     A
    VCF_REF                                                                                                     A
    VCF_ALT                                                                                                     G
========================================================================================
SNP2,SNP2-0_B_F_1511663050
SNP2
Type: SNP
      QUERY ACGCAGTGATGCAATGGATGTAGGTCTCTAGCGAAGCCAAGTCTAGTCGCGCCTCCGCGCGCAAGTCTGCGATAATGGGCAAGTGCCTGCAGTCTAAGTANAACTCGTCGCCAGATGCGGCATAGGATTATGAGCGTTTCCCCTGCGCGTTATGGTACCCGGACCGGGCCCGCGACACACGGTGCACAGGTAGAGCTAGTT
    TO LEFT                                                                                                 699|
        600 ACGCAGTGATGCAATGGATGTAGGTCTCTAGCGAAGCCAAGTCTAGTCGCGCCTCCGCGCGCAAGTCTGCGATAATGGGCAAGTGCCTGCAGTCTAAGTATAACTCGTCGCCAGATGCGGCATAGGATTATGAGCGTTTCCCCTGCGCGTTATGGTACCCGGACCGGGCCCGCGACACACGGTGCACAGGTAGAGCTAGTT 800
      PROBE                                                                                                  >>>
      RULER |         |         |         |         |         |         |         |         |         |         |
    ALLELE1                                                                                                     T
    ALLELE2                                                                                                     G
   POSITION                                                                                                  700|
        REF                                                                                                     T
    VCF_REF                                                                                                     T
    VCF_ALT                                                                                                     G
========================================================================================
SNP3,SNP3-0_B_F_1511657910
SNP3
Type: SNP
      QUERY TAGGCGTAACGACGCCAGAATTATGTTTATTATTTACCTGTGACGCAAGCTAACAGTAGTGCCCCGGGGTGCTAGTAAGTAAGCAGAGAACTGGGATGTANCCGTCAAAGGTCTTTTGCCGAGATGACTACTACAACCGTATAGACAAAGCGTGCACATTACATGGGGAGTACCTACTTCCAGAACCTGTGTCTTCCTAGT
    TO LEFT                                                                                                 899|
        800 TAGGCGTAACGACGCCAGAATTATGTTTATTATTTACCTGTGACGCAAGCTAACAGTAGTGCCCCGGGGTGCTAGTAAGTAAGCAGAGAACTGGGATGTAGCCGTCAAAGGTCTTTTGCCGAGATGACTACTACAACCGTATAGACAAAGCGTGCACATTACATGGGGAGTACCTACTTCCAGAACCTGTGTCTTCCTAGT 1000
      PROBE                                                                                                  >>>
      RULER |         |         |         |         |         |         |         |         |         |         |
    ALLELE1                                                                                                     T
    ALLELE2                                                                                                     G
   POSITION                                                                                                  900|
        REF                                                                                                     G
    VCF_REF                                                                                                     G
    VCF_ALT                                                                                                     T
========================================================================================
SNP4,SNP4_dup-0_B_F_2328966441
SNP4
Type: SNP
      QUERY AGTGAGGACCTGGTGTATTACGTTGGATTACCCTGTGACAGCTCAGGCACACACCAGGATTAGGAAATTAGCATCGTAAGACTAGTCCGTACAAACAAAANCAAAAAATAGAAGTTTCAAGTGGTTCCCGTTGTTGGAGCGCGTAAGGGATACGTAATAATAGGTCAGGTCAGAAAGAAGCGGCTTGGAGCCCCATTTATA
    TO LEFT                                                                                                 199|
        100 AGTGAGGACCTGGTGTATTACGTTGGATTACCCTGTGACAGCTCAGGCACACACCAGGATTAGGAAATTAGCATCGTAAGACTAGTCCGTACAAACAAAAACAAAAAATAGAAGTTTCAAGTGGTTCCCGTTGTTGGAGCGCGTAAGGGATACGTAATAATAGGTCAGGTCAGAAAGAAGCGGCTTGGAGCCCCATTTATA 300
      PROBE                                                                                                      <<<
      RULER |         |         |         |         |         |         |         |         |         |         |
    ALLELE1                                                                                                     G
    ALLELE2                                                                                                     A
   POSITION                                                                                                  200|
        REF                                                                                                     A
    VCF_REF                                                                                                     A
    VCF_ALT                                                                                                     G
========================================================================================
SNP5,SNP5-0_T_R_1511657699
SNP5
Type: SNP
      QUERY TAACTCGTCGCCAGATGCGGCATAGGATTATGAGCGTTTCCCCTGCGCGTTATGGTACCCGGACCGGGCCCGCGACACACGGTGCACAGGTAGAGCTAGTNAGGCGTAACGACGCCAGAATTATGTTTATTATTTACCTGTGACGCAAGCTAACAGTAGTGCCCCGGGGTGCTAGTAAGTAAGCAGAGAACTGGGATGTAG
    TO LEFT                                                                                                 799|
        700 TAACTCGTCGCCAGATGCGGCATAGGATTATGAGCGTTTCCCCTGCGCGTTATGGTACCCGGACCGGGCCCGCGACACACGGTGCACAGGTAGAGCTAGTTAGGCGTAACGACGCCAGAATTATGTTTATTATTTACCTGTGACGCAAGCTAACAGTAGTGCCCCGGGGTGCTAGTAAGTAAGCAGAGAACTGGGATGTAG 900
      PROBE                                                                                                      <<<
      RULER |         |         |         |         |         |         |         |         |         |         |
    ALLELE1                                                                                                     T
    ALLELE2                                                                                                     G
   POSITION                                                                                                  800|
        REF                                                                                                     T
    VCF_REF                                                                                                     T
    VCF_ALT                                                                                                     G
```

