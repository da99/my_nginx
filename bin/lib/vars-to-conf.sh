
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
vars-to-conf () {
  local +x ENV_NAME="$(bash_setup upcase "$1")"; shift
  local +x TEMPLATE="$(realpath -m "$1")"; shift

  # === CHECK IF ENVS match:
  local +x ENVS="$(envs)"
  local +x ENV_COUNT="$(echo "$ENVS" | wc -l)"

  if [[ $ENV_COUNT -lt 1 ]]; then
    bash_setup RED "=== {{No ENVS}} found in config/"
    exit 1
  fi

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
  nginx_setup var-upsert dev name "ted"              >/dev/null
  nginx_setup var-upsert dev corp "General Creative" >/dev/null
  nginx_setup var-upsert prod name "disney"          >/dev/null
  nginx_setup var-upsert prod corp "Disney MegaCorp" >/dev/null
  echo "This is my name and corp: {{NAME}} {{CORP}}" > "nginx.conf"
  should-match "This is my name and corp: ted General Creative"   "nginx_setup vars-to-conf DEV nginx.conf"
  should-match "This is my name and corp: disney Disney MegaCorp" "nginx_setup vars-to-conf PROD nginx.conf"
  # =======================================================================================================


  # === Fails if one var is not in the other:
  reset-fs
  nginx_setup var-upsert dev name "ted"              >/dev/null
  nginx_setup var-upsert dev corp "General Creative" >/dev/null
  nginx_setup var-upsert prod name "disney"          >/dev/null
  echo "This is my name and corp: {{NAME}} {{CORP}}" > "nginx.conf"
  should-exit 1 "nginx_setup vars-to-conf PROD nginx.conf 2>/dev/null"
  # =======================================================================================================

  # === Renders nested mustaches:
  reset-fs
  nginx_setup var-upsert dev name "ted"              >/dev/null
  nginx_setup var-upsert dev corp "{{NAME}} Corp" >/dev/null
  echo "My name: {{CORP}}" > "nginx.conf"
  should-match "My name: ted Corp" "nginx_setup vars-to-conf DEV nginx.conf"
  # =======================================================================================================

}



