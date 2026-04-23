#!/bin/bash

INPUT_ORIGINAL="/scratch/prj/sgdp_nanopore/Projects/prada_jz/work/pgx/downsampled-bam-runs/test-2/hg38_aligned/HG002_new_hg19_merged_hg38.bam"
INPUT_NEW="/scratch/prj/sgdp_nanopore/Projects/prada_jz/work/pgx/downsampled-bam-runs/resampling-jz/all-previous-hg002-merged.cram"
OUTDIR="/scratch/prj/sgdp_nanopore/Projects/prada_jz/work/pgx/downsampled-bam-runs/resampling-jz"
THREADS=32
TMPDIR="${OUTDIR}/tmp_${SLURM_JOB_ID}"
#
# samtools quickcheck $INPUT_ORIGINAL
# samtools flagstat -@ $THREADS $INPUT_ORIGINAL > $OUTDIR/hg002-upsampled.original.short.stats
# samtools stats -@ $THREADS $INPUT_ORIGINAL > $OUTDIR/hg002-upsampled.original.stats

samtools quickcheck $INPUT_NEW
samtools flagstat -@ $THREADS $INPUT_NEW > $OUTDIR/hg002-upsampled.new.short.stats
samtools stats -@ $THREADS $INPUT_NEW > $OUTDIR/hg002-upsampled.new.stats
