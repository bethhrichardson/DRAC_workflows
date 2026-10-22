#!/bin/bash
#SBATCH --account=def-youraccount
#SBATCH --job-name=bin
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=logs/%x_%A_%a.out

set -euo pipefail
source config.sh

module load StdEnv/2023 metabat

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES")
OUT=$OUT_DIR/$SAMPLE
mkdir -p "$OUT/bins"

metabat2 \
    -i "$OUT/assembly/final.contigs.fa" \
    -a "$OUT/depth.txt" \
    -o "$OUT/bins/bin" \
    -t "$SLURM_CPUS_PER_TASK"
