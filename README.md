
---
# Setting up 2 git accounts on one maching to maintain same local on 2 git accounts
--- 
*   ✅ Configure **multiple GitHub users/IDs**
*   ✅ Switch users **per project**
*   ✅ Push an existing local project to GitHub
*   ✅ Avoid HTTPS / credential / 403 issues
*   ✅ Work reliably behind **corporate firewalls**
*   ✅ Reuse the same approach on any new machine

This is intentionally **long, explicit, and explanatory** so it can be reused as a reference.

***

# 🧩 Problem Statement / Scenario

*   User is **new to GitHub**
*   Used to keep projects in **local folders**
*   Now asked to push each project to GitHub
*   **Different GitHub ID per project**
*   User:
    *   ❌ Has **no admin rights**
    *   ✅ Uses **Windows**
    *   ✅ Uses **Git CLI (Git Bash)**

***

# 🎯 Goal

1.  Set up **multi‑user Git configuration**
2.  Start from **plain local folder → GitHub repo**
3.  Push code securely using **SSH**
4.  Allow **easy switching between GitHub users**
5.  Make it **portable** across multiple Windows machines

***

# 🧠 Core Principles (Important to Understand)

| Concept                        | Why it matters                         |
| ------------------------------ | -------------------------------------- |
| Git **user.name / user.email** | Controls **commit author**, NOT login  |
| GitHub **authentication**      | Controlled by **SSH keys**             |
| SSH over port **443**          | Works even when port 22 is blocked     |
| Per‑repo config                | Prevents using the wrong GitHub ID     |
| No admin rights needed         | Everything runs in user home directory |

***

# 📁 PHASE 0 — Pre‑Setup (Once per Machine)

> These steps are done **once** per Windows machine.

***

## ✅ 0.1 Verify Git is installed

```bash
git --version
```

✅ If Git Bash opens and shows a version, you're good  
❌ If not, install Git for Windows (user‑level install is enough)

***

## ✅ 0.2 Decide GitHub users layout

Example:

```text
Project-A → github-work
Project-B → github-client
Personal  → github-personal
```

Each GitHub account → **one SSH key**

***

# 🔐 PHASE 1 — SSH Multi‑User Setup (Once per Machine)

> This enables switching users **without logging in/out**.

***

## ✅ 1.1 Generate SSH keys (one per GitHub user)

```bash
ssh-keygen -t ed25519 -C "work@email.com" -f ~/.ssh/id_ed25519_work
ssh-keygen -t ed25519 -C "client@email.com" -f ~/.ssh/id_ed25519_client
```

📌 Why:

*   Each file = one GitHub identity
*   No admin rights required
*   Stored in your user home (`~/.ssh`)

***

## ✅ 1.2 Add public keys to GitHub (UI step)

For each user:

```bash
cat ~/.ssh/id_ed25519_work.pub
```

GitHub → **Settings → SSH and GPG Keys → New SSH Key**

📌 Why:

*   GitHub must trust your machine for that user
*   One key = one user

***

## ✅ 1.3 Configure SSH to support multiple users (CRITICAL)

Edit:

```bash
nano ~/.ssh/config
```

```ssh
# Work account (SSH over HTTPS 443 – firewall safe)
Host github-work
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/id_ed25519_work

# Client account
Host github-client
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/id_ed25519_client
```

📌 Why:

*   Host aliases let you choose users per repo
*   Port 443 works on restricted networks
*   No global login switching required

***

## ✅ 1.4 Start SSH Agent

```bash
eval "$(ssh-agent -s)"
```

📌 What this does:

*   Starts an in‑memory process that holds SSH keys
*   Required so Git can use SSH without asking passphrase

📌 What if you run it again?

*   ✅ It restarts the agent
*   ❌ Previously added keys are **forgotten**
*   ✅ You must re‑add keys

***

## ✅ 1.5 Add keys to the agent

```bash
ssh-add ~/.ssh/id_ed25519_work
ssh-add ~/.ssh/id_ed25519_client
```

Verify:

```bash
ssh-add -l
```

***

## ✅ 1.6 Test authentication (MANDATORY)

```bash
ssh -T git@github-work
```

✅ Expected:

    Hi USERNAME! You've successfully authenticated, but GitHub does not provide shell access.

This confirms:

*   SSH works
*   Firewall issue solved
*   Correct GitHub user

***

# 📦 PHASE 2 — Project Setup (Per Project)

> Done **per local folder / project**.

***

## ✅ 2.1 Go to local project folder

```bash
cd /c/projects/MyProject
```

***

## ✅ 2.2 Initialize Git

```bash
git init
```

📌 Why:

*   Converts a normal folder into a Git repo
*   Does NOT affect files

***

## ✅ 2.3 Set Git user for THIS repo (VERY IMPORTANT)

```bash
git config user.name "Work User Name"
git config user.email "work@email.com"
```

📌 Why:

*   Prevents personal email on work project
*   Overrides global config

Verify:

```bash
git config user.name
git config user.email
```

***

## ✅ 2.4 First commit

```bash
git add .
git commit -m "Initial commit"
```

***

# 🌍 PHASE 3 — Connect to GitHub

***

## ✅ 3.1 Create empty GitHub repo (UI)

*   Do ❌ NOT add README
*   Do ❌ NOT add .gitignore
*   Copy **SSH URL** (not HTTPS)

Example:

    git@github.com:Org/MyProject.git

***

## ✅ 3.2 Add remote using SSH alias

```bash
git remote add origin git@github-work:Org/MyProject.git
```

📌 Why:

*   `github-work` forces correct SSH key
*   Avoids HTTPS credential conflicts

Verify:

```bash
git remote -v
```

***

## ✅ 3.3 Create main branch (if needed)

```bash
git checkout -b main
```

***

## ✅ 3.4 Push to GitHub

```bash
git push -u origin main
```

✅ Code now visible on GitHub

***

# 🧪 PHASE 4 — Verification & Troubleshooting

***

## ✅ 4.1 Verify author identity

```bash
git log -1 --pretty=format:"%an <%ae>"
```

***

## ✅ 4.2 Verify remote access

```bash
git remote -v
```

***

## ✅ 4.3 Verify SSH still works

```bash
ssh -T git@github-work
```

***

# 🔁 PHASE 5 — Switching Users (Daily Usage)

No re‑login needed ✅

| Need                   | Action                       |
| ---------------------- | ---------------------------- |
| Switch GitHub user     | Use different SSH Host       |
| Switch commit identity | `git config user.name/email` |
| New machine            | Repeat **Phase 1**           |
| New project            | Repeat **Phase 2–3**         |

***

# 🖥️ Using Same Setup on Another Windows Machine

✅ Repeat:

*   Phase 1 (SSH setup)
*   Phase 2–3 per project

❌ No admin rights required  
✅ No credential conflicts  
✅ Predictable behavior

***

# ✅ Common Mistakes (Avoid These)

| Mistake              | Result                       |
| -------------------- | ---------------------------- |
| Using HTTPS          | 403 / wrong user             |
| No repo‑level config | Wrong commit author          |
| Port 22 SSH          | Blocked in corporate network |
| Forgetting ssh-add   | SSH auth fails               |

***

# 📘 TL;DR – Reusable Mental Model

```text
One GitHub user = One SSH key
One project = One repo-level git config
One repo = One SSH remote
```

***

# 🏁 Final Architecture
```
Local Repo
 ├── origin-work     (github-work)
 └── origin-personal (github-personal)

SSH Config
 ├── github-work     → id_ed25519_work
 └── github-personal → id_ed25519_personal
```
# 📦 Final Template Structure
```
git-multiaccount-starter/
│
├── scripts/
│   ├── git-multiuser-setup.sh
│   ├── push-all.sh
│   └── detect-default-branch.sh
│
├── hooks/
│   ├── pre-commit
│   └── pre-push
│
├── hooks/install-hooks.sh
│
├── README.md
└── .gitignore
```
---

# 🧠 Design Guarantees

| Risk | Mitigation |
|----|----|
Wrong GitHub user | SSH alias + repo config |
Wrong commit author | pre‑commit hook |
Broken history | No force‑push |
Accidental main push | pre‑push hook |
Firewall outage | SSH over 443 |
Human error | Automation + prompts |

---