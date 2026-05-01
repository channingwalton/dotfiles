#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: pw-copy-prod.sh REMOTE_PATH LOCAL_PATH" >&2
}

if [[ $# -ne 2 ]]; then
  usage
  exit 64
fi

remote_path=$1
local_path=$2
connect_script=${PW_CONNECT_INSTANCE_SHELL:-/Users/channing/dev/patchwork/repos/InfraTools/aws/connect-instance-shell.sh}

if [[ ! -x "$connect_script" ]]; then
  echo "pw-copy-prod.sh: connect script not executable: $connect_script" >&2
  exit 69
fi

decode_base64() {
  if base64 -d </dev/null >/dev/null 2>&1; then
    base64 -d
  else
    base64 -D
  fi
}

remote_path_b64=$(printf '%s' "$remote_path" | base64 | tr -d '\n')
raw_log=$(mktemp -t pw-copy-prod.XXXXXX)
normalised_log=$(mktemp -t pw-copy-prod.XXXXXX)
local_dir=$(dirname -- "$local_path")
local_base=$(basename -- "$local_path")
mkdir -p "$local_dir"
tmp_out=$(mktemp "$local_dir/.${local_base}.tmp.XXXXXX")

cleanup() {
  rm -f "$raw_log" "$normalised_log" "$tmp_out"
}
trap cleanup EXIT

remote_command="sh -c 'f=\$(printf %s \"$remote_path_b64\" | base64 -d); [ -r \"\$f\" ] || { echo __ERROR__ \"\$f\" not readable; exit 0; }; echo __BEGIN__; base64 < \"\$f\"; echo __END__'"

if ! "$connect_script" -q prod -- "$remote_command" >"$raw_log"; then
  tr -d '\r' <"$raw_log" >"$normalised_log"
  if grep -q '^__ERROR__' "$normalised_log"; then
    grep '^__ERROR__' "$normalised_log" >&2
    exit 1
  fi
  cat "$raw_log" >&2
  exit 1
fi

tr -d '\r' <"$raw_log" >"$normalised_log"

if grep -q '^__ERROR__' "$normalised_log"; then
  grep '^__ERROR__' "$normalised_log" >&2
  exit 1
fi

if ! grep -q '^__BEGIN__$' "$normalised_log" || ! grep -q '^__END__$' "$normalised_log"; then
  echo "pw-copy-prod.sh: transfer markers not found" >&2
  cat "$raw_log" >&2
  exit 1
fi

awk '
  /^__BEGIN__$/ { capture = 1; next }
  /^__END__$/ { capture = 0; exit }
  capture { print }
' "$normalised_log" \
  | tr -cd 'A-Za-z0-9+/=' \
  | decode_base64 >"$tmp_out"

mv "$tmp_out" "$local_path"
trap - EXIT
rm -f "$raw_log" "$normalised_log"
