
source "$THIS_DIR/bin/public/latest-version/_.sh"
source "$THIS_DIR/bin/public/version/_.sh"

# === {{CMD}}
is-latest () {
  local +x LATEST="$(latest-version)"
  local +x INSTALLED="$(version)"

  if [[ "$LATEST" == "$INSTALLED" ]]; then
    return 0
  fi

  return 1
} # === end function
