
# === {{CMD}}
version () {
  $PWD/progs/nginx/sbin/nginx -v 2>&1 | cut -d'/' -f2
} # === end function
