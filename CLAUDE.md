# CLAUDE.md — chezmoi dotfiles

This is a personal dotfiles repository managed by [chezmoi](https://www.chezmoi.io/).

## Target environments

Three named locations, auto-detected in `.chezmoi.toml.tmpl`:

| Location | Description | Detection |
|---|---|---|
| `desktop` | personal machines: macOS and Fedora 45 Silverblue (default) | fallback |
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
{{ if hasPrefix "/afs" .chezmoi.homeDir }} ... {{ end }} # AFS home detection (prefix first!)
```

The `.location` variable comes from `.chezmoi.toml.tmpl` and must be one of the three values above.
`desktop` does not imply macOS — check `.chezmoi.os` separately.

## External binaries

`.chezmoiexternal.toml.tmpl` manages binaries downloaded to `~/.local/bin/`:

- All platforms: uv, uvx, bat, bat-extras, fd, rg, dust, hyperfine, sd, git-cliff, zoxide, btm, procs, tldr, gping, glow
- Linux only (macOS uses MacPorts): fzf, direnv, starship, gh, eza, glab
- iTerm2 shell integration scripts (`~/.iterm2_shell_integration.{zsh,bash}`)
- `$target` is the Rust triple; Linux always uses the static `musl` builds
- Asset names are matched with globs (`bat-*-%s.tar.gz`) and versioned archive
  directories are removed with `stripComponents = 1`, so no version lookups are needed
- Rust tools with the standard layout are a single `range list (list name repo pattern)` entry
- All entries have a weekly refresh period; `gitHub.refreshPeriod` in `.chezmoi.toml.tmpl`
  caches API results to stay under GitHub's anonymous rate limit
  (or run with `GITHUB_TOKEN=$(gh auth token)`)

## Key files

| File | Purpose |
|---|---|
| `.chezmoi.toml.tmpl` | chezmoi config; defines `.location` and other variables |
| `.chezmoiexternal.toml.tmpl` | external binary downloads |
| `.chezmoiignore.tmpl` | files excluded per location |
| `.chezmoitemplates/shellrc` | interactive setup shared by zsh and bash (hooks, fzf, conda, AFS caches) |
| `private_dot_zshrc.tmpl` / `private_dot_bashrc.tmpl` | shell-specific options, then include `shellrc` |
| `private_dot_config/shell/funcs.sh` | shell functions for zsh and bash (`showpath`, CVMFS setups) |
| `.chezmoiremove` | formerly managed files to delete on apply |
| `private_dot_config/starship.toml` | starship prompt (gruvbox dark) |
| `private_dot_config/direnv/` | direnv config + CERN-specific layouts |
| `private_dot_ssh/` | SSH config (private) |
| `private_dot_local/bin/`, `libexec/` | helper scripts (grid certs, bitwarden SSH, `cbe-login` step-ca hook) |
| `.chezmoiscripts/` | post-apply hooks |

## AFS caching

When `$HOME` is on AFS (`/afs/...`), `shellrc` redirects caches to `/tmp` to avoid AFS quota exhaustion. This affects: pip, uv, cargo, go, npm, starship, and XDG runtime/cache/state dirs.

## Applying changes

```sh
chezmoi apply          # apply all managed files
chezmoi diff           # preview what would change
chezmoi re-add <file>  # pull changes from home dir back into the source
```
