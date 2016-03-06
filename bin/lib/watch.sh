
# === {{CMD}}
watch () {
    cmd () {
      if [[ -z "$@" ]]; then
        path="some.file"
      else
        path="$1"
        shift
      fi
    }
    cmd

    echo -e "\n=== Watching: $files"
    while read -r CHANGE; do
      dir=$(echo "$CHANGE" | cut -d' ' -f 1)
      path="${dir}$(echo "$CHANGE" | cut -d' ' -f 3)"
      file="$(basename $path)"

      # Make sure this is not a temp/swap file:
      { [[ ! -f "$path" ]] && continue; } || :

      # Check if file has changed:
      if bash_setup is_same_file "$path"; then
        echo "=== No change: $CHANGE"
        continue
      fi

      # File has changed:
      echo -e "\n=== $CHANGE ($path)"

      if [[ "$path" =~ "$0" ]]; then
        echo "=== Reloading..."
        break
      fi

      if [[ "$file" =~ ".some_ext" ]]; then
        cmd $path
      fi
    done < <(inotifywait --quiet --monitor --event close_write some_file "$0") || exit 1
    $0 watch $THE_ARGS
} # === end function
