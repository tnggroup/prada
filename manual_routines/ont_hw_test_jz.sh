#!/usr/bin/env bash

#SBATCH --job-name=hw_test
#SBATCH --partition=cpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=2-00:00:00
#SBATCH --output=hw_test.out.txt

export PROJECT_HOME=/scratch/prj/sgdp_nanopore/Projects/prada_jz/

export JAVA_HOME=/scratch/prj/ppn_tng/software/java/jdk-24.0.1
export JAVA_CMD='/scratch/prj/ppn_tng/software/java/jdk-24.0.1/bin/java'

export NEXTFLOW_CMD='/scratch/prj/ppn_tng/software/nextflow/nextflow-25.04.4-dist'


JOBID=$SLURM_JOB_ID

export JOBNAME=hw_test

export NXF_HOME=$PROJECT_HOME/work/results_$JOBNAME/nextflow
mkdir -p $NXF_HOME
export NXF_CACHE=$NXF_HOME/cache
export NXF_TEMP=$NXF_HOME/tmp
export NXF_SINGULARITY_CACHEDIR=$NXF_HOME/singularity/
export SINGULARITY_CACHEDIR=$NXF_HOME/singularity/
export NXF_JVM_ARGS="-XX:InitialRAMPercentage=25 -XX:MaxRAMPercentage=75"
export NXF_WORK=$NXF_HOME/work


 #--bed 'wf-human-variation-demo/demo.bed' \
 #downsample_coverage false
$NEXTFLOW_CMD run epi2me-labs/wf-human-variation \
    --bam "$PROJECT_HOME/data/ont_raw/pilot1/barcode01" \
    --ref "$PROJECT_HOME/data/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz" \
    --sample_name 'hw_test' \
    --snp \
    --sv \
    --cnv \
    --str \
    --mod \
    --phased \
    -profile singularity \
    --sex "XY" \
    --annotation false \
    --bam_min_coverage 1 \
    --threads 16 \
    --ubam_map_threads 16 \
    --ubam_sort_threads 16 \
    --ubam_bam2fq_threads 16

