
specs () {
  local TMP="/tmp/nginx_setup_specs/vars"

  reset-fs () {
    rm -rf "$TMP"
    mkdir -p $TMP
    cd $TMP
  }

  # ===============================================================
  reset-fs
  echo -n "=== Create var: "
  should-create-file-with-content "config/DEV/port" 4567 'nginx_setup UPDATE-OR-CREATE-VAR DEV port 4567'
  # ===============================================================

  # ===============================================================
  reset-fs
  nginx_setup CREATE-VAR DEV port 9000 >/dev/null
  echo -n "=== Updates var: "
  should-create-file-with-content "config/DEV/port" 8000 'nginx_setup UPDATE-OR-CREATE-VAR DEV port 8000'
  # ===============================================================

} # specs()

specs
