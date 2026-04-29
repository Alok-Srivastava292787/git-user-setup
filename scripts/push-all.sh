#!/usr/bin/env bash
echo "Push all script with safety controls"
#!/usr/bin/env bash
set -e

############################################
# CONFIG – EDIT IF REQUIRED
############################################
WORK_REMOTE="origin-work"
PERSONAL_REMOTE="origin-personal"
ALLOWED_BRANCHES=("main" "develop")

############################################
# HELPERS
############################################
current_branch=$(git branch --show-current)

fail() {
  echo "❌ ERROR: $1"
  exit 1
}

############################################
# SAFETY CHECKS
############################################
if [[ -z "$current_branch" ]]; then
  fail "No active branch detected"
fi

branch_allowed=false
for b in "${ALLOWED_BRANCHES[@]}"; do
  [[ "$current_branch" == "$b" ]] && branch_allowed=true
done

if [[ "$branch_allowed" != true ]]; then
  fail "Branch '$current_branch' is not allowed for push"
fi

git remote get-url "$WORK_REMOTE" &>/dev/null || \
  fail "Missing remote: $WORK_REMOTE"

git remote get-url "$PERSONAL_REMOTE" &>/dev/null || \
  fail "Missing remote: $PERSONAL_REMOTE"

############################################
# CONFIRMATION
############################################
echo "Branch       : $current_branch"
echo "Work repo    : $WORK_REMOTE"
echo "Personal repo: $PERSONAL_REMOTE"
read -p "Proceed with push to BOTH repositories? (yes/no): " CONFIRM
[[ "$CONFIRM" == "yes" ]] || fail "Aborted by user"

############################################
# PUSH
############################################
echo "🚀 Pushing to work repo..."
git push "$WORK_REMOTE" "$current_branch"

echo "🚀 Pushing to personal repo..."
git push "$PERSONAL_REMOTE" "$current_branch"

echo "✅ Push completed safely"