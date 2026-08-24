#!/usr/bin/env bash
set -euo pipefail

REPO="basecamp/omarchy"
OUTPUT="data/contributors.json"

mkdir -p "$(dirname "$OUTPUT")"

contributors_tmp="$(mktemp)"
profiles_tmp="$(mktemp)"
output_tmp="$(mktemp)"

trap 'rm -f "$contributors_tmp" "$profiles_tmp" "$output_tmp"' EXIT

headers=(
  --header "Accept: application/vnd.github+json"
  --header "X-GitHub-Api-Version: 2026-03-10"
)

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  headers+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
fi

echo "Fetching contributors from ${REPO}..."

page=1

while true; do
  response="$(
    curl --fail --silent --show-error --location \
      "${headers[@]}" \
      "https://api.github.com/repos/${REPO}/contributors?per_page=100&page=${page}"
  )"

  count="$(jq 'length' <<<"$response")"

  if [[ "$count" -eq 0 ]]; then
    break
  fi

  jq -c '.[] | select(.type == "User")' <<<"$response" >>"$contributors_tmp"

  echo "Fetched page ${page}: ${count} contributors"

  if [[ "$count" -lt 100 ]]; then
    break
  fi

  page=$((page + 1))
done

echo "Enriching contributor profiles..."

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  export GITHUB_TOKEN

  jq -r '.login' "$contributors_tmp" |
    xargs -P 8 -I {} bash -c '
      login="$1"

      curl --fail --silent --show-error --location \
        --header "Accept: application/vnd.github+json" \
        --header "Authorization: Bearer ${GITHUB_TOKEN}" \
        --header "X-GitHub-Api-Version: 2026-03-10" \
        "https://api.github.com/users/${login}" |
      jq -c "{login: .login, name: .name}"
    ' _ {} >"$profiles_tmp"
else
  echo "GITHUB_TOKEN not available; using login as display name."

  jq -c '{login, name: .login}' "$contributors_tmp" >"$profiles_tmp"
fi

jq -n \
  --slurpfile contributors "$contributors_tmp" \
  --slurpfile profiles "$profiles_tmp" \
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
      | map(
          . as $contributor
          | (
              $profiles
              | map(select(.login == $contributor.login))
              | .[0]
            ) as $profile
          | . + {
              name: ($profile.name // $contributor.login)
            }
        )
      | sort_by(-.commits, .login)
    )
  }
' >"$output_tmp"

mv "$output_tmp" "$OUTPUT"

echo
echo "Updated $OUTPUT"
echo "Contributors: $(jq '.contributors | length' "$OUTPUT")"
