#!/usr/bin/env bash
set -euo pipefail

REPO="basecamp/omarchy"
OUTPUT="data/contributors.json"

mkdir -p "$(dirname "$OUTPUT")"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "Fetching contributors from ${REPO}..."

page=1

while true; do
  response="$(
    curl --fail --silent --show-error --location \
      --header "Accept: application/vnd.github+json" \
      --header "X-GitHub-Api-Version: 2026-03-10" \
      "https://api.github.com/repos/${REPO}/contributors?per_page=100&page=${page}"
  )"

  count="$(jq 'length' <<<"$response")"

  if [[ "$count" -eq 0 ]]; then
    break
  fi

  jq -c '.[] | select(.type == "User")' <<<"$response" >>"$tmp"

  echo "Fetched page ${page}: ${count} contributors"

  if [[ "$count" -lt 100 ]]; then
    break
  fi

  page=$((page + 1))
done

jq -n \
  --slurpfile contributors "$tmp" \
  --arg repo "$REPO" '
  {
    generatedAt: (now | todateiso8601),
    repository: $repo,
    contributors: (
      $contributors
      | map({
          login,
          avatarUrl: .avatar_url,
          profileUrl: .html_url,
          commits: .contributions
        })
      | sort_by(-.commits, .login)
    )
  }
' >"$OUTPUT"

echo
echo "Updated $OUTPUT"
echo "Contributors: $(jq '.contributors | length' "$OUTPUT")"
