
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

# === {{CMD}}  "ENV"  "nginx.conf.mustache"
vars-to-conf () {
  local ENV_NAME="$(bash_setup upcase "$1")"; shift
  local TEMPLATE="$1"; shift
  # === CHECK IF ENVS match:
  local ENVS="$(envs)"
  local ENV_COUNT="$(echo "$ENVS" | wc -l)"

  if [[ $ENV_COUNT -lt 1 ]]; then
    bash_setup RED "=== {{No ENVS}} found in config/"
    exit 1
  fi

  local FILE

  for VAR_NAME in $(vars); do
    local FILE="config/${ENV_NAME}/${VAR_NAME}"
    if [[ ! -f "$FILE" ]]; then
      bash_setup RED "=== File does not exist for ${ENV_NAME}: $FILE"
      exit 1
    fi

    # === From now on: use LOCAL and EXPORT to
    #     prevent name clashing with template values.
    export ${VAR_NAME}="$(cat "$FILE")"
  done

  local OLD=""
  local CURRENT="$(cat "$TEMPLATE")"
  while [[ "$OLD" != "$CURRENT" ]]; do
    local OLD="$CURRENT"
    local CURRENT="$(echo "$CURRENT" | bash_setup mush)"
  done

  echo "$CURRENT"
} # === end function

specs () {
  local TMP="/tmp/nginx_setup/vars"

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
}



