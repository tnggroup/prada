#!/bin/bash

REFERENCE="/scratch/prj/sgdp_nanopore/Projects/prada_jz/data/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna"
OUTDIR="/scratch/prj/sgdp_nanopore/Projects/prada_jz/work/pgx/downsampled-bam-runs/resampling-jz"
THREADS=32
TMPDIR="${OUTDIR}/tmp_${SLURM_JOB_ID}"

hg002origpath=/scratch/prj/sgdp_nanopore/recovered/HALee/giab_stuff/nihr_giab_results/hv

samtools merge -@ $THREADS -f -l 9 --output-fmt cram --output-fmt-option level=9 --output-fmt-option nthreads=32 --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/all-previous-hg002-merged.cram $hg002origpath/test_HG002_new_hg19/output/test_HG002_new.haplotagged.cram $hg002origpath/test_HG002_ont_new_hg19/output/test_HG002_ont_new.haplotagged.cram $hg002origpath/test_HG002_br_new_hg19/output/test_HG002_br_new.haplotagged.cram


#Gaurav also recommended https://www.illumina.com/products/by-type/informatics-products/basespace-sequence-hub/apps/bwa-aligner.html
