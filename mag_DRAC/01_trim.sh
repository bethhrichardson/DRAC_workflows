#!/bin/bash
#SBATCH --account=def-youraccount
#SBATCH --job-name=trim
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=06:00:00
#SBATCH --output=logs/%x_%A_%a.out

set -euo pipefail
source config.sh

module load StdEnv/2023 fastp

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES")
OUT=$OUT_DIR/$SAMPLE
mkdir -p "$OUT"

fastp \
    -i "$READS_DIR/${SAMPLE}_R1.fastq.gz" \
    -I "$READS_DIR/${SAMPLE}_R2.fastq.gz" \
    -o "$OUT/R1.trim.fastq.gz" \
    -O "$OUT/R2.trim.fastq.gz" \
    -h "$OUT/fastp.html" \
    -j "$OUT/fastp.json" \
    --thread "$SLURM_CPUS_PER_TASK"
