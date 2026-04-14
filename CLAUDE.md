# CLAUDE.md — chezmoi dotfiles

This is a personal dotfiles repository managed by [chezmoi](https://www.chezmoi.io/).

## Target environments

Three named locations, auto-detected in `.chezmoi.toml.tmpl`:

| Location | Description | Detection |
|---|---|---|
| `desktop` | macOS personal machine (default) | fallback |
| `lxplus` | CERN lxplus cluster | hostname matches `lxplus\d+\.cern\.ch` |
| `clip` | Vienna ÖAW CBE cluster | hostname matches `.*\.cbe\.vbc\.ac\.at` |

The detected location is stored as `.location` and used throughout templates.

## Chezmoi naming conventions

| Prefix/suffix | Meaning |
|---|---|
| `private_dot_*` | maps to `~/.*` with mode 0600 |
| `dot_*` | maps to `~/.*` (world-readable) |
| `executable_*` | applied file gets executable bit |
| `*.tmpl` | rendered as a Go template before applying |
| `run_once_after_*.sh` | script run once after `chezmoi apply` |

## Template patterns

Templates use Go template syntax. Common idioms in this repo:

```
{{ if eq .chezmoi.os "darwin" }} ... {{ end }}        # macOS vs Linux
{{ if eq .location "desktop" }} ... {{ end }}          # per-environment blocks
{{ if hasPrefix .chezmoi.homeDir "/afs" }} ... {{ end }} # AFS home detection
```

The `.location` variable comes from `.chezmoi.toml.tmpl` and must be one of the three values above.

## External binaries

`.chezmoiexternal.toml.tmpl` manages binaries downloaded to `~/.local/bin/`:

- fzf, direnv, starship, gh, glab, uv, git-cliff
- Uses `gitHubLatestReleaseAssetURL` / `gitHubLatestTag` chezmoi functions
- Architecture is mapped at template time (amd64↔x86_64, arm64↔aarch64)
- All entries have a weekly refresh period

To add a new external binary, follow the existing patterns in `.chezmoiexternal.toml.tmpl`.

## Key files

| File | Purpose |
|---|---|
| `.chezmoi.toml.tmpl` | chezmoi config; defines `.location` and other variables |
| `.chezmoiexternal.toml.tmpl` | external binary downloads |
| `.chezmoiignore.tmpl` | files excluded per location |
| `private_dot_zshrc.tmpl` | main zsh config |
| `private_dot_zfuncs/` | zsh autoloaded functions |
| `private_dot_config/starship.toml` | starship prompt (gruvbox dark) |
| `private_dot_config/direnv/` | direnv config + CERN-specific layouts |
| `private_dot_ssh/` | SSH config (private) |
| `private_dot_local/bin/` | helper scripts (grid certs, bitwarden SSH) |
| `.chezmoiscripts/` | post-apply hooks |

## AFS caching

When `$HOME` is on AFS (`/afs/...`), caches are redirected to `/tmp` to avoid AFS quota exhaustion. This affects: pip, uv, cargo, go, npm, starship, and XDG runtime/cache/state dirs.

## Applying changes

```sh
chezmoi apply          # apply all managed files
chezmoi diff           # preview what would change
chezmoi re-add <file>  # pull changes from home dir back into the source
```
