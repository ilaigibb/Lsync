# AGENTS.md - lsync Project Documentation

## Project Overview

**lsync** is a bash-based file and directory synchronization tool that uses rsync over SSH to sync files between a local machine and remote server.

**Version**: 1.1.1

**Naming Note**: The default remote path is `.lodestone` in the script defaults, but is fully configurable. The user previously used `.lodestone` (lodestone panel) and may configure `.pterodactyl` (pterodactyl panel) during `lsync init`.

---

## Local Development Setup

The repo is cloned at `/home/ilai/lsync`. Use the local version via:

```bash
# Add to PATH (already added to ~/.bashrc)
export PATH="$HOME/bin:$PATH"

# Or run directly
/home/ilai/lsync/lsync --help

# Or via symlink in ~/bin
~/bin/lsync --help
```

---

## Installation

```bash
# Quick install (requires sudo)
sudo cp /home/ilai/lsync/lsync /usr/local/bin/lsync
sudo chmod +x /usr/local/bin/lsync
lsync init

# Or via installer script (downloads from GitHub)
curl -sL https://raw.githubusercontent.com/ilaigibb/Lsync/main/install.sh | bash
```

---

## Configuration

Config is stored at `~/.config/lsync/config` (XDG base dir). Profiles are stored in `~/.config/lsync/profiles/`. Run `lsync init` to configure interactively.

**Important**: The config key is `SSH_USER` (not `USER`) to avoid shadowing bash's built-in `$USER` variable. Legacy configs using `USER=` are automatically migrated on load.

```bash
HOST=""
SSH_USER="ubuntu"
SSH_KEY="$HOME/.ssh/id_rsa.key"
REMOTE_PATH=".lodestone"
LOCAL_PATH="$HOME/localServer"
BACKUP_DIR="$HOME/.lsync_backups"
PUSH_CMD="dpush"
PULL_CMD="dpull"
AUTO_SUDO=false
DEFAULT_REMOTE_USER=""
BACKUP_DAYS=30
```

---

## Commands

| Command | Description |
|---------|-------------|
| `lsync dpush` | Push `REMOTE_PATH` to server (configurable name) |
| `lsync dpull` | Pull `REMOTE_PATH` from server (configurable name) |
| `lsync push [folder]` | Push current directory (or subfolder) to server |
| `lsync pull [folder]` | Pull current directory (or subfolder) from server |
| `lsync push <profile>` | Push all paths in a profile to server |
| `lsync pull <profile>` | Pull all paths in a profile from server |
| `lsync <profile>` | Pull from profile (shorthand) |
| `lsync backup` | List available backups |
| `lsync restore <name>` | Restore from backup |
| `lsync init` | Configure lsync interactively |
| `lsync init --reset` | Reset/overwrite existing configuration |

### Profile Commands

| Command | Description |
|---------|-------------|
| `lsync create <name>` | Create a new profile |
| `lsync add <profile> <path-name> [folder]` | Add a path to a profile |
| `lsync remove <profile> [path-name]` | Remove a profile or a path from it |
| `lsync profiles` | List all profiles and their paths |
| `lsync default <profile>` | Set (or show) the default profile |
| `lsync rename <old> <new>` | Rename a profile |

---

## Flags

| Flag | Description |
|------|-------------|
| `-y`, `--yes` | Auto-confirm all prompts (including sudo) |
| `-q`, `--quiet` | Suppress non-error output |
| `--sudo` | Use sudo on remote (warns; requires passwordless sudo) |
| `-u`, `--user <user>` | Override remote user for this run |
| `--debug` | Show raw rsync output |
| `--dry-run` | Preview changes without syncing |
| `--delete` | Remove files at destination not present in source |
| `--exclude <pattern>` | Exclude files matching pattern (repeatable) |
| `--min-size <size>` | Only sync files larger than size (e.g. `1M`, `500K`) |
| `--newer <duration\|date>` | Only sync files newer than duration (`24h`, `7d`, `30m`) or date (`2024-01-01`) |
| `--no-colors` | Disable colored output (also respects `$NO_COLOR`) |
| `-v`, `--verbose` | Increase verbosity (repeatable; passes extra `-v` to rsync) |
| `--checksum` | Verify file integrity with checksum during sync |

---

## Key Implementation Details

- **Argument parsing**: `parse_flags` collects non-flag arguments into `CMD_ACTION`, `CMD_ARG`, `CMD_ARG2`, `CMD_ARG3` — avoids positional `$2`/`$3` bugs.
- **rsync options as arrays**: `RSYNC_OPTS` and `FILTER_ARGS` are bash arrays to handle spaces in paths and patterns safely.
- **Progress**: Uses a single rsync call with `--info=progress2`, parsing `to-check=REMAINING/TOTAL` lines live. No double round-trip.
- **Exit codes**: `PIPESTATUS[0]` captures rsync's real exit code from the pipeline; errors print the last captured output lines.
- **Host key checking**: Defaults to `accept-new` (safe). Set `STRICT_HOST_KEY_CHECKING=no` in config to disable (not recommended).
- **Backup rotation**: Old backups older than `BACKUP_DAYS` days are pruned automatically after each sync.
- **Profile sync**: Uses a proper INI-style section parser (`get_profile_path_value`) instead of fragile `grep -A2`.
- **Color**: Respects `$NO_COLOR` env var and `--no-colors` flag.
- **Clone detection**: Prints `[CLONE]` marker in output when not run from `/usr/local/bin` (i.e. dev clone).

---

## Testing

```bash
# Test locally
/home/ilai/lsync/lsync --version
/home/ilai/lsync/lsync --help

# Auto-confirm
echo "y" | /home/ilai/lsync/lsync dpull

# Dry run (preview changes without syncing)
/home/ilai/lsync/lsync --dry-run push

# With timeout
timeout 30 /home/ilai/lsync/lsync dpull
```
