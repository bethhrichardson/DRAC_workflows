#!/bin/bash
#SBATCH --account=def-youraccount
#SBATCH --job-name=humann
#SBATCH --cpus-per-task=16
#SBATCH --mem=256G
#SBATCH --time=96:00:00
#SBATCH --output=logs/humann_%A_%a.out

set -euo pipefail

PROJECT_DIR=/scratch/$USER/metagenomics
ENV_DIR=$PROJECT_DIR/envs/humann
DB_DIR=$PROJECT_DIR/db

#edit to point to your files
EXISTING_TRIMMED_DIR=/scratch/$USER/your_qced_files

OUT_DIR=$PROJECT_DIR/humann_results
mkdir -p "$OUT_DIR" logs

module load StdEnv/2023
module load python/3.11
module load bowtie2
module load diamond
source "$ENV_DIR/bin/activate"

#edit to point to your sample list
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$EXISTING_TRIMMED_DIR/your_sample_list.txt")
echo "Sample: $SAMPLE"

CONCAT="$OUT_DIR/${SAMPLE}.fastq.gz"
cat "$EXISTING_TRIMMED_DIR/${SAMPLE}_R1.fastq.gz" \
    "$EXISTING_TRIMMED_DIR/${SAMPLE}_R2.fastq.gz" \
    > "$CONCAT"

MPA_INDEX_FILE="$DB_DIR/metaphlan/mpa_index.txt"
MPA_INDEX=$(cat "$MPA_INDEX_FILE")

humann \
  --input "$CONCAT" \
  --output "$OUT_DIR/${SAMPLE}" \
  --threads "$SLURM_CPUS_PER_TASK" \
  --nucleotide-database "$DB_DIR/raw/chocophlan" \
  --protein-database "$DB_DIR/raw/uniref" \
  --metaphlan-options "--offline --db_dir $DB_DIR/metaphlan -x $MPA_INDEX"

rm -f "$CONCAT"  
