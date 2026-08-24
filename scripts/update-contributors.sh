#!/usr/bin/env bash
set -euo pipefail

REPO="basecamp/omarchy"
OUTPUT="data/contributors.json"

mkdir -p "$(dirname "$OUTPUT")"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl --fail --silent --show-error --location \
  --header "Accept: application/vnd.github+json" \
  --header "X-GitHub-Api-Version: 2026-03-10" \
  "https://api.github.com/repos/${REPO}/contributors?per_page=100" \
  >"$tmp"

jq '
  {
    generatedAt: (now | todateiso8601),
    repository: "'"$REPO"'",
    contributors: [
      .[]
      | select(.type == "User")
      | {
          login,
          avatarUrl: .avatar_url,
          profileUrl: .html_url,
          commits: .contributions
        }
    ]
  }
' "$tmp" >"$OUTPUT"

echo "Updated $OUTPUT"
