#!/bin/env nextflow

params.manifest = "$baseDir/data/manifest.csv"
params.reference = "$baseDir/data/reference.fa"
params.species = 'all'
params.outdir = 'results'
params.chunkSize = 1000
params.dev = false
params.number_of_inputs = 2000

db_name = file(params.reference).name
db_dir = file(params.reference).parent

reference_name = file(params.reference).getBaseName().replaceAll(/\./, "_")
panel_name = file(params.manifest).getBaseName().replaceAll(/\./, "_")
output_name = panel_name + '.' + reference_name

final_outdir = file([params.outdir, params.species, reference_name].join(File.separator))

Channel.fromPath(params.manifest).set{ variants_ch }
    
process split_csv {
    input:
    path 'csv' from variants_ch

    output:
    file 'split_*' into split_csv_output_ch
    
    shell:
    '''
    #check if Affy manifest
    set +e
    affy=$(grep -c -m1 '^"Probe Set ID","Affy SNP ID"' csv)
    set -e

    #get SNP name and SourceSeq / Flank
    if [ "$affy" -gt 0 ]; then
        #Affymetrix
        #Keep everything except comment lines in Affymetrix manifest
        grep -v '^#' csv > affymetrix
        #Print Affy SNP ID and Flank columns without header
        awk -F, 'NR==1 { for (i=1; i<=NF; i++) { ix[$i] = i } } NR>1 { print $ix["\\"Affy SNP ID\\""]"," $ix["\\"Flank\\""] }' affymetrix > ID_seq_no_header
        rm -f affymetrix
    else
        #Illumina
        #Keep everything after [Assay] and before [Control] line in Illumina manifest
        awk -F, '/^\\[Assay\\]/{flag=1;next}/^\\[Controls\\]/{flag=0}flag' csv > illumina
        #Keep Name and SourceSeq columns without header
        awk -F, 'NR==1 { for (i=1; i<=NF; i++) { ix[$i] = i } } NR>1 { print $ix["Name"]"," $ix["SourceSeq"] }' illumina > ID_seq_no_header
        rm -f illumina
    fi
    
    #Process subset of data depending on params.dev
    #Split into multiple files
    if [ '!{params.dev}' == 'true' ]; then
        head -n !{params.number_of_inputs} ID_seq_no_header > ID_seq_no_header_sample
    else
        cat ID_seq_no_header > ID_seq_no_header_sample
    fi
    
    cat ID_seq_no_header_sample | split -l !{params.chunkSize} - split_
    for file in split_*
    do
        echo -e "Name,Sequence" > tmp_file
        cat "$file" >> tmp_file
        #Remove quotes
        sed 's/\\"//g' tmp_file > "$file"
        rm -f tmp_file
    done
    rm -f ID_seq_no_header_sample
    '''
}

process csv_to_fasta {
    input:
    path 'csv_part' from split_csv_output_ch.flatten()
    
    output:
    file 'sequence.fasta' into csv_to_fasta_output_ch_1
    file 'sequence.fasta' into csv_to_fasta_output_ch_2    
    
    shell:
    '''
    #Remove header and convert csv to fasta where only 'N' in sequence is variant site
    tail -n +2 csv_part > temp
    awk -F, -v OFS=, 'NR>=1{gsub(/[Nn]/, "",$2)} 1' temp > temp2
    awk -F, -v OFS=, 'NR>=1{gsub(/\\[.*?\\]/, "N",$2)} 1' temp2 > temp3
    awk -F, -v OFS=, 'NR>=1{gsub(/[^GATCNgatcn]/, "",$2)} 1' temp3 > temp4   
    awk -F, '{print ">"$1"\\n"$2}' temp4 > sequence.fasta
    rm -f temp temp2 temp3 temp4
    '''

}

csv_to_fasta_output_ch_1
   .collectFile(name: output_name + '.fasta', storeDir: final_outdir)


process blast {
    input:
    path 'sequence.fasta' from csv_to_fasta_output_ch_2
    path db from db_dir
    
    output:
    file 'top_hits.txt' into blast_output_ch_1
    file 'top_hits.txt' into blast_output_ch_2
    
    """
    blastn -db $db/$db_name -query sequence.fasta -outfmt '7 delim=, qseqid qseq sseqid sstart send sstrand sseq' -perc_identity 90 -qcov_hsp_perc 90 -max_target_seqs 5 -max_hsps 1 > blast_result
    grep -m1 "^# Fields:" blast_result > temp
    sed 's/# Fields: //' temp > temp2
    sed 's/, /,/g' temp2 > top_hits.txt
    grep --invert-match "^#" blast_result | awk '!seen[\$1]++' >> top_hits.txt
    rm -f temp temp2
    """
}

blast_output_ch_1
   .collectFile(name: output_name + '.blast.csv', storeDir: final_outdir, keepHeader: true, skip: 1)

process merge_blast {

    input:
    file '*.txt' from blast_output_ch_2.collect()
    
    output:
    file 'merged_hits.txt' into merge_blast_output_ch
    
    """
    head -1 1.txt > all
    tail -n +2 -q *.txt >> all
    mv all merged_hits.txt
    """
}

Channel.fromPath(params.manifest).set{ manifest_ch }

process final_report {
   
   input:
   path 'merged_hits.txt' from merge_blast_output_ch
   path x from manifest_ch
   
   output:
   file 'conversion.txt' into final_report_output_ch_1
   file 'position.txt' into final_report_output_ch_2
   file 'alignment.txt' into final_report_output_ch_3
   
   """
   build_conversion_file_and_position_file.pl -m $x -b merged_hits.txt -c conversion.txt -p position.txt -i 'SPECIES=$params.species' 'REF=$reference_name' 'PANEL=$panel_name' -v > alignment.txt
   """

}
    
final_report_output_ch_1
   .collectFile(name: output_name + '.conversion.csv', storeDir: final_outdir)

final_report_output_ch_2
   .collectFile(name: output_name + '.position.csv', storeDir: final_outdir)

final_report_output_ch_3
   .collectFile(name: output_name + '.alignment.txt', storeDir: final_outdir)
  
