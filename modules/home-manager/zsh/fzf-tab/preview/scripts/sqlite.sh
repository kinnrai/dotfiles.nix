# shellcheck shell=bash

preview_sqlite() {
  local path="${1:-}"
  local output schema_version

  [[ -n "$path" && -f "$path" ]] || return 1
  # The SQLite CLI can report a malformed database on stderr while still
  # exiting successfully when it reads commands from stdin. Probe with a
  # direct statement first so non-database files reliably use path preview.
  schema_version="$(
    run_bounded 2s sqlite3 -readonly -noinit -batch -- "$path" \
      'PRAGMA schema_version;' 2>/dev/null
  )" || return 1
  [[ "$schema_version" =~ ^[0-9]+$ ]] || return 1
  output="$(
    run_bounded 2s sqlite3 \
      -readonly -noinit -batch -- "$path" 2>/dev/null <<'SQL'
.print [Database]
.headers on
.mode column
SELECT
  sqlite_version() AS sqlite_version,
  (SELECT page_size FROM pragma_page_size) AS page_size,
  (SELECT page_count FROM pragma_page_count) AS pages,
  (SELECT page_size FROM pragma_page_size) *
    (SELECT page_count FROM pragma_page_count) AS bytes;

.print
.print [Objects]
SELECT type, name, tbl_name
FROM sqlite_schema
WHERE name NOT LIKE 'sqlite_%'
ORDER BY CASE type
  WHEN 'table' THEN 1
  WHEN 'view' THEN 2
  WHEN 'index' THEN 3
  WHEN 'trigger' THEN 4
  ELSE 5
END, name;

.print
.print [Schema]
.headers off
.mode list
SELECT sql || ';'
FROM sqlite_schema
WHERE sql IS NOT NULL AND name NOT LIKE 'sqlite_%'
ORDER BY CASE type
  WHEN 'table' THEN 1
  WHEN 'view' THEN 2
  WHEN 'index' THEN 3
  WHEN 'trigger' THEN 4
  ELSE 5
END, name;
SQL
  )" || return 1

  file --brief -- "$path"
  printf '\n%s\n' "$output"
}
