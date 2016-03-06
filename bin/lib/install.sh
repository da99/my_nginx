
# === {{CMD}}
# === {{CMD}}  "path/to/dir"
# === {{CMD}}  "path/to/dir"   "--compile --options"
# === {{CMD}}  "--compile --options"
install () {
  local DIR="$(realpath --canonicalize-missing nginx/)"
  local COMPILE=""
  local ORIG_PWD="$PWD"
  local SOURCE="nginx-1.8.0.tar.gz"
  local SOURCE_DIR="$(basename "$SOURCE" ".tar.gz")"

  if [[ -n "$@" && "$@" != *"--" ]]; then
    DIR="$(realpath --canonicalize-missing "$1")";
    shift
  fi

  if [[ -n "$@" ]]; then
    COMPILE="$@"
  fi

  mkdir -p "$DIR"

  cd /tmp
  rm -f "$SOURCE"
  wget http://nginx.org/download/$SOURCE
  tar -xzf "$SOURCE"
  cd "$SOURCE_DIR"
  ./configure                          \
    --prefix="$DIR"                  \
    --without-http_auth_basic_module    \
    --without-http_autoindex_module      \
    --without-http_geo_module             \
    --without-http_map_module           \
    --without-http_fastcgi_module        \
    --without-http_uwsgi_module           \
    --without-http_scgi_module           \
    --without-http_empty_gif_module       \
    --without-http_ssi_module              \
    \
    --without-mail_pop3_module       \
    --without-mail_imap_module        \
    --without-mail_smtp_module         \
    $COMPILE
  make
  make install

  cd "$ORIG_PWD"
  bash_setup GREEN "=== {{NGINX installed}}: $DIR"
}
