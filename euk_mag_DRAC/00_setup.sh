#!/bin/bash
# One-time setup. Run on a login node (needs internet): bash 00_setup.sh
set -euo pipefail
cd "$(dirname "$0")"
source config.sh

module load StdEnv/2023 python/3.11

virtualenv --no-download "$EUKREP_VENV"
source "$EUKREP_VENV/bin/activate"
pip install --no-index --upgrade pip
pip install --no-index eukrep
cp eukrep_wrapper.py "$EUKREP_VENV/bin/"
deactivate

virtualenv --no-download "$BUSCO_VENV"
source "$BUSCO_VENV/bin/activate"
pip install --no-index --upgrade pip
pip install --no-index busco==6.0.0
busco --download_path "$BUSCO_DOWNLOADS" --download "$BUSCO_LINEAGE"
deactivate
