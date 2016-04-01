
vars () {
  # === This function gets all the different VARs in each environment.
  #     This way, we can find out if an ENV is missing a var from another environment.
  #     In other words: Did you forget to write a PORT for PROD?
  find config/* -mindepth 1 -maxdepth 1 -type f -print | xargs -I FILE basename FILE | sort | uniq
}

envs () {
  find config/ -mindepth 1 -maxdepth 1 -type d -print | \
    xargs -I PATH basename PATH                       | \
    grep -P '^[^a-z]+$'
}

# === {{CMD}}  "ENV_NAME"  "nginx.conf.mustache"
mkconf () {
  local +x ENV_NAME="$1"; shift
  local +x TEMPLATE="$(realpath -m "$1")"; shift

  local +x ENVS="$(envs)"
  local +x ENV_COUNT="$(echo "$ENVS" | wc -l)"

  # === There must be at least one ENV found:
  if [[ $ENV_COUNT -lt 1 ]]; then
    bash_setup RED "=== {{No ENVS}} found in config/"
    exit 1
  fi

  # === Make sure this ENV is not missing a VAR from the other ENVs:
  for VAR_NAME in $(vars); do
    local +x FILE="config/${ENV_NAME}/${VAR_NAME}"
    if [[ ! -f "$FILE" ]]; then
      bash_setup RED "=== File does not exist for ${ENV_NAME}: $FILE"
      exit 1
    fi
  done

  /apps/bash_setup/bin/bash_setup template-render "config/$ENV_NAME" "$TEMPLATE"
} # === end function

specs () {
  local +x TMP="/tmp/nginx_setup_test/vars"

  reset-fs () {
    rm -rf "$TMP"
    mkdir -p $TMP
    cd $TMP
  }

  # === Can print in different envs:
  reset-fs
  nginx_setup UPDATE-OR-CREATE-VAR DEV NAME "ted"              >/dev/null
  nginx_setup UPDATE-OR-CREATE-VAR DEV CORP "General Creative" >/dev/null
  nginx_setup UPDATE-OR-CREATE-VAR PROD NAME "disney"          >/dev/null
  nginx_setup UPDATE-OR-CREATE-VAR PROD CORP "Disney MegaCorp" >/dev/null
  echo "This is my name and corp: {{NAME}} {{CORP}}" > "nginx.conf"
  should-match "This is my name and corp: ted General Creative"   "nginx_setup mkconf DEV nginx.conf"
  should-match "This is my name and corp: disney Disney MegaCorp" "nginx_setup mkconf PROD nginx.conf"
  # =======================================================================================================


  # === Fails if one var is not in the other:
  reset-fs
  nginx_setup UPDATE-OR-CREATE-VAR DEV NAME "ted"              >/dev/null
  nginx_setup UPDATE-OR-CREATE-VAR DEV CORP "General Creative" >/dev/null
  nginx_setup UPDATE-OR-CREATE-VAR PROD NAME "disney"          >/dev/null
  echo "This is my name and corp: {{NAME}} {{CORP}}" > "nginx.conf"
  should-exit 1 "nginx_setup mkconf PROD nginx.conf 2>/dev/null"
  # =======================================================================================================

  # === Renders nested mustaches:
  reset-fs
  nginx_setup UPDATE-OR-CREATE-VAR DEV NAME "ted"              >/dev/null
  nginx_setup UPDATE-OR-CREATE-VAR DEV CORP "{{NAME}} Corp" >/dev/null
  echo "My name: {{CORP}}" > "nginx.conf"
  should-match "My name: ted Corp" "nginx_setup mkconf DEV nginx.conf"
  # =======================================================================================================

}



