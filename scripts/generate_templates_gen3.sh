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

# Script for automatically generating differencing templates for this dataset.
# It takes roughly 5 hours to run on lsst-devl.
# Running this script allows for templates to incorporate pipeline
# improvements. It makes no attempt to update the set of input exposures; they
# are hard-coded into the file.
#
# Example:
# $ nohup generate_templates_gen3.sh -c "u/me/DM-123456-calib" -o "u/me/DM-123456-template" &
# produces templates in /repo/main in the u/me/DM-123456-template collection.
# See generate_templates_gen3.sh -h for more options.


# Abort script on any error
set -e


########################################
# Raw template exposures to process

# Exposure filter is a safeguard against queries that can't be constrained by
# tract/patch, or against inclusion of non-HiTS data. Patch filter specifies
# the area covered by the CI dataset in the decam_rings_v1 skymap.

FIELDS="'Blind14A_09', 'Blind14A_10'"
EXPOSURES="288934, 288935, 288975, 288976, 289015, 289016, 289055, 289056, 289160, 289161, 289201,
           289202, 289242, 289243, 289283, 289284, 289367, 289368, 289408, 289409, 289449, 289450,
           289492, 289493, 289572, 289573, 289613, 289614, 289655, 289656, 289696, 289697, 289782,
           289783, 289818, 289820, 289828, 289870, 289871, 289912, 289913"
declare -A PATCHES
PATCHES[8363]="33, 34"
PATCHES[8604]="0, 1, 2, 6, 7, 8"
PATCHES[8605]="5, 11"
DATE_CUTOFF=20141231


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
    print_error "   -c          input calib collection for template processing"
    print_error "   -o          template collection name; will also appear in final repo"
    print_error "   -h          show this message"
    exit 1
}

parse_args() {
    while getopts "b:c:o:h" option $@; do
        case "$option" in
            b)  BUTLER_REPO="$OPTARG";;
            c)  CALIBS="$OPTARG";;
            o)  TEMPLATES="$OPTARG";;
            h)  usage;;
            *)  usage;;
        esac
    done
    if [[ -z "${BUTLER_REPO}" ]]; then
        BUTLER_REPO="/repo/main"
    fi
    if [[ -z "${CALIBS}" ]]; then
        print_error "$0: mandatory argument -- c"
        usage
        exit 1
    fi
    if [[ -z "${TEMPLATES}" ]]; then
        print_error "$0: mandatory argument -- o"
        usage
        exit 1
    fi
}
parse_args "$@"


########################################
# Generate templates

FILTER="instrument='DECam' AND skymap='decam_rings_v1'
        AND exposure IN (${EXPOSURES}) AND detector NOT IN (2, 61)
        AND ("
OR=""
for tract in ${!PATCHES[*]}; do
    FILTER="${FILTER} ${OR} (tract=${tract} AND patch IN (${PATCHES[${tract}]}))"
    OR="OR"
done
FILTER="${FILTER})"


pipetask run -j 12 -d "${FILTER}" -b ${BUTLER_REPO} -i DECam/defaults,${CALIBS} -o ${TEMPLATES} \
    -p $AP_PIPE_DIR/pipelines/DECam/RunIsrForCrosstalkSources.yaml

# Run single-frame processing and coaddition separately, so that isolated
# errors in SFP do not prevent coaddition from running. Instead, coadds will
# use all successful runs, ignoring any failures.
pipetask run -j 12 -d "${FILTER}" -b ${BUTLER_REPO} -o ${TEMPLATES} \
    -p $AP_VERIFY_CI_HITS2015_DIR/pipelines/ApTemplate.yaml#singleFrameAp
pipetask run -j 12 -d "${FILTER}" -b ${BUTLER_REPO} -o ${TEMPLATES} \
    -p $AP_VERIFY_CI_HITS2015_DIR/pipelines/ApTemplate.yaml#makeTemplate


########################################
# Final summary

echo "Templates stored in ${BUTLER_REPO}:${TEMPLATES}"
