function get_version_num () {
  echo "$@" | grep -oP '[^vV].*'
}

function trunc_patchnum () {
  echo "$@" | grep -oP '[0-9]+.[0-9]+'
}

function version () {
  get_version_num "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}



echo $(get_version_num v1.20.0)  # 1.20.0
echo $(get_version_num V1.20.0)  # 1.20.0

echo $(trunc_patchnum v1.20.0)  # 1.20

echo $(version v1.20.0)  # 1020000000
echo $(version V1.20.0)  # 1020000000
