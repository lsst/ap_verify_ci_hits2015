#!/usr/bin/env python
# This file is part of ap_verify_ci_hits2015.
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

"""Make the butler export yaml file to be used by ap_verify runs.

This script must be run after **any** change to the preloaded repository;
otherwise, ingestion may fail or the changes may not be visible.
"""

import logging
import os
import sys

import lsst.log
import lsst.skymap
import lsst.daf.butler as daf_butler


# Avoid explicit references to dataset package to maximize portability.
SCRIPT_DIR = os.path.abspath(os.path.dirname(__file__))
REPO_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "preloaded"))
CONFIG_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, "..", "config"))


def main():
    # Ensure logs from tasks are visible
    logging.basicConfig(level=logging.INFO, stream=sys.stdout)
    lsst.log.configure_pylog_MDC("DEBUG", MDC_class=None)

    logging.info("Exporting registry to configure new repos...")
    _export_for_copy(REPO_DIR, CONFIG_DIR)


def _export_for_copy(repo, export_dir):
    """Export a butler repository so that a dataset can make copies later.

    Parameters
    ----------
    repo : `str`
        The location of the repository.
    export_dir : `str`
        The location at which to create the export file.
    """
    butler = daf_butler.Butler(repo)
    with butler.export(directory=export_dir, format="yaml") as contents:
        # Need all detectors, even those without data, for visit definition
        contents.saveDataIds(butler.registry.queryDataIds({"detector"}).expanded())
        contents.saveDatasets(butler.registry.queryDatasets(datasetType=..., collections=...))
        # Explicitly save the calibration and chained collections.
        # Do _not_ include the RUN collections here because that will export
        # an empty raws collection, which ap_verify assumes does not exist
        # before ingest.
        target_types = {daf_butler.CollectionType.CALIBRATION, daf_butler.CollectionType.CHAINED}
        for collection in butler.registry.queryCollections(..., collectionTypes=target_types):
            contents.saveCollection(collection)
        # Export skymap collection even if it is empty
        contents.saveCollection(lsst.skymap.BaseSkyMap.SKYMAP_RUN_COLLECTION_NAME)
        # Dataset export exports visits, but need matching visit definitions as
        # well (DefineVisitsTask won't add them back in).
        contents.saveDimensionData("day_obs",
                                   butler.registry.queryDimensionRecords("day_obs"))
        contents.saveDimensionData("exposure",
                                   butler.registry.queryDimensionRecords("exposure"))
        contents.saveDimensionData("group",
                                   butler.registry.queryDimensionRecords("group"))
        contents.saveDimensionData("visit_definition",
                                   butler.registry.queryDimensionRecords("visit_definition"))
        contents.saveDimensionData("visit_detector_region",
                                   butler.registry.queryDimensionRecords("visit_detector_region"))


if __name__ == "__main__":
    main()
