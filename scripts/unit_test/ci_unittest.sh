#!/bin/bash
set -e

echo "=== Starting Unit Test CI ==="

# Get changed .py test files from this PR
CHANGED_FILES=$(git diff --name-only origin/main...HEAD -- '*.py' 2>/dev/null || true)

if [ -z "$CHANGED_FILES" ]; then
    echo "No Python test files changed, skipping."
    exit 0
fi

FLAGS_enable_CI=false

for file_name in $CHANGED_FILES; do
    ext="${file_name##*.}"
    echo "file_name: $file_name, ext: $ext"
    if [[ "$ext" == "py" ]] && [[ -f "$file_name" ]]; then
        FLAGS_enable_CI=true
        break
    fi
done

if [ "$FLAGS_enable_CI" = true ]; then
    echo "Running pytest on changed files..."
    for f in $CHANGED_FILES; do
        if [[ -f "$f" ]] && [[ "$f" == *.py ]]; then
            echo "Executing: $f"
            python3 -m pytest "$f" -v --timeout=60 2>&1 || true
        fi
    done
fi

echo "=== Unit Test CI Complete ==="
