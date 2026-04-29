#!/usr/bin/env bash
set -e

############################################
# CONFIG
############################################
WORK_REMOTE="origin-work"
PERSONAL_REMOTE="origin-personal"
DRY_RUN=false

############################################
# PARSE FLAGS
############################################
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
fi

############################################
# DETECT BRANCH
############################################
CURRENT_BRANCH=$(git branch --show-current)

if [[ -z "$CURRENT_BRANCH" ]]; then
  echo "❌ No active branch"
  exit 1
fi

############################################
# SAFETY: PROTECTED BRANCH
############################################
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
  echo "❌ Direct push blocked to $CURRENT_BRANCH"
  echo "Use PR workflow"
  exit 1
fi

############################################
# VERIFY REMOTES
############################################
git remote get-url "$WORK_REMOTE"      >/dev/null
git remote get-url "$PERSONAL_REMOTE"  >/dev/null

############################################
# EXECUTE
############################################
echo "Branch       : $CURRENT_BRANCH"
echo "Work Repo    : $WORK_REMOTE"
echo "Personal Repo: $PERSONAL_REMOTE"

if $DRY_RUN; then
  echo "✅ DRY‑RUN MODE"
  echo "git push $WORK_REMOTE $CURRENT_BRANCH"
  echo "git push $PERSONAL_REMOTE $CURRENT_BRANCH"
  exit 0
fi

read -p "Proceed pushing to both repos? (yes/no): " CONFIRM
[[ "$CONFIRM" == "yes" ]] || exit 1

git push "$WORK_REMOTE" "$CURRENT_BRANCH"
git push "$PERSONAL_REMOTE" "$CURRENT_BRANCH"

echo "✅ Push complete"