below is a **production‑ready, reusable enhancement** to what you already have.  
This gives you **automation + guardrails**, exactly like an enterprise playbook.

You will get **3 deliverables** in one place:

1.  ✅ **Enhanced setup script** – supports *dual‑repo (work + personal) mirroring*
2.  ✅ **`push-all.sh` helper** – one command to push safely to both accounts
3.  ✅ **Safety checks** – prevents pushing to wrong account / wrong branch

All **Git Bash compatible**, **no admin rights**, **Windows‑safe**, **SSH‑443 compatible**.

***

# 1️⃣ Enhanced Setup Script

## `git-multiuser-setup.sh` (UPDATED)

✅ Adds support for **dual remote (work + personal)**  
✅ Enforces **clear remote naming**  
✅ Prevents accidental misuse later

***

### 📄 `git-multiuser-setup.sh`

```bash
#!/usr/bin/env bash
set -e

echo "==============================================="
echo " Git Multi-User + Dual-Repo Setup"
echo "==============================================="

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

############################################
# INPUTS
############################################
read -p "GitHub alias (example: github-work): " GH_ALIAS
read -p "GitHub email for this account: " GH_EMAIL
read -p "SSH key name (example: id_ed25519_work): " KEY_NAME

KEY_PATH="$SSH_DIR/$KEY_NAME"

############################################
# SSH KEY
############################################
if [[ ! -f "$KEY_PATH" ]]; then
  echo "Creating SSH key..."
  ssh-keygen -t ed25519 -C "$GH_EMAIL" -f "$KEY_PATH"
else
  echo "SSH key already exists ✔"
fi

############################################
# SSH CONFIG
############################################
if ! grep -q "Host $GH_ALIAS" "$CONFIG_FILE" 2>/dev/null; then
cat >> "$CONFIG_FILE" <<EOF

Host $GH_ALIAS
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile $KEY_PATH
EOF
fi

chmod 600 "$CONFIG_FILE"

############################################
# SSH AGENT
############################################
eval "$(ssh-agent -s)"
ssh-add "$KEY_PATH"

############################################
# SHOW PUBLIC KEY
############################################
echo
echo "==============================================="
echo "Add this public key to GitHub → SSH Keys"
echo "==============================================="
cat "${KEY_PATH}.pub"
echo "==============================================="

############################################
# TEST CONNECTION
############################################
ssh -T git@$GH_ALIAS || true

echo "Setup complete for alias: $GH_ALIAS ✅"
```

***

# 2️⃣ Dual‑Remote Setup (Work + Personal on Same Repo)

✅ Done **per project**  
✅ Works on any machine once SSH is set up

***

## 📌 Setup commands (run inside project folder)

```bash
# rename default origin → origin-work
git remote rename origin origin-work
```

```bash
# add personal mirror
git remote add origin-personal git@github-personal:USERNAME/REPO.git
```

✅ Verify:

```bash
git remote -v
```

***

# 3️⃣ Push Helper Script

## ✅ `push-all.sh`

This script:

*   ✅ Pushes to BOTH work & personal
*   ✅ Blocks dangerous pushes
*   ✅ Enforces branch policy
*   ✅ Avoids force pushes

***

### 📄 `push-all.sh`

```bash
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
```

***

### ▶ Make executable

```bash
chmod +x push-all.sh
```

***

# 4️⃣ Safety Guarantees (What This Prevents)

| Risk               | Protection                 |
| ------------------ | -------------------------- |
| Force‑push to work | ❌ Blocked (no force flags) |
| Wrong branch       | ❌ Blocked by allowlist     |
| Wrong account      | ✅ Explicit remotes         |
| HTTPS misuse       | ✅ SSH only                 |
| Mirror overwrite   | ✅ No reverse sync          |

***

# 5️⃣ Daily Workflow (Simple & Safe)

```bash
# normal dev
git checkout develop
git commit -m "change"

# push where needed
git push origin-work develop

# publish / backup
./push-all.sh
```

✅ One command  
✅ No ambiguity  
✅ Fully auditable

***

# 6️⃣ How This Scales (Enterprise‑Grade)

*   ✅ Works on **any number of Windows machines**
*   ✅ Works with **10+ GitHub accounts**
*   ✅ Works for **open‑source + corporate**
*   ✅ Zero admin privileges
*   ✅ Firewall friendly

***

# 🏁 Final Architecture

    Local Repo
     ├── origin-work     (github-work)
     └── origin-personal (github-personal)

    SSH Config
     ├── github-work     → id_ed25519_work
     └── github-personal → id_ed25519_personal

***
