#!/usr/bin/env bash
# Usage: upsert-comment.sh <marker> <body-file> [--update-only]
# Edits the PR comment tagged with <marker>, or creates it unless --update-only.
# The tag keeps workflows that comment on the same PR from overwriting each other.
set -euo pipefail

export MARKER="<!-- $1 -->"
body=$(mktemp)
{ echo "$MARKER"; cat "$2"; } > "$body"

id=$(gh api --paginate "repos/$GH_REPO/issues/$PR/comments" \
  --jq '.[] | select(.user.login == "github-actions[bot]" and (.body | startswith(env.MARKER))) | .id' |
  tail -n1)

if [[ -n $id ]]; then
  gh api -X PATCH "repos/$GH_REPO/issues/comments/$id" -F body=@"$body" > /dev/null
elif [[ ${3:-} != --update-only ]]; then
  gh api "repos/$GH_REPO/issues/$PR/comments" -F body=@"$body" > /dev/null
fi
