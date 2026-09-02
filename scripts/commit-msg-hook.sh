#!/bin/sh
# Installed as .git/hooks/commit-msg by the disciplined-scaffold skill.
# Rejects commit messages that don't follow Conventional Commits.
# Bypass in an emergency with: git commit --no-verify

msg_file="$1"
first_line=$(head -n1 "$msg_file")

# Allow native git automated operations and comments/empty lines
case "$first_line" in
  Merge*|revert*|Revert*|"fixup!"*|"squash!"*|"#"*|"")
    exit 0
    ;;
esac

# Standard Conventional Commits 1.0.0 types
types="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert|release"
pattern="^($types)(\([a-zA-Z0-9_.-]+\))?!?: .+"

if ! echo "$first_line" | grep -Eq "$pattern"; then
  echo "commit-msg hook: message doesn't look like a conventional commit."
  echo "  got:      $first_line"
  echo "  expected: <type>(<optional-scope>): <description>"
  echo "  types:    feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert, release"
  echo "  bypass:   git commit --no-verify"
  exit 1
fi
