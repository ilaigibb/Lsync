# lsync

A bash-based file synchronization tool using rsync over SSH.

## Installation

### Quick Install
```bash
curl -sL https://raw.githubusercontent.com/ilaigibb/Lsync/main/install.sh | bash
```

### Manual Install
```bash
curl -sL https://raw.githubusercontent.com/ilaigibb/Lsync/main/lsync -o /usr/local/bin/lsync
chmod +x /usr/local/bin/lsync
lsync init
```

## Configuration

Run `lsync init` to configure. Config saved to `~/.config/lsync/config`.

## Commands

### Basic Sync
| Command | Description |
|---------|-------------|
| `lsync push [folder]` | Push current directory to server |
| `lsync pull [folder]` | Pull current directory from server |

### Profile System
Create named profiles to sync multiple paths:

| Command | Description |
|---------|-------------|
| `lsync create <name>` | Create a new profile |
| `lsync add <profile> <path-name> [folder]` | Add path to profile |
| `lsync remove <profile> [path-name]` | Remove profile or path |
| `lsync profiles` | List all profiles |
| `lsync default <profile>` | Set default profile |
| `lsync rename <old> <new>` | Rename a profile |
| `lsync <profile>` | Pull from profile (shorthand) |
| `lsync pull <profile>` | Pull all paths in profile |
| `lsync pull <profile> <path>` | Pull specific path |
| `lsync push <profile>` | Push all paths in profile |

### Other Commands
| Command | Description |
|---------|-------------|
| `lsync backup` | List backups |
| `lsync restore <name>` | Restore from backup |
| `lsync init` | Reconfigure |
| `lsync init --reset` | Reset configuration |

## Flags

| Flag | Description |
|------|-------------|
| `-y`, `--yes` | Auto-confirm prompts |
| `-q`, `--quiet` | Suppress non-error output |
| `--debug` | Show rsync output |
| `--dry-run` | Preview changes without syncing |
| `--delete` | Remove files not in source |

## Profile Examples

```bash
# Create a profile
lsync create petro

# Add paths (from current directory or specify folder)
lsync add petro panel
lsync add petro wings

# Pull all paths in profile
lsync pull petro

# Pull specific path
lsync pull petro panel

# Set as default so you can just run 'lsync petro'
lsync default petro
```

## License

MIT
