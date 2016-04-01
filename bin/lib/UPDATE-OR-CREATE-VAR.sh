
# === {{CMD}}  "DEV|PROD" "name" "val"
# === {{CMD}}  "DEV|PROD" "name"       # Opens editor to enter file.

UPDATE-OR-CREATE-VAR () {
  local ENV_NAME="$(bash_setup upcase "$1")"; shift
  local NAME="$1"; shift
  local FILE="config/$ENV_NAME/$NAME"
  local VAL="$@"

  if [[ -f "$FILE" ]]; then
    rm "$FILE"
  fi

  nginx_setup CREATE-VAR "$ENV_NAME" "$NAME" "$VAL"
} # === end function

specs () {
  local TMP="/tmp/nginx_setup_specs/vars"

  reset-fs () {
    rm -rf "$TMP"
    mkdir -p $TMP
    cd $TMP
  }

  # ===============================================================
  reset-fs
  echo -n "=== Create var: "
  should-create-file-with-content "config/DEV/port" 4567 'nginx_setup UPDATE-OR-CREATE-VAR DEV port 4567'
  # ===============================================================

  # ===============================================================
  reset-fs
  nginx_setup CREATE-VAR DEV port 9000 >/dev/null
  echo -n "=== Updates var: "
  should-create-file-with-content "config/DEV/port" 8000 'nginx_setup UPDATE-OR-CREATE-VAR DEV port 8000'
  # ===============================================================

} # specs()



