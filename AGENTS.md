# AGENTS.md - lsync Project Documentation

## Project Overview

**lsync** is a bash-based file and directory synchronization tool that uses rsync over SSH to sync files between a local machine and remote server.

**Naming Note**: Previously synced `.lodestone`, now syncs `.pterodactyl` (petro) - the user switched from lodestone to pterodactyl panel.

---

## Local Development Setup

The repo is cloned at `/home/ilai/Lsync`. Use the local version via:

```bash
# Add to PATH (already added to ~/.bashrc)
export PATH="$HOME/bin:$PATH"

# Or run directly
/home/ilai/Lsync/lsync --help

# Or via symlink in ~/bin
~/bin/lsync --help
```

---

## Installation

```bash
# Quick install (requires sudo)
sudo cp /home/ilai/Lsync/lsync /usr/local/bin/lsync
sudo chmod +x /usr/local/bin/lsync
lsync init
```

---

## Configuration

First run `lsync init` to configure. Config is stored at `~/.lsyncrc`:

```bash
HOST="129.159.130.127"
USER="ubuntu"
SSH_KEY="$HOME/.ssh/id_rsa.key"
REMOTE_PATH=".pterodactyl"
LOCAL_PATH="$HOME/localServer"
BACKUP_DIR="$HOME/.lsync_backups"
PUSH_CMD="dpush"
PULL_CMD="dpull"
```

---

## Commands

| Command | Description |
|---------|-------------|
| `lsync dpush` | Push `.pterodactyl` to server |
| `lsync dpull` | Pull `.pterodactyl` from server |
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

## Testing

```bash
# Test locally
/home/ilai/Lsync/lsync --version
/home/ilai/Lsync/lsync --help

# Auto-confirm
echo "y" | /home/ilai/Lsync/lsync dpull

# With timeout
timeout 30 /home/ilai/Lsync/lsync dpull
```
