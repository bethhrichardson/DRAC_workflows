#!/bin/bash
#SBATCH --account=def-youraccount
#SBATCH --job-name=busco
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=logs/%x_%A_%a.out

set -euo pipefail
source config.sh

module load StdEnv/2023 python/3.11 metaeuk hmmer
source "$BUSCO_VENV/bin/activate"

SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES")
OUT=$OUT_DIR/$SAMPLE
mkdir -p "$OUT/busco"

for bin in "$OUT"/euk_bins/bin.*.fa; do
    [ -e "$bin" ] || continue
    busco \
        -i "$bin" \
        -o "$(basename "$bin" .fa)" \
        --out_path "$OUT/busco" \
        -l "$BUSCO_LINEAGE" \
        -m genome \
        -c "$SLURM_CPUS_PER_TASK" \
        --offline \
        --skip_bbtools \
        --download_path "$BUSCO_DOWNLOADS"
done
