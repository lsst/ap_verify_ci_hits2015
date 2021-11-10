#!/bin/bash
# This file is part of ap_verify_hits2015.
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

# Script for automatically generating calibs for this dataset. It takes roughly
# 1 hour to run on lsst-devl.
# Running this script allows for calibs to incorporate pipeline improvements.
# It makes no attempt to update the set of input exposures or their validity
# ranges; they are hard-coded into the file.
#
# Example:
# $ nohup generate_calibs_gen3.sh -c "u/me/DM-123456" &
# produces certified calibs in /repo/main in the u/me/DM-123456-calib
# collection. See generate_calibs_gen3.sh -h for more options.
#
# The calibs produced by this script are a subset of those produced by
# ap_verify_hits2015/scripts/generate_calibs_gen3.sh, so if you are running
# that script, there is no need to run this one as well.

# Abort script on any error
set -e

########################################
# Raw calibs to process

# Syntax matters -- use
#     https://pipelines.lsst.io/v/daily/modules/lsst.daf.butler/queries.html#dimension-expressions
#     syntax, with no trailing comma.

declare -A EXPOSURES_BIAS
EXPOSURES_BIAS[20150218]='411502, 411503, 411504, 411505, 411506, 411507, 411508, 411509, 411510,
                          411511, 411512'
EXPOSURES_BIAS[20150313]='421350, 421351, 421352, 421353, 421354, 421355, 421356, 421357, 421358,
                          421359, 421360'

declare -A VALIDITIES_BIAS
VALIDITIES_BIAS[20150218]='--begin-date 2015-02-18T00:00:00 --end-date 2015-02-18T23:59:59'
VALIDITIES_BIAS[20150313]='--begin-date 2015-03-06T00:00:00 --end-date 2015-03-15T23:59:59'

declare -A EXPOSURES_FLAT_g_c0001
EXPOSURES_FLAT_g_c0001[20150218]='411578, 411579, 411580, 411581, 411582, 411583, 411584, 411585,
                                  411586, 411587, 411588'
EXPOSURES_FLAT_g_c0001[20150313]='421426, 421427, 421428, 421429, 421430, 421431, 421432, 421433,
                                  421434, 421435, 421436'

declare -A VALIDITIES_FLAT_g_c0001
VALIDITIES_FLAT_g_c0001[20150218]='--begin-date 2015-02-18T00:00:00 --end-date 2015-02-18T23:59:59'
VALIDITIES_FLAT_g_c0001[20150313]='--begin-date 2015-03-06T00:00:00 --end-date 2015-03-15T23:59:59'

# from https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
join_by() { local IFS="$1"; shift; echo "$*"; }
EXPOSURES_CROSSTALK=`join_by , "${EXPOSURES_FLAT_g_c0001[@]}"`


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
    print_error "   -c          unique base collection name"
    print_error "   -h          show this message"
    exit 1
}

while getopts "b:c:h" option; do
    case "$option" in
        b)  BUTLER_REPO="$OPTARG";;
        c)  COLLECT_ROOT="$OPTARG";;
        h)  usage;;
        *)  usage;;
    esac
done
if [[ -z "${BUTLER_REPO}" ]]; then
    BUTLER_REPO="/repo/main"
fi
if [[ -z "${COLLECT_ROOT}" ]]; then
    print_error "$0: mandatory argument -- c"
    usage
    exit 1
fi


########################################
# Prepare crosstalk sources (overscan subtraction)

# TODO: overscan.fitType override may be included in cp_pipe on DM-30651

pipetask run -j 12 -d "exposure IN ($EXPOSURES_CROSSTALK) AND instrument='DECam'" \
    -b ${BUTLER_REPO} -i DECam/defaults -o ${COLLECT_ROOT}-crosstalk-sources \
    -p $CP_PIPE_DIR/pipelines/DarkEnergyCamera/RunIsrForCrosstalkSources.yaml \
    -c overscan:overscan.fitType='MEDIAN_PER_ROW'

########################################
# Build and certify bias frames

# TODO: overscan.fitType override may be included in cp_pipe on DM-30651

for date in ${!EXPOSURES_BIAS[*]}; do
    pipetask run -j 12 -d "exposure IN (${EXPOSURES_BIAS[${date}]}) AND instrument='DECam'" \
        -b ${BUTLER_REPO} -i DECam/defaults -o ${COLLECT_ROOT}-bias-construction-${date} \
        -p $CP_PIPE_DIR/pipelines/cpBias.yaml -c isr:overscan.fitType='MEDIAN_PER_ROW'
    butler certify-calibrations ${BUTLER_REPO} ${COLLECT_ROOT}-bias-construction-${date} \
        ${COLLECT_ROOT}-calib bias ${VALIDITIES_BIAS[${date}]}
done

########################################
# Build and certify flat frames

# TODO: cpFlatNorm:level override may be included in cp_pipe on DM-30651

for date in ${!EXPOSURES_FLAT_g_c0001[*]}; do
    pipetask run -j 12 -d "exposure IN (${EXPOSURES_FLAT_g_c0001[${date}]}) AND instrument='DECam'" \
        -b ${BUTLER_REPO} -i DECam/defaults,${COLLECT_ROOT}-calib,${COLLECT_ROOT}-crosstalk-sources \
        -o ${COLLECT_ROOT}-flat-construction-${date} \
        -p $CP_PIPE_DIR/pipelines/DarkEnergyCamera/cpFlat.yaml -c cpFlatNorm:level='AMP'
    butler certify-calibrations ${BUTLER_REPO} ${COLLECT_ROOT}-flat-construction-${date} \
        ${COLLECT_ROOT}-calib flat ${VALIDITIES_FLAT_g_c0001[${date}]}
done


########################################
# Final summary

echo "Biases and flats stored in ${BUTLER_REPO}:${COLLECT_ROOT}-calib"
