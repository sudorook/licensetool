<!--
  -- SPDX-FileCopyrightText: 2024 sudorook <daemon@nullcodon.com>
  --
  -- SPDX-License-Identifier: GPL-3.0-or-later
  --
  -- This program is free software: you can redistribute it and/or modify it
  -- under the terms of the GNU General Public License as published by the Free
  -- Software Foundation, either version 3 of the License, or (at your option)
  -- any later version.
  --
  -- This program is distributed in the hope that it will be useful, but
  -- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  -- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
  -- for more details.
  --
  -- You should have received a copy of the GNU General Public License along
  -- with this program. If not, see <https://www.gnu.org/licenses/>.
  -->

# License Tool

Tool for adding license information to a repository. Useful for inserting
SPDX-compliant license headers to files, including any relevant license-specific
header text, via [reuse-tool](https://github.com/fsfe/reuse-tool).

The attracting of using this script instead of using `reuse annotate` directly
is the ability to fill fields directly from Git metadata.

Also included are custom license templates (see
`.reuse/templates/header.jinja2`) that not only set the SPDX standard fields but
also the copyright blurbs for each license that includes them.

For example, setting a GPLv3 header will embed:

```txt
SPDX-FileCopyrightText: <year> <nane> <email>

SPDX-License-Identifier: GPL-3.0-or-later

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with this program. If not, see <https://www.gnu.org/licenses/>.
```

## Embed SPDX metadata

To embed SPDX license metadata, run:

```sh
licensetool annotate <flags> <file>
```

The available flags are:

```txt
-a|--author   <string>  author (optional)
-e|--email    <string>  email address (optional)
-g|--git      <bool>    fill optional fields using Git metadata
-l|--license  <string>  license header to embed (required)
-y|--year     <int>     year for copyright notice (optional)
-s|--style    <string>  'reuse' copyright style (default: spdx)
-m|--multiline  <bool>  force multiline comments for header (default: false)"
```

Multiple authors, email addresses, years, and licenses can be supplied by
passing comma-delimited strings.

The `license` field may be supplied via the command line, and if not specified,
the script will prompt the user for a selection.

All of the optional fields can be automatically filled using Git commit data if
the `-g` flag is passed to the script. The `year` field will default to the
current year if not deduced through Git metadata.

Lastly, the `-s` flag refers to the copyright style. The options are:

- `spdx`
- `spdx-c`
- `spdx-symbol`
- `string`
- `string-c`
- `string-symbol`

See `reuse annotate --help` for more information.

## Download licenses

To download the license(s) specified in the headers, run:

```sh
licensetool download
```

This is a simple wrapper around `reuse download --all`.
