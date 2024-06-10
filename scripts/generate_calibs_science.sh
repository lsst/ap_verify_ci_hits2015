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

# Script for automatically generating calibs for this dataset. It takes roughly
# 1 hour to run on lsst-devl.
# Running this script allows for calibs to incorporate pipeline improvements.
# It makes no attempt to update the set of input exposures or their validity
# ranges; they are hard-coded into the file.
#
# Example:
# $ nohup generate_calibs_science.sh -c "u/me/DM-123456" &
# produces certified calibs in /repo/main in the u/me/DM-123456-calib
# collection. See generate_calibs_science.sh -h for more options.


# Common definitions
SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"
source "${SCRIPT_DIR}/generate_calibs.sh"


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

EXPOSURES_CROSSTALK=$(join_by , "${EXPOSURES_FLAT_g_c0001[@]}")


########################################
# Command-line options

parse_args "$@"


########################################
# Generate calibs

do_crosstalk $BUTLER_REPO $COLLECT_ROOT "$EXPOSURES_CROSSTALK"

# Associative array hack from https://stackoverflow.com/questions/4069188/
do_bias $BUTLER_REPO $COLLECT_ROOT "$(declare -p EXPOSURES_BIAS)" "$(declare -p VALIDITIES_BIAS)"
do_flat $BUTLER_REPO $COLLECT_ROOT \
    "$(declare -p EXPOSURES_FLAT_g_c0001)" "$(declare -p VALIDITIES_FLAT_g_c0001)"


########################################
# Final summary

echo "Biases and flats stored in ${BUTLER_REPO}:${COLLECT_ROOT}-calib"
