#!/bin/bash
#SBATCH --account=def-youraccount
#SBATCH --job-name=checkm2
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH --time=24:00:00
#SBATCH --output=logs/%x_%A_%a.out

set -euo pipefail
source config.sh

module load StdEnv/2023 diamond prodigal/2.6.3
source "$CHECKM2_VENV/bin/activate"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES")
OUT=$OUT_DIR/$SAMPLE

checkm2 predict \
    -i "$OUT/bins" \
    -x fa \
    -o "$OUT/checkm2" \
    --database_path "$CHECKM2_DB" \
    --threads "$SLURM_CPUS_PER_TASK" \
    --force
