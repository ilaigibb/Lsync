# lsync

A bash-based file synchronization tool using rsync over SSH.

## Installation

### Quick Install (After GitHub Release)
```bash
curl -sL https://raw.githubusercontent.com/ilaigibb/Lsync/main/install.sh | bash
```

### Manual Install
```bash
curl -sL https://raw.githubusercontent.com/ilaigibb/Lsync/main/lsync -o /usr/local/bin/lsync
chmod +x /usr/local/bin/lsync
lsync init
```

### Local Install (Before GitHub Push)
```bash
sudo cp /home/ilai/bin/lsync /usr/local/bin/lsync
sudo chmod +x /usr/local/bin/lsync
lsync init
```

## Configuration

Run `lsync init` to configure. Config saved to `~/.lsyncrc`:


## Commands

| Command | Description |
|---------|-------------|
| `lsync dpush` | Push `.lodestone` to server |
| `lsync dpull` | Pull `.lodestone` from server |
| `lsync push [folder]` | Push current directory |
| `lsync pull [folder]` | Pull current directory |
| `lsync backup` | List backups |
| `lsync restore <name>` | Restore from backup |
| `lsync init` | Reconfigure |

## Flags

| Flag | Description |
|------|-------------|
| `-y`, `--yes` | Auto-confirm |
| `-q`, `--quiet` | Quiet mode |
| `--debug` | Show rsync output |
| `--dry-run` | Preview only |
| `--delete` | Remove extra files |

## License

MIT
