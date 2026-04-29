---
## 📦 Download the package

**Git multi‑account starter ZIP:**  
---

## 📁 What’s inside the ZIP

```text
git-multiaccount-starter/
│
├── scripts/
│   ├── git-multiuser-setup.sh        # SSH + multi‑account setup (per machine)
│   ├── push-all.sh                   # Safe dual‑push with dry‑run & checks
│   └── detect-default-branch.sh      # main vs master auto‑detection
│
├── hooks/
│   ├── pre-commit                    # Blocks wrong user.email
│   ├── pre-push                      # Branch locking (blocks main/master)
│   └── install-hooks.sh              # Installs hooks into .git/hooks
│
├── README.md                         # Usage & explanation
└── .gitignore                        # (Optional – extend as needed)
```

***

## 🚀 How to use on a new Windows machine

### 1️⃣ Unzip

```bash
unzip git-multiaccount-starter.zip
cd git-multiaccount-starter
```

***

### 2️⃣ Set up GitHub users (run once per GitHub account)

```bash
./scripts/git-multiuser-setup.sh
```

*   Run again for **each GitHub ID** (work, personal, client, etc.)
*   Copy the printed public key into GitHub → *Settings → SSH keys*

***

### 3️⃣ Use it in a project

```bash
cd /path/to/your/project
git init
git config user.name  "Work User"
git config user.email "work@company.com"

./hooks/install-hooks.sh
```

This immediately enables:

*   ✅ Author enforcement
*   ✅ Branch locking
*   ✅ Push safeguards

***

### 4️⃣ Add remotes (example)

```bash
git remote add origin-work     git@github-work:Org/Repo.git
git remote add origin-personal git@github-personal:YourUser/Repo.git
```

***

### 5️⃣ Safe pushes

Dry‑run first (recommended):

```bash
./scripts/push-all.sh --dry-run
```

Real push:

```bash
./scripts/push-all.sh
```

***

## 🛡️ What this package guarantees

| Risk                 | Protection              |
| -------------------- | ----------------------- |
| Wrong GitHub account | SSH aliases per remote  |
| Wrong commit author  | `pre-commit` hook       |
| Push to main/master  | `pre-push` hook         |
| Accidental overwrite | No force‑push           |
| Corporate firewall   | SSH over port 443       |
| Human error          | Dry‑run + confirmations |

***

## ✅ Reuse & scale

*   Copy this ZIP to **any new Windows machine**
*   Works for **any number of GitHub accounts**
*   Ideal as:
    *   Personal toolkit
    *   Team standard
    *   Enterprise starter template
    *   GitHub *Template Repository*

***

