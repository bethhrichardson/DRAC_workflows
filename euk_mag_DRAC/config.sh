# Settings shared by all scripts in this workflow.

SAMPLES=samples.txt                  # one sample name per line
READS_DIR=/path/to/reads             # contains <sample>_R1.fastq.gz and <sample>_R2.fastq.gz
OUT_DIR=$SCRATCH/eukaryotic-mags
MAX_CONCURRENT=10                    # array tasks running at once per step

MIN_CONTIG_LEN=2000                  # contigs shorter than this are not classified
MIN_BIN_SIZE=1000000                 # smallest bin MetaBAT2 reports (bp)

EUKREP_VENV=$HOME/eukrep_venv
BUSCO_VENV=$HOME/busco_venv
BUSCO_DOWNLOADS=$HOME/busco_downloads
BUSCO_LINEAGE=eukaryota_odb10
