#!/bin/bash
# Backup workspace files to GitHub
# Usage: GITHUB_TOKEN=your_token ./backup.sh

REPO="tmarshall777/Leon"
BRANCH="main"
WORKSPACE="/root/.openclaw/workspace"

TOKEN="${GITHUB_TOKEN}"
if [ -z "$TOKEN" ]; then
    echo "Error: Set GITHUB_TOKEN env variable first"
    exit 1
fi

cd "$WORKSPACE"

# Get all files except .git and backup script itself
files=$(find . -type f ! -path './.git*' ! -name 'backup.sh' ! -name '*.pyc' ! -name '__pycache__*')

# Add all files
for f in $files; do
    if [ -f "$f" ]; then
        content=$(base64 -w0 "$f" 2>/dev/null || base64 "$f")
        curl -s -X PUT "https://api.github.com/repos/$REPO/contents/$f" \
            -H "Authorization: token $TOKEN" \
            -H "Content-Type: application/json" \
            -d "{
                \"message\": \"Backup: $f\",
                \"content\": \"$content\",
                \"branch\": \"$BRANCH\"
            }" || echo "Failed: $f"
    fi
done

echo "Backup complete."