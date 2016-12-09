
# === {{CMD}}
latest-version () {
  curl -s 'http://nginx.org/en/download.html' |  grep -Po "Stable .+?nginx-\K([\.\d]+)(?=\.tar.gz)" || {
    sh_color RED "!!! Failed to get latest version";
    exit 1;
  }
} # === end function
