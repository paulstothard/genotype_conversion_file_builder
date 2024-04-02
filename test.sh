#!/usr/bin/env bash
nextflow main.nf \
--manifest data/manifest.csv \
--reference data/reference.fa \
--species bos_taurus \
--align \
--blast \
--outdir test_output

DIR1="test_output"
DIR2="sample_output"

find "$DIR1" -type f | while read -r file; do
    # Compute the relative path
    relative_path="${file#"$DIR1"/}"

    # Check if the corresponding file exists in DIR2
    if [ -e "$DIR2/$relative_path" ]; then
        printf "Comparing %s with %s\n" "$file" "$DIR2/$relative_path"
        diff "$file" "$DIR2/$relative_path"
    else
        printf "%s does not exist in %s\n" "$relative_path" "$DIR2"
    fi
done