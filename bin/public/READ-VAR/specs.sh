

specs () {
  local +x TMP="/tmp/nginx_setup_specs/vars"
  local +x RESET='\e[0m'
  local +x BOLD='\e[1m'

  reset-fs () {
    cd /tmp
    rm -rf "$TMP"
    mkdir -p "$TMP"
    cd "$TMP"
  }


  # ===============================================================
  reset-fs
  nginx_setup CREATE-VAR DEV port 1234 >/dev/null
  echo -n "=== Output value for env: "
  should-match-stdout "1234" 'nginx_setup READ-VAR DEV port'
  # ===============================================================

  # ===============================================================
  reset-fs
  nginx_setup CREATE-VAR PROD port 1234 >/dev/null
  nginx_setup CREATE-VAR DEV  port 4567 >/dev/null
  echo -n "=== Sorts output by name: "
  should-match-stdout "$(mksh_setup BOLD "{{DEV}}: 4567\n{{PROD}}: 1234")" \
    'nginx_setup READ-VAR port'
  # ===============================================================

} # === specs ()

specs
