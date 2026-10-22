#!/bin/bash
#SBATCH --account=def-youraccount
#SBATCH --job-name=assemble
#SBATCH --cpus-per-task=32
#SBATCH --mem=512G
#SBATCH --time=168:00:00
#SBATCH --output=logs/%x_%A_%a.out

set -euo pipefail
source config.sh

module load StdEnv/2023 spades

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES")
OUT=$OUT_DIR/$SAMPLE

spades.py \
    --meta \
    -1 "$OUT/R1.trim.fastq.gz" \
    -2 "$OUT/R2.trim.fastq.gz" \
    -o "$OUT/assembly" \
    -t "$SLURM_CPUS_PER_TASK" \
    -m 500
