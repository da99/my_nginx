
row-with-exact-name-exists () {
  local DB="$1"; shift
  local NAME="$1"; shift
  local RESULT="$(sqlite "$DB" "SELECT * FROM VARS WHERE name = "$NAME"")";

  if [[ -z "$RESULT" ]]; then
    return 1
  else
    return 0
  fi
}

# === {{CMD}}  my.db "dev|prod" "name"  "val"
var-upsert () {
  local DB="$1"; shift
  local ENV_NAME="$1"; shift
  local NAME="$(echo "$1" | tr '[:lower:]' '[:upper:]' )"; shift
  local VAL="$1"; shift

  if row-with-exact-name-exists "$DB" "$NAME" ; then
    sqlite3 "$DB"  "UPDATE VARS SET $ENV_NAME = "$VAL" WHERE NAME = $NAME;"
  else
    sqlite3 "$DB"  "INSERT INTO VARS (name, $ENV_NAME) VALUES ("$NAME", "$VAL");"
  fi

  row-with-exact-name-exists "$DB" "$NAME"
} # === end function

specs () {
  local TMP="/tmp/nginx_setup"
  mkdir -p $TMP
  cd $TMP
  local DB="$TMP/config.db"
  rm -rf "$DB"

  nginx_setup create-db "$DB"
  nginx_setup var-upsert "$DB"  "dev"  "port"  "1234"
  sqlite3  "$DB"  "SELECT * FROM VARS;"
}



