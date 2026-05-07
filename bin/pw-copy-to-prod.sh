#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: pw-copy-to-prod.sh LOCAL_PATH REMOTE_PATH" >&2
}

if [[ $# -ne 2 ]]; then
  usage
  exit 64
fi

local_path=$1
remote_path=$2
connect_script=${PW_CONNECT_INSTANCE_SHELL:-/Users/channing/dev/patchwork/repos/InfraTools/aws/connect-instance-shell.sh}
chunk_size=${PW_COPY_TO_PROD_CHUNK_SIZE:-12000}

if [[ ! -r "$local_path" ]]; then
  echo "pw-copy-to-prod.sh: local file not readable: $local_path" >&2
  exit 66
fi

if [[ ! -x "$connect_script" ]]; then
  echo "pw-copy-to-prod.sh: connect script not executable: $connect_script" >&2
  exit 69
fi

encode_base64() {
  if base64 --help 2>/dev/null | grep -q -- '-w'; then
    base64 -w0
  else
    base64
  fi
}

run_remote() {
  local remote_command=$1
  local raw_log normalised_log
  raw_log=$(mktemp -t pw-copy-to-prod.XXXXXX)
  normalised_log=$(mktemp -t pw-copy-to-prod.XXXXXX)

  if ! "$connect_script" -q prod -- "$remote_command" >"$raw_log" < /dev/null; then
    tr -d '\r' <"$raw_log" >"$normalised_log"
    if grep -q '^__ERROR__' "$normalised_log"; then
      grep '^__ERROR__' "$normalised_log" >&2
      rm -f "$raw_log" "$normalised_log"
      exit 1
    fi
    cat "$raw_log" >&2
    rm -f "$raw_log" "$normalised_log"
    exit 1
  fi

  tr -d '\r' <"$raw_log" >"$normalised_log"

  if grep -q '^__ERROR__' "$normalised_log"; then
    grep '^__ERROR__' "$normalised_log" >&2
    rm -f "$raw_log" "$normalised_log"
    exit 1
  fi

  cat "$normalised_log"
  rm -f "$raw_log" "$normalised_log"
}

remote_path_b64=$(printf '%s' "$remote_path" | base64 | tr -d '\n')
remote_b64_path="${remote_path}.b64-upload"
remote_b64_path_b64=$(printf '%s' "$remote_b64_path" | base64 | tr -d '\n')
local_size=$(wc -c <"$local_path" | tr -d ' ')
b64_file=$(mktemp -t pw-copy-to-prod.XXXXXX)

cleanup() {
  rm -f "$b64_file"
}
trap cleanup EXIT

encode_base64 <"$local_path" | tr -d '\n' >"$b64_file"

init_command="sh -c 'f=\$(printf %s \"$remote_path_b64\" | base64 -d); b=\$(printf %s \"$remote_b64_path_b64\" | base64 -d); d=\$(dirname -- \"\$f\"); mkdir -p \"\$d\" || { echo __ERROR__ \"\$d\" not writable; exit 0; }; : > \"\$b\" || { echo __ERROR__ \"\$b\" not writable; exit 0; }; echo __INIT__ \"\$b\"'"
run_remote "$init_command" | grep -q '^__INIT__' || {
  echo "pw-copy-to-prod.sh: init marker not found" >&2
  exit 1
}

chunk_number=0
b64_size=$(wc -c <"$b64_file" | tr -d ' ')
offset=0
while [[ "$offset" -lt "$b64_size" ]]; do
  chunk_number=$((chunk_number + 1))
  chunk=$(dd if="$b64_file" bs=1 skip="$offset" count="$chunk_size" 2>/dev/null)
  chunk_b64=$(printf '%s' "$chunk" | base64 | tr -d '\n')
  append_command="sh -c 'b=\$(printf %s \"$remote_b64_path_b64\" | base64 -d); c=\$(printf %s \"$chunk_b64\" | base64 -d); printf %s \"\$c\" >> \"\$b\" || { echo __ERROR__ append failed; exit 0; }; echo __CHUNK__ $chunk_number'"
  run_remote "$append_command" | grep -q "^__CHUNK__ $chunk_number" || {
    echo "pw-copy-to-prod.sh: chunk marker not found for chunk $chunk_number" >&2
    exit 1
  }
  offset=$((offset + chunk_size))
done

finish_command="sh -c 'f=\$(printf %s \"$remote_path_b64\" | base64 -d); b=\$(printf %s \"$remote_b64_path_b64\" | base64 -d); tmp=\"\$f.tmp.\$\$\"; if base64 -d \"\$b\" > \"\$tmp\"; then mv \"\$tmp\" \"\$f\" && rm -f \"\$b\"; else rm -f \"\$tmp\"; echo __ERROR__ base64 decode failed; exit 0; fi; size=\$(wc -c < \"\$f\" | tr -d \" \"); if [ \"\$size\" != \"$local_size\" ]; then echo __ERROR__ size mismatch local=$local_size remote=\$size; exit 0; fi; echo __OK__ \"\$f\" bytes=\$size chunks=$chunk_number'"
finish_output=$(run_remote "$finish_command")

if ! grep -q '^__OK__' <<<"$finish_output"; then
  echo "pw-copy-to-prod.sh: upload confirmation marker not found" >&2
  printf '%s\n' "$finish_output" >&2
  exit 1
fi

grep '^__OK__' <<<"$finish_output"
trap - EXIT
rm -f "$b64_file"
