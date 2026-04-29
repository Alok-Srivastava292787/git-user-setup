Below are **two reusable artifacts** you can keep in Git, copy to new Windows machines, and reuse for **any number of GitHub users/projects**:

1.  ✅ **A Shell Script** → for **actual setup**
2.  ✅ **A README.md playbook** → for **learning & understanding what happens and why**

Both are written for:

*   **Windows (Git Bash)**
*   **No admin rights**
*   **Corporate networks (SSH over port 443)**
*   **Multi‑GitHub‑user setup**

***

# ✅ 1️⃣ Shell Script: `git-multiuser-setup.sh`

> 📌 Purpose  
> Sets up SSH, multiple GitHub users, and validates connectivity.  
> Safe to reuse on **any new Windows machine**.

***

### 📄 `git-multiuser-setup.sh`

```bash
#!/usr/bin/env bash

############################################################
# Git Multi-User SSH Setup Script (Windows / Git Bash)
#
# - Supports multiple GitHub users
# - Uses SSH over port 443 (corporate firewall safe)
# - Does NOT require admin rights
#
# Run once per machine
############################################################

set -e

echo "==============================================="
echo " Git Multi-User SSH Setup"
echo "==============================================="

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

############################################################
# Step 1: Collect user input
############################################################

read -p "Enter GitHub alias name (e.g. github-work): " GH_ALIAS
read -p "Enter GitHub email (used as key comment): " GH_EMAIL
read -p "Enter SSH key file name (e.g. id_ed25519_work): " KEY_NAME

KEY_PATH="$SSH_DIR/$KEY_NAME"

############################################################
# Step 2: Generate SSH key if missing
############################################################

if [[ -f "$KEY_PATH" ]]; then
  echo "✔ SSH key already exists: $KEY_PATH"
else
  echo "Generating SSH key..."
  ssh-keygen -t ed25519 -C "$GH_EMAIL" -f "$KEY_PATH"
fi

############################################################
# Step 3: Ensure SSH config entry exists
############################################################

if grep -q "Host $GH_ALIAS" "$CONFIG_FILE" 2>/dev/null; then
  echo "✔ SSH config already contains $GH_ALIAS"
else
  echo "Adding SSH config for $GH_ALIAS"

  cat >> "$CONFIG_FILE" <<EOF

# GitHub account: $GH_EMAIL
Host $GH_ALIAS
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile $KEY_PATH
EOF
fi

chmod 600 "$CONFIG_FILE"

############################################################
# Step 4: Start SSH agent
############################################################

echo "Starting SSH agent..."
eval "$(ssh-agent -s)"

############################################################
# Step 5: Add SSH key to agent
############################################################

ssh-add "$KEY_PATH"

############################################################
# Step 6: Show public key (for GitHub UI copy)
############################################################

echo "==============================================="
echo " COPY THIS PUBLIC KEY TO GITHUB → Settings → SSH Keys"
echo "==============================================="
cat "${KEY_PATH}.pub"
echo
echo "==============================================="

############################################################
# Step 7: Test connectivity
############################################################

echo "Testing SSH connection..."
ssh -T "git@$GH_ALIAS" || true

echo
echo "Setup complete ✅"
echo "You can now use this alias in git remotes:"
echo "git@${GH_ALIAS}:ORG/REPO.git"
```

***

### ▶ How to run the script

```bash
chmod +x git-multiuser-setup.sh
./git-multiuser-setup.sh
```

🔁 Run **again** for every **additional GitHub user**.

***

# ✅ 2️⃣ Documentation Playbook: `README-Git-MultiUser.md`

> 📌 Purpose  
> Explains **what each step does**, **why it exists**, and **how to reuse it safely**.

***

### 📘 `README-Git-MultiUser.md`

````markdown
# Git Multi-User Setup Playbook (Windows / Git Bash)

## Problem Statement

- User is new to GitHub
- Code historically stored in local folders
- Each project must be pushed to GitHub
- Different GitHub user per project
- No admin rights
- Corporate network blocks SSH port 22

---

## High-Level Solution

✅ Use SSH authentication  
✅ One SSH key per GitHub user  
✅ SSH aliases to switch users cleanly  
✅ Port 443 to bypass firewall  
✅ Per-repository Git identity  

---

## Key Concepts (Must Read)

### 1️⃣ Git commit identity ≠ GitHub login

| Config | Purpose |
|-----|------|
| `user.name` | Commit author |
| `user.email` | Commit email |
| SSH key | GitHub authentication |

Changing commit author does **not** change login user.

---

### 2️⃣ Why SSH instead of HTTPS?

HTTPS problems:
- 403 errors
- PAT expiration
- Credential clashes (Windows Credential Manager)

SSH benefits:
- Strong auth
- No passwords
- Per-user isolation
- Works offline once trusted

---

### 3️⃣ Why SSH Agent (`eval "$(ssh-agent -s)"`)?

#### What it does:
- Starts a background process
- Holds decrypted SSH keys in memory
- Allows Git to authenticate silently

#### What happens if you run it again?
- SSH agent restarts
- Loaded keys are LOST
- You must re-run `ssh-add`

✅ Safe to run  
⚠ Requires re‑adding keys

---

## One-Time Machine Setup

Run `git-multiuser-setup.sh` once per GitHub user.

What it does:
- Creates SSH keys
- Adds SSH aliases
- Uses port 443
- Tests access
- Requires no admin privileges

---

## Per-Project Setup (Local Folder → GitHub)

### Step 1: Initialize Git

```bash
git init
````

***

### Step 2: Set project-specific identity

```bash
git config user.name "Work User"
git config user.email "work@example.com"
```

Why:

*   Prevents wrong author on commits
*   Overrides global settings

***

### Step 3: Commit work

```bash
git add .
git commit -m "Initial commit"
```

***

### Step 4: Add GitHub remote using SSH alias

```bash
git remote add origin git@github-work:ORG/REPO.git
```

Why:

*   Forces correct SSH key
*   Prevents account mix-ups

***

### Step 5: Push to GitHub

```bash
git checkout -b main
git push -u origin main
```

***

## Switching GitHub Users (Daily Use)

No logins. No logout. No credential clearing.

Just use:

```bash
git@github-client:org/repo.git
git@github-work:org/repo.git
```

***

## Reusing on Another Windows Machine

✅ Copy script  
✅ Run script per GitHub user  
✅ Add keys to GitHub UI  
✅ Same workflow applies

No admin rights required.

***

## Common Issues & Fixes

| Issue              | Cause           | Fix                 |
| ------------------ | --------------- | ------------------- |
| SSH fails          | Port 22 blocked | Use port 443        |
| Wrong author       | No repo config  | Set user.name/email |
| 403 error          | HTTPS auth      | Switch to SSH       |
| SSH suddenly fails | Agent restarted | Run ssh-add again   |

***

## Golden Rule

    One GitHub user = One SSH key
    One project    = One Git config
    One repo       = One SSH remote

***

## Recommended Workflow

    Local folder
      ↓
    git init
      ↓
    git commit
      ↓
    git push (SSH)
      ↓
    GitHub → visible ✅

***

```

---

# ✅ Final Output Summary

You now have:

✔ **A runnable shell script**  
✔ **A detailed Markdown playbook**  
✔ Portable setup for **multiple machines**  
✔ Works **without admin rights**  
✔ Safe for **corporate networks**  
✔ No HTTPS / PAT / credential issues  

