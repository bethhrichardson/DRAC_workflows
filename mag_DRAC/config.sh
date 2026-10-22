# Settings shared by all scripts in this workflow.

SAMPLES=samples.txt                  # one sample name per line
READS_DIR=/path/to/reads             # contains <sample>_R1.fastq.gz and <sample>_R2.fastq.gz
OUT_DIR=$SCRATCH/mag-assembly

CHECKM2_VENV=$HOME/checkm2
CHECKM2_DB=$HOME/databases/CheckM2_database/uniref100.KO.1.dmnd
