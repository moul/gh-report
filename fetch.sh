#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="${DATA_DIR:-$ROOT/data}"
REPOS_FILE="${REPOS_FILE:-$ROOT/repos.txt}"
QUERY_FILE="${QUERY_FILE:-$ROOT/query.graphql}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh-report: 'gh' CLI not installed" >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "gh-report: 'gh' not authenticated (run: gh auth login)" >&2
  exit 1
fi

query="$(cat "$QUERY_FILE")"
mkdir -p "$DATA_DIR"
failed=0
while IFS= read -r repo || [[ -n "$repo" ]]; do
  [[ "$repo" =~ ^[[:space:]]*(#|$) ]] && continue
  if [[ ! "$repo" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$ ]]; then
    echo "gh-report: invalid owner/repo: $repo" >&2
    failed=1
    continue
  fi

  owner="${repo%%/*}"
  name="${repo##*/}"
  out="$DATA_DIR/${owner}--${name}.json"
  tmp="$(mktemp "$DATA_DIR/.snapshot.XXXXXX")"

  echo ">> fetching $repo" >&2
  # Single page of 50, ordered by UPDATED_AT DESC.
  if gh api graphql -F owner="$owner" -F name="$name" -f query="$query" > "$tmp" &&
      ! grep -Eq '"type"[[:space:]]*:[[:space:]]*"RATE_LIMITED"' "$tmp"; then
    mv "$tmp" "$out"
    echo ">> wrote $out" >&2
  else
    echo "gh-report: failed to fetch $repo" >&2
    rm -f "$tmp"
    failed=1
  fi
done < "$REPOS_FILE"
exit "$failed"
