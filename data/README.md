# Test data files:

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

manifest.csv - an artifical Illumina manifest file describing five SNPs. 

```
```

The flanking sequence of each SNP was derived from the reference.fa sequence such that the locations of the SNPs are as follows:

* SNP1 is located at position 300 on the forward strand
* SNP2 is located at position 700 on the forward strand
* SNP3 is located at position 900 on the forward strand
* SNP4 is located at position 200 on the reverse strand
* SNP5 is located at position 800 on the reverse strand

```
      1       2   3   Forward strand SNP positions
  a a a t c a t t g t Forward strand bases     
0_1_2_3_4_5_6_7_8_9_0 Base positions (100 bases)
  t t t a g t a a c a Reverse strand bases
    4           5     Reverse strand SNP positions
```
