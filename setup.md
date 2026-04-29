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