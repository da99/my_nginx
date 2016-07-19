
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




