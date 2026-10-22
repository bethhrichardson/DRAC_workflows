#!/bin/bash
#SBATCH --account=def-youraccount
#SBATCH --job-name=map
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=24:00:00
#SBATCH --output=logs/%x_%A_%a.out

set -euo pipefail
source config.sh

module load StdEnv/2023 bowtie2 samtools metabat

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES")
OUT=$OUT_DIR/$SAMPLE
THREADS=$SLURM_CPUS_PER_TASK

bowtie2-build --threads "$THREADS" "$OUT/euk_contigs.fasta" "$OUT/euk_contigs"

bowtie2 \
    -x "$OUT/euk_contigs" \
    -1 "$OUT/R1.trim.fastq.gz" \
    -2 "$OUT/R2.trim.fastq.gz" \
    -p "$THREADS" \
    | samtools sort -@ "$THREADS" -o "$OUT/euk_reads.sorted.bam"

samtools index "$OUT/euk_reads.sorted.bam"

jgi_summarize_bam_contig_depths --outputDepth "$OUT/euk_depth.txt" "$OUT/euk_reads.sorted.bam"
