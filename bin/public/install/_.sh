
source "$THIS_DIR/bin/public/is-latest/_.sh"

# === {{CMD}}
# === {{CMD}}  "--compile --options"
install () {
  PATH="$PATH:$THIS_DIR/bin"
  PATH="$PATH:$THIS_DIR/../sh_color/bin"
  PATH="$PATH:$THIS_DIR/../sh_string/bin"
  if is-latest; then
    source "$THIS_DIR/bin/public/version/_.sh"
    sh_color GREEN "=== Already installed: {{$(version)}}"
    exit 0
  fi

  local PREFIX="$(realpath --canonicalize-missing "$PWD")"
  local COMPILE=""
  local ORIG_PWD="$PWD"
  local LATEST_VERSION="$(nginx_setup latest-version)"
  local ARCHIVE="nginx-${LATEST_VERSION}.tar.gz"
  local BASE="nginx-${LATEST_VERSION}"
  local URL="http://nginx.org/download/${ARCHIVE}"
  local SOURCE_DIR="/tmp/$(mktemp -d "$BASE".XXXXXXXXXXXXXXXXXX)"
  local UNTAR="tar --directory=""$SOURCE_DIR"" -xzf "

  # === Remove old builds of NGINX to prevent stuffing /tmp:
  rm -rf /tmp/${BASE}.*

  # === Init /tmp dir:
  mkdir -p "$SOURCE_DIR"
  mkdir -p "$ORIG_PWD/config"
  mkdir -p "$ORIG_PWD/tmp"
  mkdir -p "$ORIG_PWD/progs"
  mkdir -p "$PREFIX"

  # === Determine compilation options:
  if [[ -n "$@" ]]; then
    COMPILE="$@"
  fi


  # === Download archive file if it doesn't exist:
  mkdir -p $THIS_DIR/tmp
  cd $THIS_DIR/tmp

  if [[ ! -f "$ARCHIVE" ]]; then
    wget --quiet "$URL"
  fi

  # === Untar archive. Re-download if file is corrupt:
  $UNTAR "$ARCHIVE" || {
    rm -f "$ARCHIVE"
    wget --quiet "$URL"
    $UNTAR "$ARCHIVE"
  }

  # === Compile:
  cd "$SOURCE_DIR"
  cd "$BASE"
  ./configure                               \
    --prefix="$PREFIX"                       \
    --sbin-path="$PREFIX/progs/nginx/sbin/nginx"    \
    --conf-path="$ORIG_PWD/progs/nginx.conf"   \
    --pid-path="$ORIG_PWD/progs/nginx.pid"  \
    --error-log-path="$ORIG_PWD/progs/startup.error.log"  \
    --http-log-path="$ORIG_PWD/progs/startup.access.log"  \
    --with-http_ssl_module             \
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

  sleep 3
  make
  make install

  cd "$ORIG_PWD"
  sh_color GREEN "=== {{NGINX installed}}: $PREFIX"
}

