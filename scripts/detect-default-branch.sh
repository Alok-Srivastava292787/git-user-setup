#!/usr/bin/env bash
git branch --show-current
#!/usr/bin/env bash
set -e

if git show-ref --quiet refs/heads/main; then
  echo "main"
elif git show-ref --quiet refs/heads/master; then
  echo "master"
else
  echo "❌ No main or master branch found"
  exit 1
fi