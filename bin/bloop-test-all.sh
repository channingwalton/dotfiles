#!/bin/bash

set -e

echo "🧪"

for project in $(bloop projects); do
  echo "Testing project: $project"
  bloop test "$project"
  echo ""
done
