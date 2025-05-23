#!/bin/bash
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

# Script for regenerating a complete Gen 3 repository in preloaded/.
# It takes roughly 10 hours to run on lsst-devl.
#
# Example:
# $ nohup generate_all_gen3.sh -c "u/me/DM-123456" &
# fills this dataset, using collections prefixed by u/me/DM-123456 in
# /repo/main as a staging area. See generate_all_gen3.sh -h for more options.


# Abort script on any error
set -e

SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"
DATASET_REPO="${AP_VERIFY_CI_HITS2015_DIR:?'dataset is not set up'}/preloaded/"


########################################
# Command-line options

print_error() {
    >&2 echo "$@"
}

usage() {
    print_error
    print_error "Usage: $0 [-b BUTLER_REPO] -c ROOT_COLLECTION [-h]"
    print_error
    print_error "Specific options:"
    print_error "   -b          Butler repo URI, defaults to /repo/main"
    print_error "   -c          unique base collection name for processing; will also appear in final repo"
    print_error "   -h          show this message"
    exit 1
}

parse_args() {
    while getopts "b:c:h" option $@; do
        case "$option" in
            b)  SCRATCH_REPO="$OPTARG";;
            c)  COLLECT_ROOT="$OPTARG";;
            h)  usage;;
            *)  usage;;
        esac
    done
    if [[ -z "${SCRATCH_REPO}" ]]; then
        SCRATCH_REPO="/repo/main"
    fi
    if [[ -z "${COLLECT_ROOT}" ]]; then
        print_error "$0: mandatory argument -- c"
        usage
        exit 1
    fi
}
parse_args $@


CALIB_COLLECTION_SCI="${COLLECT_ROOT}-calib-science"
CALIB_COLLECTION_TMP="${COLLECT_ROOT}-calib-template"
TEMPLATE_COLLECTION="${COLLECT_ROOT}-template"
REFCAT_COLLECTION="refcats"
INJECTION_CATALOG_COLLECTION="fake-injection-catalog"

########################################
# Prepare calibs

"${SCRIPT_DIR}/generate_calibs_gen3_science.sh" -b ${SCRATCH_REPO} -c "${CALIB_COLLECTION_SCI}"


########################################
# Repository creation

"${SCRIPT_DIR}/make_preloaded.sh"


########################################
# Import calibs, templates, and refcats

"${SCRIPT_DIR}/import_calibs_gen3.sh" -b ${SCRATCH_REPO} -c "${CALIB_COLLECTION_SCI}-calib"
python "${SCRIPT_DIR}/import_templates_gen3.py" -b ${SCRATCH_REPO} -t "${TEMPLATE_COLLECTION}"
python "${SCRIPT_DIR}/generate_refcats_gen3.py" -b ${SCRATCH_REPO} -i "${REFCAT_COLLECTION}"


########################################
# Import pretrained NN models

python "${SCRIPT_DIR}/get_nn_models.py" -m "rbResnet50-DC2"


########################################
# Download solar system ephemerides

python "${SCRIPT_DIR}/generate_ephemerides_gen3.py"

########################################
# Create fake source injecteion catalogs

"${SCRIPT_DIR}/generate_fake_injection_catalog.sh" -b ${DATASET_REPO} -o ${INJECTION_CATALOG_COLLECTION}

########################################
# Generate self-consistent APDB data

python "${SCRIPT_DIR}/generate_self_preload.py"  # Must be run after all other ApPipe inputs available

########################################
# Final clean-up

butler collection-chain "${DATASET_REPO}" sso sso/cached
butler collection-chain "${DATASET_REPO}" DECam/defaults templates/goodSeeing skymaps DECam/calib \
    refcats sso dia_catalogs models ${INJECTION_CATALOG_COLLECTION}
python "${SCRIPT_DIR}/make_preloaded_export.py"

echo "Gen 3 preloaded repository complete."
echo "All preloaded data products are accessible through the DECam/defaults collection."
