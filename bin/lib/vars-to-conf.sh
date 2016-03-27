
# === {{CMD}}  SQL.db  "nginx.conf.mustache"
vars-to-conf () {
  local DB="$1"; shift
  local TEMPLATE="$1"; shift
  local OLD=""
  local CURRENT=""

  local environment="${IS_DEV-is_null}"
  local VNAME
  local VVAL

  if [[ -n "${IS_DEV:+1}" ]]; then
    environment="DEV"
  else
    environment="PROD"
  fi

  while read "LINE"; do
    VNAME="$(echo "$LINE" | cut -d'|' -f1)"
    VVAL="$(echo "$LINE" | cut -d'|' -f2)"
    export $VNAME="$VVAL"
  done < <(sqlite3 "$DB" "select name,$environment FROM VARS")

  CURRENT="$(cat "$TEMPLATE")"
  while [[ "$OLD" != "$CURRENT" ]]; do
    OLD="$CURRENT"
    CURRENT="$(echo "$CURRENT" | bash_setup mush)"
  done

  echo "$CURRENT"
} # === end function

