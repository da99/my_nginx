
# === {{CMD}}  ENV  name
# === {{CMD}}  ENV  name   val

CREATE-VAR () {
  local +x ENV_NAME="$1"; shift
  local +x NAME="$1";     shift
  local +x VAL="$@";
  local +x DIR="config/$ENV_NAME"
  local +x FILE="$DIR/$NAME"

  if [[ -z "$VAL" ]]; then
    mksh_setup RED "!!! Empty value for {{$NAME}}"
    exit 1
  fi

  if [[ -e "$FILE" ]]; then
    mksh_setup RED "=== Already {{exists}}: BOLD{{$FILE}} with content {{$(cat "$FILE")}}"
    exit 1
  fi

  if [[ ! -d "$DIR" ]]; then
    if [[ "$ENV_NAME" == "DEV" || "$ENV_NAME" == "PROD" ]]; then
      mkdir -p "$DIR"
    else
      mksh_setup RED "=== Create directory {{$DIR}} first. This helps to ensure you did not misspell the environment name: $ENV_NAME"
      exit 1
    fi
  fi

  echo "$VAL" > "$FILE"
  mksh_setup GREEN "=== Created: {{$FILE}}"
} # === end function





