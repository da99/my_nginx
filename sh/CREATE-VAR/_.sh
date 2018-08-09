
# === {{CMD}}  ENV  name
# === {{CMD}}  ENV  name   val

CREATE-VAR () {
  local +x ENV_NAME="$1"; shift
  local +x NAME="$1";     shift
  local +x VAL="$@";
  local +x DIR="config/$ENV_NAME"
  local +x FILE="$DIR/$NAME"

  if [[ -z "$VAL" ]]; then
    sh_color RED "!!! Empty value for {{$NAME}}"
    exit 1
  fi

  if [[ -e "$FILE" ]]; then
    sh_color RED "=== Already {{exists}}: BOLD{{$FILE}} with content {{$(cat "$FILE")}}"
    exit 1
  fi

  if [[ ! -d "$DIR" ]]; then
    if [[ "$ENV_NAME" == "DEV" || "$ENV_NAME" == "PROD" ]]; then
      mkdir -p "$DIR"
    else
      sh_color RED "=== Create directory {{$DIR}} first. This helps to ensure you did not misspell the environment name: $ENV_NAME"
      exit 1
    fi
  fi

  echo "$VAL" > "$FILE"
  sh_color GREEN "=== Created: {{$FILE}}"
} # === end function





