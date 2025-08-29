#!/bin/bash

test_path=$1
filename=$2

echo "🧪"
echo

# Check if path starts with foo/src pattern, if so use foo as project_name, otherwise use root
if [[ $test_path == */src/* ]]; then
  project_name=$(echo "$test_path" | cut -d'/' -f1)
else
  project_name="root"
fi

bloop test $project_name -o "*$filename*"
