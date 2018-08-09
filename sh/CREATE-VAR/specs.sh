

specs () {
  local +x TMP="/tmp/nginx_setup_specs/vars"

  reset-fs () {
    cd /tmp
    rm -rf "$TMP"
    mkdir -p "$TMP"
    cd "$TMP"
  }

  # ===============================================================
  reset-fs
  should-create-file-with-content "config/DEV/port" "4567" "nginx_setup CREATE-VAR DEV port 4567"
  # ===============================================================

  # ===============================================================
  reset-fs
  should-create-file-with-content "config/PROD/port" "4567" "nginx_setup CREATE-VAR PROD port 4567"
  # ===============================================================

  # ===============================================================
  reset-fs
  should-exit 1 "nginx_setup CREATE-VAR stag port 4567"
  # ===============================================================

  # ===============================================================
  reset-fs
  mkdir -p $TMP/config/stag
  should-create-file-with-content  "config/stag/port" "4567" "nginx_setup CREATE-VAR stag port 4567"
  # ===============================================================


} # === function specs

specs
