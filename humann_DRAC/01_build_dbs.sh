#!/bin/bash
# run on a login node; needs access to the internet

set -euo pipefail

PROJECT_DIR=/scratch/$USER/metagenomics
DB_DIR=$PROJECT_DIR/db
RAW_DIR=$DB_DIR/raw
ENV_DIR=$PROJECT_DIR/envs/humann

MPA_INDEX=mpa_vOct22_CHOCOPhlAnSGB_202403

module load StdEnv/2023
module load python/3.11
module load bowtie2
module load diamond
source "$ENV_DIR/bin/activate"

MPA_DIR=$DB_DIR/metaphlan
mkdir -p "$MPA_DIR"

# Clean up former metaphlan build attempts
rm -f "$MPA_DIR/${MPA_INDEX}".*.bt2 "$MPA_DIR/${MPA_INDEX}".*.bt2.tmp 2>/dev/null || true

metaphlan --install -x "$MPA_INDEX" --db_dir "$MPA_DIR"

deactivate
