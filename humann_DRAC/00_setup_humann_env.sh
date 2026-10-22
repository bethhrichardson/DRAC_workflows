#!/bin/bash
# run on a login node; needs access to the internet

set -euo pipefail

PROJECT_DIR=/scratch/$USER/metagenomics
ENV_DIR=$PROJECT_DIR/envs/humann

module load StdEnv/2023
module load python/3.11

virtualenv --no-download "$ENV_DIR"
source "$ENV_DIR/bin/activate"
pip install --no-index --upgrade pip

pip install humann metaphlan

# Patch a confirmed HUMAnN/MetaPhlAn parsing bug on DRAC:
#
# HUMAnN checks each dependency's version by running `<tool> --version`,
# merging stderr into stdout, taking the LAST non-empty output line, and
# splitting it on spaces (humann/utilities.py:check_software_version, using
# the per-tool flag/line/column config in humann/config.py). For metaphlan
# that config uses "line": -1 (last line).
#
# Confirmed on Narval (Sept 2026) that current MetaPhlAn (pip, 4.2.5) prints
# TWO lines for `--version`, not one:
#   MetaPhlAn version 4.2.5 (13 Jul 2026)
#   No complete MetaPhlAn Bowtie2 database found
# The second line appears because the version check doesn't pass --db_dir,
# so MetaPhlAn falls back to looking for a database at its own default
# location and reports not finding one, unrelated to whether
# the real --db_dir we pass at run time is complete. But it means HUMAnN's
# "last line" now grabs that message instead of the version string, fails
# to parse a version number out of it, and exits with the generic
# "CRITICAL ERROR: Can not call software version for metaphlan", which
# reads like a version-incompatibility error but isn't one. Verified by
# manually reproducing HUMAnN's exact subprocess call and walking its parser
# by hand against the real output above.
#
# This patch brings metaphlan's entry in line with how DIAMOND and bowtie are 
# already configured. 


HUMANN_CONFIG=$(python3 -c "import humann.config as c; print(c.__file__)")
python3 - "$HUMANN_CONFIG" <<'PYEOF'
import re, sys

path = sys.argv[1]
with open(path) as f:
    content = f.read()

block_re = re.compile(r"metaphlan_version\s*=\s*\{[^}]*\}", re.DOTALL)
m = block_re.search(content)
if not m:
    print(f"WARNING: metaphlan_version dict not found in {path} — HUMAnN's "
          "internal structure may have changed; skipping patch. If "
          "02_run_humann.slurm fails with \"Can not call software version "
          "for metaphlan\", this dict needs to be located and fixed by hand.",
          file=sys.stderr)
    sys.exit(0)

block = m.group(0)
if re.search(r"[\"']line[\"']\s*:\s*0\b", block):
    print("humann/config.py already patched (metaphlan line index is 0) — nothing to do.")
    sys.exit(0)

new_block, n = re.subn(r"([\"']line[\"']\s*:\s*)-1", r"\g<1>0", block)
if n == 0:
    print(f"WARNING: found metaphlan_version dict in {path} but no "
          "\"line\": -1 entry to change — inspect it by hand.", file=sys.stderr)
    sys.exit(0)

content = content[:m.start()] + new_block + content[m.end():]
with open(path, "w") as f:
    f.write(content)
print(f"Patched {path}: metaphlan_version line index -1 -> 0")
PYEOF

# Patch #2: MetaPhlAn 4.2 renamed --bowtie2out to --mapout
#
# Confirmed on Narval (Sept 2026) and confirmed upstream: MetaPhlAn 4.2.0
# (May 2025) renamed --bowtie2out to --mapout. HUMAnN's installed code  
# still hardcodes the pre-4.2 name when it builds the metaphlan command line, 
# in humann/search/prescreen.py.
#
# This fix is a published patch: see https://github.com/biobakery/humann/pull/67 
# Applying that one-line change here directly to the installed package.

HUMANN_PRESCREEN=$(python3 -c "import humann.search.prescreen as p; print(p.__file__)")
python3 - "$HUMANN_PRESCREEN" <<'PYEOF'
import re, sys

path = sys.argv[1]
with open(path) as f:
    content = f.read()

if '"--mapout"' in content or "'--mapout'" in content:
    print("humann/search/prescreen.py already patched (--mapout present) — nothing to do.")
    sys.exit(0)

new_content, n = re.subn(r"(['\"])--bowtie2out\1", r"\g<1>--mapout\g<1>", content)
if n == 0:
    print(f"WARNING: no \"--bowtie2out\" flag literal found in {path} — HUMAnN's "
          "internal structure may have changed; skipping patch. If "
          "02_run_humann.slurm fails with \"unrecognized arguments: "
          "--bowtie2out\", this needs to be located and fixed by hand "
          "(see https://github.com/biobakery/humann/pull/67).",
          file=sys.stderr)
    sys.exit(0)

with open(path, "w") as f:
    f.write(new_content)
print(f"Patched {path}: --bowtie2out -> --mapout ({n} occurrence(s))")
PYEOF

humann --version
metaphlan --version
deactivate

echo "Venv ready at: $ENV_DIR"
echo "Next: 01b_download_humann_databases.sh (get the database files),"
echo "then: 01c_build_humann_databases.sh (extract/compile/register them)."
