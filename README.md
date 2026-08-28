# local_scripts

My local development environment, packaged so setting up a new machine does
not become an archaeological dig.

This repository contains opinionated bootstrap scripts and dotfiles for macOS
and Debian/Ubuntu Linux. The top-level installer detects the operating system
and dispatches to the appropriate setup.

## Setup

```sh
git clone https://github.com/DavidTeju/local_scripts.git ~/scripts
cd ~/scripts
./fresh_install.sh
```

To update an existing installation:

```sh
git -C ~/scripts pull --ff-only
~/scripts/fresh_install.sh
```

The installers are designed to be rerun, but they are built for my machines,
not as a general-purpose setup tool. Review them before running: they install
packages and applications, create symlinks in `$HOME`, update shell
configuration, and configure development tools.

## What it configures

- Shell, Git, and SSH configuration
- Homebrew packages and macOS applications
- Debian/Ubuntu CLI packages and optional desktop applications
- VS Code settings, keybindings, and extensions
- Claude Code configuration and shared skills
- macOS-specific iTerm2 and utility setup

## Repository layout

| Path | Purpose |
| --- | --- |
| `fresh_install.sh` | Detects macOS or Linux and runs the matching installer |
| `mac/` | macOS installation and platform-specific configuration |
| `linux/` | Debian/Ubuntu installation and platform-specific configuration |
| `lib/` | Shared shell configuration and helpers |
| `ai/` | Claude Code configuration installer |
| `vscode/` | VS Code settings, keybindings, and extension list |
| `gh/` | GitHub CLI configuration |

## Private configuration

This is a public repository. Secrets, SSH keys, and machine-local configuration
must stay untracked. Check `.gitignore` before adding new configuration files,
and inspect staged changes before pushing.
