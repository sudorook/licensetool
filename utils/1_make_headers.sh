#!/bin/bash

# SPDX-FileCopyrightText: 2024 sudorook <daemon@nullcodon.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.

set -euo pipefail

DIR="$(dirname "${0}")"
BASE="$(dirname "$(readlink -f "${DIR}")")"

source "${BASE}"/globals

! check_command find git html2text sed && exit 3

function parse_xml {
  sed -n '/<standardLicenseHeader>/,/<\/standardLicenseHeader>/p' "${1}" |
    html2text |
    sed 's/^\(\[.*\]\)\?\((.*)\)\?\(<.*>\)\?\s*Copyright\s*\((.*)\)\?\(\[.*\]\)\?\(<.*>\)\?\s*//g' |
    sed '/^%% pig\./d' |
    sed 's/^%\+ //g' |
    sed 's/YEAR YOUR NAME\s*\.\?\s*//g' |
    sed 's/<\?\[\?\(year\|19yy\|19xx\|yyyy\)>\?\]\?\s\+<\?\[\?\(name of author\|copyright holders\)>\?\]\?\s*//g' |
    sed "s/\[\$date-of-software\]//g" |
    sed "s/\[\(2019\|Year\)\] \[name of copyright holder\]//g" |
    sed "s/Copyright [0-9]\+ M. Y. Name//g" |
    sed "/^<\?one line to give the \(program's\|library's\) name and \(a brief\|an\) idea of what it does\.>\?/d" |
    sed -e 's/^"\(.*\)"$/\1/g' |
    sed 's/^ \+//g' |
    sed 's/ \+$//g' |
    fmt -w1000 |
    sed -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' |
    sed -e "s/ \+/ /g" |
    sed -e '1s/^"//' |
    sed -e '$s/"$//'
}

function parse_xml_minimal {
  sed -n '/<standardLicenseHeader>/,/<\/standardLicenseHeader>/p' "${1}" |
    html2text |
    sed '/^%% pig\./d' |
    sed 's/^%\+ //g' |
    fmt -w2000 |
    sed -e 's/^"\(.*\)"$/\1/g' |
    sed -e "s/  \+/ /g" |
    sed -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}'
}

git submodule update --init

OUTDIR=headers
mkdir -p "${OUTDIR}"

while read -r FILE; do
  HEADER="$(parse_xml "${FILE}")"
  if [ -n "${HEADER}" ]; then
    show_listitem "${FILE@Q}" >&2
    echo "${HEADER}" > "${OUTDIR}/$(basename "${FILE%.*}").txt"
  fi
done < <(find "${DIR}"/license-list-XML/src/ -type f -name "*.xml")
