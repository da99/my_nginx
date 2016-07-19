
# === {{CMD}}  NAME
# === {{CMD}}  ENV   NAME
READ-VAR () {
  case "$#" in
    1)
      local +x NAME="$1"; shift
      local +x ENV_NAME=""
      ;;
    2)
      local +x ENV_NAME="$1"; shift
      local +x NAME="$1"; shift
      ;;
    *)
      mksh_setup RED "!!! Invalid args: {{$@}}}"
      exit 1
  esac

  if [[ -n "$ENV_NAME" ]]; then
    local +x FILE="config/$ENV_NAME/$NAME"
    if [[ ! -e "$FILE" ]]; then
      mksh_setup RED "!!! File {{not found}}: BOLD{{$FILE}}}"
      exit 1
    fi
    cat "$FILE"
    exit 0
  fi

  local +x FILES="$(find "config/" -maxdepth 2 -maxdepth 2 -type f -name "$NAME" -print | sort)"
  if [[ -z "$FILES" ]]; then
    mksh_setup RED "!!! No values found for {{$NAME}}"
    exit 1
  fi

  local +x IFS=$'\n'
  for FILE in $FILES; do
    mksh_setup BOLD "{{$(basename "$(dirname "$FILE")")}}: $(cat "$FILE")"
  done

} # === end function

