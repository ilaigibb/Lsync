# AGENTS.md - lsync Project Documentation

## Current Status

**NOT YET PUBLISHED** - Files exist locally, need to push to GitHub first.

---

## Project Overview

**lsync** is a bash-based file and directory synchronization tool that uses rsync over SSH to sync files between a local machine and remote server.

---

## Installation (After GitHub Push)

```bash
# Quick install
curl -sL https://raw.githubusercontent.com/ilaigibb/Lsync/main/install.sh | bash

# Or manual install
curl -sL https://raw.githubusercontent.com/ilaigibb/Lsync/main/lsync -o /usr/local/bin/lsync
chmod +x /usr/local/bin/lsync
lsync init
```

---

## Local Installation (Before GitHub)

```bash
# Copy to /usr/local/bin (requires sudo)
sudo cp /home/ilai/bin/lsync /usr/local/bin/lsync
sudo chmod +x /usr/local/bin/lsync

# Or use local version directly
/home/ilai/bin/lsync --help
```

---

## Configuration

First run `lsync init` to configure. Config is stored at `~/.lsyncrc`:

```bash
HOST="129.159.130.127"
USER="ubuntu"
SSH_KEY="$HOME/.ssh/id_rsa.key"
REMOTE_PATH=".lodestone"
LOCAL_PATH="$HOME/localServer"
BACKUP_DIR="$HOME/.lsync_backups"
PUSH_CMD="dpush"
PULL_CMD="dpull"
```

---

## Commands

| Command | Description |
|---------|-------------|
| `lsync dpush` | Push `.lodestone` to server |
| `lsync dpull` | Pull `.lodestone` from server |
| `lsync push [folder]` | Push current directory to server |
| `lsync pull [folder]` | Pull current directory from server |
| `lsync backup` | List available backups |
| `lsync restore <name>` | Restore from backup |
| `lsync init` | Reconfigure lsync |
| `lsync init --reset` | Reset configuration |

---

## Flags

| Flag | Description |
|------|-------------|
| `-y`, `--yes` | Auto-confirm prompts |
| `-q`, `--quiet` | Suppress non-error output |
| `--debug` | Show raw rsync output |
| `--dry-run` | Preview without syncing |
| `--delete` | Remove files not in source |

---

## Files in Repo

```
/home/ilai/bin/
├── lsync           - Main script
├── install.sh      - One-line installer
├── README.md       - User docs
├── AGENTS.md       - Dev docs
├── .gitignore      - Git ignore
└── LICENSE         - MIT License
```

---

## GitHub Push Steps

1. Create repo at https://github.com/new (name: `Lsync`)
2. Run:
   ```bash
   cd /home/ilai/bin
   git init
   git add .
   git commit -m "v1.0.0"
   git remote add origin https://github.com/ilaigibb/Lsync.git
   git push -u origin main
   ```

---

## Testing

```bash
# Test locally
/home/ilai/bin/lsync --version
/home/ilai/bin/lsync --help

# Auto-confirm
echo "y" | /home/ilai/bin/lsync dpull

# With timeout
timeout 30 /home/ilai/bin/lsync dpull
```
