#!/usr/bin/env bash
set -e

# Ensure we are inside a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: Not inside a Git repository."
  exit 1
fi

# Get commit message from argument, or prompt for one, or default to a timestamp
MSG="$1"
if [ -z "$MSG" ]; then
  read -p "Commit message (leave blank for timestamp): " MSG
fi
if [ -z "$MSG" ]; then
  MSG="Sync: $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Stage all changes (new, modified, and deleted files)
git add -A

# Commit only if there are staged changes
if ! git diff --cached --quiet; then
  git commit -m "$MSG"
else
  echo "No local changes to commit."
fi

# Sync with remote: pull with rebase first, then push current branch
CURRENT_BRANCH=$(git branch --show-current)
git pull --rebase origin "$CURRENT_BRANCH"
git push -u origin "$CURRENT_BRANCH"

echo "Successfully synced branch '$CURRENT_BRANCH' with GitHub."
