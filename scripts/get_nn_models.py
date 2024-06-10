#!/usr/bin/env python
# This file is part of ap_verify_dataset_template.
#
# Developed for the LSST Data Management System.
# This product includes software developed by the LSST Project
# (https://www.lsst.org).
# See the COPYRIGHT file at the top-level directory of this distribution
# for details of code ownership.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

"""Script for ingesting pretrained neural net models for this dataset.

Running this script allows for updates or replacements of the existing model.

Example:
$ python get_nn_models.py -m rbResnet50-DC2
imports rbResnet50-DC2 from /repo/main to this dataset's preloaded repo. See
get_nn_models.py -h for more options.
"""

import argparse
import logging
import os
import sys

import lsst.log
import lsst.skymap
from lsst.daf.butler import Butler, CollectionType
from lsst.meas.transiNet.modelPackages.storageAdapterButler import StorageAdapterButler

logging.basicConfig(level=logging.INFO, stream=sys.stdout)
lsst.log.configure_pylog_MDC("DEBUG", MDC_class=None)


MODEL_PREFIX = StorageAdapterButler.packages_parent_collection
MODEL_CHAIN = "models"  # Interface to generate_all.sh

# Avoid explicit references to dataset package to maximize portability.
SCRIPT_DIR = os.path.abspath(os.path.dirname(__file__))
DATASET_REPO = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "preloaded"))


########################################
# Command-line options

def _make_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("-b", dest="src_dir", default="/repo/main",
                        help="Repo to import from, defaults to '/repo/main'.")
    parser.add_argument("-m", dest="model_name", required=True,
                        help="Model package to import.")
    return parser


args = _make_parser().parse_args()


########################################
# Clean up existing model

def _clean_dataset(butler):
    """Remove the previous model(s), to avoid clashes on load.

    Parameters
    ----------
    butler : `lsst.daf.butler.Butler`
        A Butler pointing to the repository to be cleaned.
    """
    try:
        model_runs = butler.registry.getCollectionChain(MODEL_CHAIN)
    except lsst.daf.butler.registry.MissingCollectionError:
        # No prior collections
        return

    butler.registry.setCollectionChain(MODEL_CHAIN, [])
    butler.removeRuns(model_runs, unstore=True)


dest = Butler(DATASET_REPO, writeable=True)
_clean_dataset(dest)


########################################
# Transfer

MODEL_COLLECT = f"{MODEL_PREFIX}/{args.model_name}"

src = Butler(args.src_dir, writeable=False)
dest.transfer_from(src, src.registry.queryDatasets(..., collections=MODEL_COLLECT),
                   transfer="copy", register_dataset_types=True)

dest.registry.registerCollection(MODEL_CHAIN, CollectionType.CHAINED)
dest.registry.setCollectionChain(MODEL_CHAIN, [MODEL_COLLECT])

logging.info(f"Model {args.model_name} stored in {DATASET_REPO}:{MODEL_CHAIN}.")
