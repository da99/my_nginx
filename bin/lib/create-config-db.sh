
# === {{CMD}}  "my.db"
create-config-db () {
  local DB="$1"; shift
  local SCHEMA="CREATE TABLE VARS(name varchar(25), dev varchar(255), prod varchar(255));
CREATE UNIQUE INDEX name_unique_idx ON VARS (name);"

  if [[ ! -s "$DB" ]]; then
    sqlite3 "$DB" "$SCHEMA" && bash_setup BOLD "=== Created: {{$DB}}"
  else
    local CURRENT="$(sqlite3 "$DB" ".schema")"
    if [[ "$CURRENT" != "$SCHEMA" ]]; then
      bash_setup RED "=== {{SCHEMA mismatch}}: $CURRENT"
      exit 1
    else
      bash_setup GREEN "=== Database already exists with {{valid schema}}."
    fi
  fi
} # === end function


specs () {
  local TMP="/tmp/nginx_setup"
  local DB="$TMP/config.db"
  mkdir -p "$TMP"
  cd "$TMP"

  rm -rf "$DB"
  nginx_setup create-config-db "$DB"
  should-match-regexp  "CREATE TABLE VARS"  "sqlite3 "$DB" .schema"

  rm -rf "$DB"
  sqlite3 "$DB" "CREATE  TABLE VARS(name varchar(25), prod varchar(255));"
  should-exit 1  "nginx_setup create-config-db $DB" 2>/dev/null
}
