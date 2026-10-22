#!/bin/bash
#SBATCH --account=def-youraccount
#SBATCH --job-name=classify
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=logs/%x_%A_%a.out

set -euo pipefail
source config.sh

module load StdEnv/2023 python/3.11
source "$EUKREP_VENV/bin/activate"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES")
OUT=$OUT_DIR/$SAMPLE

python "$EUKREP_VENV/bin/eukrep_wrapper.py" \
    -i "$OUT/assembly/contigs.fasta" \
    -o "$OUT/euk_contigs.fasta" \
    --min "$MIN_CONTIG_LEN"
