# lsync Bug Fix Plan — 8 Bugs Found

Full audit of lsync (1477 lines) and install.sh (58 lines). Each bug includes
the exact location, what breaks, why it breaks, and a concrete fix with code.

---

## Bug 1 — backup_create() silences errors (lsync:589)

**Location**: `backup_create()`, line 589
**Symptom**: "Error: Backup failed" with zero explanation. No way to tell if
it's a permission error, SSH key issue, network timeout, or wrong path.
**Root cause**: `2>/dev/null` on the rsync call discards all stderr. rsync
writes errors to stderr, so every failure produces the same opaque message.
**Impact**: Debugging is impossible without manually removing the redirect.
This is the #1 source of user frustration — you can't fix what you can't see.
**Fix**: Replace `2>/dev/null` with a temp file. Print captured output on
failure, delete on success.
```bash
# Line 589 — replace:
if ! "${rsync_cmd[@]}" "$src_with_user" "$backup_path/" 2>/dev/null; then
# with:
local err_file; err_file=$(mktemp)
if ! "${rsync_cmd[@]}" "$src_with_user" "$backup_path/" 2>"$err_file"; then
    cat "$err_file" >&2; rm -f "$err_file"
    echo -e "${RED}${CLONE_MARKER}Error: Backup failed${NC}" >&2; return 1
fi
rm -f "$err_file"
```

---

## Bug 2 — AUTO_SUDO forces root SSH user (lsync:46-56, 564, 1105)

**Location**: `get_remote_user()` lines 46-56. Called from backup_create()
line 564, run_rsync_progress() line 1105, get_changes() line 447.
**Symptom**: With AUTO_SUDO=true, every backup and sync fails. After fixing
Bug 1 you'll see: "root@server: Permission denied".
**Root cause**: get_remote_user() has three branches:
  1. REMOTE_USER set (-u flag) → return it
  2. should_use_sudo (AUTO_SUDO=true) → return "root"
  3. Otherwise → return SSH_USER (e.g. "ubuntu")
Branch 2 fires when AUTO_SUDO=true. All three callers use this for the SSH
connection string (`ssh root@server`). Root SSH is disabled on most servers.
**Why this is wrong**: Sudo and SSH user are separate concerns. Sudo is
already handled by get_rsync_path() which returns `--rsync-path=sudo rsync`
— this runs sudo on the remote side AFTER connecting. The SSH connection
must use the normal user (ubuntu), not root.
**Fix**: Remove the should_use_sudo branch. Only decide between -u flag
and config default:
```bash
get_remote_user() {
    if [[ -n "$REMOTE_USER" ]]; then echo "$REMOTE_USER"
    else echo "$SSH_USER"; fi
}
```

---

## Bug 3 — profile_add() uses local cwd for remote path (lsync:722-730)

**Location**: `profile_add()` lines 722-730
**Symptom**: `lsync add pterodactyl panel` sets both local and remote to
your cwd (e.g. /home/ilai). Remote should be /var/www/pterodactyl.
**Root cause**: Both local_path and remote_path are set to `$cwd` or
`$cwd/$folder`. No way to specify a different remote path.
**Impact**: Profiles are useless for remote-to-local mirroring. Every path
assumes the remote has the exact same directory structure as local.
**Fix**: Prompt separately for remote path after setting local from cwd/folder:
```bash
if [[ -z "$folder" ]]; then local_path="$(pwd)"
else local_path="$(pwd)/$folder"; fi
echo -n "Remote path on server (e.g. /var/www/pterodactyl): "
read -r remote_input
remote_path="${remote_input:-$local_path}"
```

---

## Bug 4 — -u/--user flag silently ignored (lsync:229, 365, 1400)

**Location**: Flag parsed at line 365, overwritten at line 229 inside
load_config(), called at line 1400 in main().
**Symptom**: `lsync -u deployuser push` connects as config user (ubuntu),
not deployuser. The flag does nothing.
**Root cause**: Execution order in main():
  1. parse_flags("$@") sets REMOTE_USER="deployuser" (line 365)
  2. load_config() runs line 229:
     `REMOTE_USER="${DEFAULT_REMOTE_USER:-$SSH_USER}"`
     This UNCONDITIONALLY overwrites REMOTE_USER, destroying the flag.
**Why it matters**: -u is the only per-run SSH user override. It's in --help
and users expect it to work. Currently it's dead code.
**Fix**: Guard line 229 so it only sets REMOTE_USER if not already set:
```bash
# Line 229 — replace:
REMOTE_USER="${DEFAULT_REMOTE_USER:-$SSH_USER}"
# with:
REMOTE_USER="${REMOTE_USER:-${DEFAULT_REMOTE_USER:-$SSH_USER}}"
```

---

## Bug 5 — backup_restore() is a stub (lsync:627)

**Location**: `backup_restore()` line 627
**Symptom**: `lsync restore mybackup` asks for confirmation then prints
"coming soon". Nothing is restored.
**Root cause**: Function was written with confirmation flow but actual
restore logic was never implemented. The backup dir exists with files —
they just never get copied back.
**Design decision**: Where to restore? Options:
  (a) Metadata file in backup dir storing original destination
  (b) Prompt user for destination at restore time
  (c) Derive from backup name (profile_path pattern)
**Fix** (simplest v1 — restore to current directory):
```bash
if confirm "Restore this backup?"; then
    echo "Restoring $backup_path to current directory..."
    rsync -av "$backup_path/" "./"
    echo "Restore complete."
fi
```
User cd's to the right location before running restore. Smarter lookup
from profile names can come later.

---

## Bug 6 — Temp file race in run_rsync_progress() (lsync:1205)

**Location**: `run_rsync_progress()` line 1205, also 1212, 1221
**Symptom**: Two concurrent lsync processes write to the same temp file
`/tmp/.lsync_rsync_err_$$`. `$$` is parent shell PID — not unique across
terminals/subshells.
**Root cause**: Subshell variables can't escape the rsync pipeline, so
error output is written to a fixed-name temp file. The name isn't unique.
**Impact**: Low probability but real — concurrent runs could clobber each
other's error output or delete the wrong file.
**Fix**: Use mktemp for guaranteed uniqueness. Create the file before the
pipe so both the subshell and outer scope reference the same path:
```bash
# Before the pipe:
local err_file; err_file=$(mktemp /tmp/.lsync_rsync_err_XXXXXX)
# In the subshell (line 1205):
printf '%s\n' "${last_error_lines[@]}" > "$err_file" 2>/dev/null || true
# After the pipe (lines 1212, 1221):
if [[ -s "$err_file" ]]; then cat "$err_file" >&2; fi
rm -f "$err_file"
```

---

## Bug 7 — install.sh references .lsyncrc (install.sh:40)

**Location**: `install.sh` line 40
**Symptom**: Installer checks `$HOME/.lsyncrc` but config is at
`~/.config/lsync/config`. Never finds existing config, always runs init.
**Root cause**: lsync migrated to XDG base dirs but install.sh wasn't
updated. It still checks the old path.
**Fix**: Update line 40:
```bash
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/lsync/config"
```

---

## Bug 8 — install.sh VERSION is 1.0.0 (install.sh:7)

**Location**: `install.sh` line 7
**Symptom**: Installer says "lsync v1.0.0 Installer" but script is v1.1.1.
**Root cause**: VERSION not bumped when lsync was updated.
**Fix**: `VERSION="1.1.1"`

---

## Execution Order

All fixes are independent. Order by impact:

1. Bug 2 — get_remote_user root (unblocks AUTO_SUDO users)
2. Bug 1 — backup stderr (makes errors visible)
3. Bug 4 — -u flag override (unblocks per-run user switching)
4. Bug 3 — profile_add remote path (unblocks profile workflows)
5. Bug 6 — mktemp race fix (quick, low risk)
6. Bug 5 — backup_restore impl (simple v1, restore to cwd)
7. Bug 7 — install.sh config path
8. Bug 8 — install.sh version
9. Install: `sudo cp /home/ilai/lsync/lsync /usr/local/bin/lsync`
10. Smoke test: `lsync --version`, `lsync --help`, `lsync profiles`
