#!/usr/bin/env python3
"""Run EukRep with a modern scikit-learn.

EukRep's bundled model was saved with scikit-learn ~0.18, whose internal
module paths were renamed in 0.22. This maps the old names to the new ones,
then runs EukRep. Usage is identical to EukRep.
"""
import importlib
import runpy
import shutil
import sys

RENAMED = {
    "sklearn.svm.classes": "sklearn.svm._classes",
    "sklearn.tree.tree": "sklearn.tree._classes",
    "sklearn.ensemble.forest": "sklearn.ensemble._forest",
    "sklearn.linear_model.base": "sklearn.linear_model._base",
    "sklearn.preprocessing.data": "sklearn.preprocessing._data",
}

for old, new in RENAMED.items():
    try:
        sys.modules[old] = importlib.import_module(new)
    except ImportError:
        pass

eukrep = shutil.which("EukRep")
if eukrep is None:
    sys.exit("EukRep not found on PATH; activate its virtual environment first.")

sys.argv = [eukrep] + sys.argv[1:]
runpy.run_path(eukrep, run_name="__main__")
