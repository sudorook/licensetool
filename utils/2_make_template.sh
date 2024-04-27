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

function write_jinja_template {
  local idx

  show_header "Writing ${OUTFILE@Q}." >&2
  cat > "${OUTFILE}" << EOF
{% for copyright_line in copyright_lines %}
{{ copyright_line }}
{% endfor %}
{% if copyright_lines and spdx_expressions %}

{% endif %}
{% for expression in spdx_expressions %}
SPDX-License-Identifier: {{ expression }}
{% endfor %}
EOF

  for idx in "${!HEADERS[@]}"; do
    header="${HEADERS["${idx}"]}"
    show_listitem "${header}" >&2
    if [ "${idx}" -eq 0 ]; then
      cat >> "${OUTFILE}" << EOF
{% if "$(basename "${header%.*}")" in spdx_expressions %}

EOF
    else
      cat >> "${OUTFILE}" << EOF
{% elif "$(basename "${header%.*}")" in spdx_expressions %}

EOF
    fi
    fold -s -w75 "${header}" | sed -e "s/\ \+$//g" >> "${OUTFILE}"
  done

  cat >> "${OUTFILE}" << EOF
{% endif %}
EOF
  show_success "Done." >&2
}

OUTFILE="${BASE}"/.reuse/templates/header.jinja2
HEADERS=(headers/*.txt)

if [ "${#HEADERS[@]}" -eq 0 ]; then
  show_error "No license headers found. Exiting."
  exit 3
fi

write_jinja_template
