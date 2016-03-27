
# === {{CMD}}  "DEV|PROD" "name" "val"
# === {{CMD}}  "DEV|PROD" "name"       # Opens editor to enter file.

var-upsert () {
  local ENV_NAME="$(bash_setup upcase "$1")"; shift
  local NAME="$(bash_setup upcase "$1")"; shift
  local FILE="config/$ENV_NAME/$NAME"
  mkdir -p "config/$ENV_NAME"

  if [[ -z "$@" ]]; then
    $EDITOR "$FILE"
  else
    local VAL="$@"; shift
    echo "$VAL"   > "$FILE"
    bash_setup GREEN "{{Wrote}}: $FILE"
  fi
} # === end function

specs () {
  local TMP="/tmp/nginx_setup/vars"

  reset-fs () {
    rm -rf "$TMP"
    mkdir -p $TMP
    cd $TMP
  }

  reset-fs
  nginx_setup var-upsert dEv my-var "my val" > /dev/null
  should-match  "my val"  "cat $TMP/config/DEV/MY-VAR"
}



