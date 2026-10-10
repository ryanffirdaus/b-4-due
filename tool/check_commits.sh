#!/usr/bin/env bash
# Checks that commit subjects follow Conventional Commits with a scope and
# reference their issue, e.g. "feat(bills): add yearly recurrence (#12)",
# and that no commit carries AI attribution (Co-Authored-By Claude, etc.).
# Usage: tool/check_commits.sh <git revision range>   (default: origin/main..HEAD)
set -euo pipefail

range="${1:-origin/main..HEAD}"
pattern='^(feat|fix|perf|refactor|style|test|docs|build|ci|chore|revert)\([a-z0-9,-]+\)!?: [^ ].* \(#[0-9]+\)$'
# release-please's own commits and merge commits are exempt.
exempt='^(chore\(main\): release |Merge )'

bad=0
while IFS= read -r line; do
  sha="${line%% *}"
  subject="${line#* }"
  if [[ "$subject" =~ $exempt ]]; then continue; fi
  if [[ ! "$subject" =~ $pattern ]]; then
    echo "::error::$sha \"$subject\" must look like: type(scope): description (#issue)"
    bad=1
  fi
done < <(git log --format='%h %s' "$range")

# Commits are authored by people only: no AI co-author trailers or banners.
ai='^co-authored-by:.*(claude|anthropic|openai|copilot|chatgpt)|generated with .*(claude|ai)|noreply@anthropic\.com'
while IFS= read -r sha; do
  if git log -1 --format=%B "$sha" | grep -qiE "$ai"; then
    echo "::error::$(git log -1 --format='%h %s' "$sha") contains AI attribution; remove the trailer"
    bad=1
  fi
done < <(git rev-list "$range")

if [[ $bad -eq 1 ]]; then
  echo "Allowed types: feat fix perf refactor style test docs build ci chore revert." >&2
  echo "Open an issue first and end the subject with its number, e.g. (#12)." >&2
  exit 1
fi
echo "OK: commit messages follow the convention."
