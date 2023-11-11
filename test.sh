#!/usr/bin/env bash
nextflow main.nf \
--manifest data/manifest.csv \
--reference data/reference.fa \
--species bos_taurus \
--align \
--blast \
--outdir test_output
