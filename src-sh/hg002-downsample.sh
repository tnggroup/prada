#!/bin/bash

set -e

echo "Argument @: $@"
echo "Argument 1: $1"
echo "Slurm argument: $SLURM_ARRAY_TASK_ID"

if [ -z "$SLURM_ARRAY_TASK_ID" ]; then #check empty slurm arg
  irun=$1
else
  irun=$SLURM_ARRAY_TASK_ID
fi


INPUT_FILE="/scratch/prj/sgdp_nanopore/Projects/prada_jz/work/pgx/downsampled-bam-runs/resampling-jz/all-previous-hg002-merged.cram"
REFERENCE="/scratch/prj/sgdp_nanopore/Projects/prada_jz/data/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna"
OUTDIR="/scratch/prj/sgdp_nanopore/Projects/prada_jz/work/pgx/downsampled-bam-runs/resampling-jz"
THREADS=32
#THREADS=6
TMPDIR="${OUTDIR}/tmp_$irun"

if [ $1 = "x" ]; then

echo "X run"

#this only needs to be run once
samtools view -@ $THREADS -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sampleX.100.bam $INPUT_FILE
#samtools view -@ $THREADS -s 999.10 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sampleX.100.bam $INPUT_FILE #test
#samtools view -@ $THREADS -s 999.25 -f -b --output-fmt-option nthreads=$THREADS --write-index -o $OUTDIR/hg002-sampleX.100.bam $INPUT_FILE #test
#samtools view -@ $THREADS -s 999.25 -b --output-fmt-option nthreads=$THREADS $INPUT_FILE > $OUTDIR/hg002-sampleX.100.bam #test
#samtools index -@ $THREADS $OUTDIR/hg002-sampleX.100.bam
samtools flagstat -@ $THREADS $OUTDIR/hg002-sampleX.100.bam > $OUTDIR/hg002-sampleX.100.bam.short.stats

else

echo "Arrray run"


((ARRAY_ARG = 90 + irun))


echo "Array task ID: $irun"
echo "Array argument (seed): $ARRAY_ARG"

samtools view -@ $THREADS -s ${ARRAY_ARG}.01 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.01.bam $INPUT_FILE

samtools view -@ $THREADS -s ${ARRAY_ARG}.05 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.05.bam $INPUT_FILE

samtools view -@ $THREADS -s ${ARRAY_ARG}.10 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.10.bam $INPUT_FILE

samtools view -@ $THREADS -s ${ARRAY_ARG}.15 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.15.bam $INPUT_FILE

samtools view -@ $THREADS -s ${ARRAY_ARG}.20 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.20.bam $INPUT_FILE

samtools view -@ $THREADS -s ${ARRAY_ARG}.25 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.25.bam $INPUT_FILE

samtools view -@ $THREADS -s ${ARRAY_ARG}.30 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.30.bam $INPUT_FILE

samtools view -@ $THREADS -s ${ARRAY_ARG}.40 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.40.bam $INPUT_FILE

samtools view -@ $THREADS -s ${ARRAY_ARG}.50 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.50.bam $INPUT_FILE

samtools view -@ $THREADS -s ${ARRAY_ARG}.60 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.60.bam $INPUT_FILE

samtools view -@ $THREADS -s ${ARRAY_ARG}.75 -b --output-fmt-option level=9 --output-fmt-option nthreads=$THREADS --output-fmt-option reference=$REFERENCE --write-index -o $OUTDIR/hg002-sample${irun}.75.bam $INPUT_FILE

fi
