#!/bin/env nextflow

nextflowVersion '20.01.0'

/* genotype_conversion_file_builder. A pipeline for determining the 
   genomic location and transformation rules for the variants described in
   Illumina or Affymetrix genotype panel manifest files.
   Copyright (C) 2020 Paul Stothard stothard@ualberta.ca

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>. */

params.manifest = "$baseDir/data/manifest.csv"
params.reference = "$baseDir/data/reference.fa"
params.species = 'all'
params.outdir = "$baseDir/results"

params.chunksize = 10000
params.dev = false
params.align = false
params.blast = false
params.number_of_inputs = 100

/*
 * Check for existence of files
 */
if( !file(params.manifest).exists() ) {
  exit 1, "The specified manifest file does not exist: ${params.manifest}"
}

if( !file(params.reference).exists() ) {
  exit 1, "The specified reference file does not exist: ${params.reference}"
}

/*
 * Check for existence of BLAST database for reference sequence
 * Create the BLAST database if it doesn't exist
 */
blastDb = [file(params.reference).parent, file(params.reference).name].join(File.separator) + '.nin'
if ( !file(blastDb).exists() ) {

  println "Building BLAST database for ${params.reference}"
  
  def command = "makeblastdb -in $params.reference -dbtype nucl"
  def proc = command.execute()
  proc.waitFor()              

  println "Process exit code: ${proc.exitValue()}"
  println "Std Err: ${proc.err.text}"
  println "Std Out: ${proc.in.text}" 
} 

dbName = file(params.reference).name
dbDir = file(params.reference).parent

referenceName = file(params.reference).getBaseName().replaceAll(/\./, "_")
panelName = file(params.manifest).getBaseName().replaceAll(/\./, "_")
outputName = panelName + '.' + referenceName

finalOutDir = file([params.outdir, params.species, referenceName].join(File.separator))

Channel.fromPath(params.manifest).set{ manifest_output_ch }
    
process split_csv {
    input:
    path 'csv' from manifest_output_ch

    output:
    file 'split_*' into split_csv_output_ch
    
    shell:
    '''
    #remove commas within quoted fields
    perl -nle  'my @new  = (); push( @new, $+ ) while $_ =~ m{"([^\\"\\\\]*(?:\\\\.[^\\"\\\\]*)*)",? | ([^,]+),? | ,}gx; push( @new, undef ) if substr( $text, -1, 1 ) eq '\\'','\\''; for(@new){s/,/ /g} print join "\\t", @new' csv > temp1
    #replace tabs with commas and remove quotes
    perl -p -e 's/\\t/,/g;' -e 's/"//g' temp1 > temp2
    
    #check if Affy manifest
    set +e
    affy=$(grep -c -m1 '^Probe Set ID,Affy SNP ID' temp2)
    set -e

    #get SNP name and SourceSeq / Flank
    if [ "$affy" -gt 0 ]; then
        #Affymetrix
        #Keep everything except comment lines in Affymetrix manifest
        grep -v '^#' temp2 > affymetrix
        #Print Affy SNP ID and Flank columns without header
        awk -F, 'NR==1 { for (i=1; i<=NF; i++) { ix[$i] = i } } NR>1 \\
        { print $ix["Affy SNP ID"]"," $ix["Flank"] }' \\
        affymetrix > ID_seq_no_header
        rm -f affymetrix
        rm -f temp1 temp2
    else
        #Illumina
        #Keep everthing except lines before IlmnID line and after [Control] line in 
        #Illumina manifest
        awk -F, '/^IlmnID/{flag=1;print;next}/^\\[Controls\\]/{flag=0}flag' temp2 > illumina
        #Keep Name and SourceSeq columns without header
        awk -F, 'NR==1 { for (i=1; i<=NF; i++) { ix[$i] = i } } NR>1 \\
        { print $ix["Name"]"," $ix["SourceSeq"] }' illumina > ID_seq_no_header
        rm -f illumina
        rm -f temp1 temp2
    fi
    
    #Process subset of data depending on params.dev
    #Split into multiple files
    if [ '!{params.dev}' == 'true' ]; then
        head -n !{params.number_of_inputs} ID_seq_no_header > ID_seq_no_header_sample
    else
        cat ID_seq_no_header > ID_seq_no_header_sample
    fi
    
    rm -f ID_seq_no_header 
    cat ID_seq_no_header_sample | split -l !{params.chunksize} - split_
    for file in split_*
    do
        echo -e "Name,Sequence" > temp1
        cat "$file" >> temp1
        mv temp1 "$file"
    done
    rm -f ID_seq_no_header_sample
    '''
}

process csv_to_fasta {
    input:
    path 'csv_part' from split_csv_output_ch.flatten()
    
    output:
    file 'sequence.fasta' into csv_to_fasta_output_ch
    
    shell:
    '''
    #Remove header and convert csv to fasta where only 'N' in sequence is variant site
    tail -n +2 csv_part > temp1
    awk -F, -v OFS=, 'NR>=1{gsub(/[Nn]/, "",$2)} 1' temp1 > temp2
    awk -F, -v OFS=, 'NR>=1{gsub(/\\[.*?\\]/, "N",$2)} 1' temp2 > temp3
    awk -F, -v OFS=, 'NR>=1{gsub(/[^GATCNgatcn]/, "",$2)} 1' temp3 > temp4   
    awk -F, '{print ">"$1"\\n"$2}' temp4 > sequence.fasta
    rm -f temp1 temp2 temp3 temp4
    '''

}

process blast {
    input:
    path 'sequence.fasta' from csv_to_fasta_output_ch
    path db from dbDir
    
    output:
    file 'top_hits.txt' into blast_output_ch
    
    """
    blastn -db $db/$dbName -query sequence.fasta \\
    -outfmt '7 qseqid qseq sseqid salltitles sstart send sstrand sseq' \\
    -perc_identity 90 -qcov_hsp_perc 90 -max_target_seqs 5 -max_hsps 1 > blast_result
    set +e
    header=\$(grep -m1 "^# Fields:" blast_result > temp1)
    set -e
    if [ "header" -gt 0 ]; then
      sed 's/# Fields: //' temp1 > temp2
    else
      echo "query id,query seq,subject id,subject titles,s. start,s. end,subject strand,subject seq" > temp2
    fi
    sed 's/, /,/g' temp2 > top_hits.txt
    sed 's/,//g' blast_result > blast_result_no_commas
    perl -p -e 's/\\t/,/g' blast_result_no_commas > blast_result
    set +e
    grep --invert-match "^#" blast_result | awk -F, '!seen[\$1]++' >> top_hits.txt
    set -e
    rm -f temp1 temp2 blast_result_no_commas blast_result
    """
}

process merge_blast {

    input:
    file '*.txt' from blast_output_ch.collect()
    
    output:
    file 'merged_hits.txt' into merge_blast_output_ch_1
    file 'blast.txt' optional true into merge_blast_output_ch_2
    
    """
    #If there is one top_hits.txt file it is staged as .txt
    if [ -f .txt ]; then
        cp .txt merged_hits.txt
    else
        head -1 1.txt > all
        tail -n +2 -q *.txt >> all
        mv all merged_hits.txt
    fi
    if [ '$params.blast' == 'true' ]; then
        cp merged_hits.txt blast.txt
    fi
    """
}

merge_blast_output_ch_2
   .collectFile(name: outputName + '.blast.csv', storeDir: finalOutDir)

Channel.fromPath(params.manifest).set{ manifest_ch }

process final_report {
   
   input:
   path 'merged_hits.txt' from merge_blast_output_ch_1
   path x from manifest_ch
   
   output:
   file 'conversion.txt' into final_report_output_ch_1
   file 'position.txt' into final_report_output_ch_2
   file 'wide.txt' into final_report_output_ch_3
   file 'alignment.txt' optional true into final_report_output_ch_4
   
   """
   build_conversion_file_and_position_file.pl -m $x -b merged_hits.txt \\
   -c conversion.txt -p position.txt -w wide.txt \\
   -i 'SPECIES=$params.species' 'REF=$referenceName' 'PANEL=$panelName' \\
   -a alignment.txt
   
   if [ '$params.align' == 'false' ]; then
       rm alignment.txt
   fi
   """

}
    
final_report_output_ch_1
   .collectFile(name: outputName + '.conversion.csv', storeDir: finalOutDir)

final_report_output_ch_2
   .collectFile(name: outputName + '.position.csv', storeDir: finalOutDir)
   
final_report_output_ch_3
   .collectFile(name: outputName + '.wide.csv', storeDir: finalOutDir)

final_report_output_ch_4
   .collectFile(name: outputName + '.alignment.txt', storeDir: finalOutDir)