#!/usr/bin/env bash
# Checks that commit subjects follow Conventional Commits with a scope and
# reference their issue, e.g. "feat(bills): add yearly recurrence (#12)".
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

if [[ $bad -eq 1 ]]; then
  echo "Allowed types: feat fix perf refactor style test docs build ci chore revert." >&2
  echo "Open an issue first and end the subject with its number, e.g. (#12)." >&2
  exit 1
fi
echo "OK: commit messages follow the convention."
