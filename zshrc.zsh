export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"
plugins=(git safe-paste)

source $ZSH/oh-my-zsh.sh

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

autoload -Uz compinit
compinit

# iTerm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# what - unified command inspector (alias, function, builtin, external)
what() {
  [[ -z "$1" ]] && { echo "Usage: what <command> [<command>...]"; return 1 }

  for cmd in "$@"; do
    [[ $# -gt 1 ]] && printf '\n\e[1m━━━ %s ━━━\e[0m\n' "$cmd"
    local found=0

    # Alias
    if (( ${+aliases[$cmd]} )); then
      found=1
      printf '\e[36m▸ alias\e[0m  %s=\e[1m%s\e[0m\n' "$cmd" "${aliases[$cmd]}"
      local target="${aliases[$cmd]%% *}" prev="$cmd"
      target="${target//[\'\"]}"
      while (( ${+aliases[$target]} )) && [[ "$target" != "$cmd" && "$target" != "$prev" ]]; do
        printf '  ↳ %s=\e[2m%s\e[0m\n' "$target" "${aliases[$target]}"
        prev="$target"
        target="${aliases[$target]%% *}"
        target="${target//[\'\"]}"
      done
      _what_srcgrep "alias[[:space:]]+${cmd}="
    fi

    # Function
    if (( ${+functions[$cmd]} )); then
      found=1
      printf '\e[33m▸ function\e[0m\n'
      local body="$(which "$cmd")" lines="$(which "$cmd" | wc -l)"
      if (( lines > 30 )); then
        echo "$body" | head -30
        printf '  \e[2m... truncated (%d lines total)\e[0m\n' "$lines"
      else
        echo "$body"
      fi
      _what_srcgrep "(function[[:space:]]+${cmd}[[:space:{]|${cmd}[[:space:]]*\(\))"
    fi

    # Builtin
    if [[ "$(whence -w "$cmd" 2>/dev/null)" == *": builtin" ]]; then
      found=1
      printf '\e[35m▸ builtin\e[0m  %s\n' "$cmd"
    fi

    # Reserved word
    if [[ "$(whence -w "$cmd" 2>/dev/null)" == *": reserved" ]]; then
      found=1
      printf '\e[31m▸ reserved word\e[0m  %s\n' "$cmd"
    fi

    # External commands (all matches in PATH)
    local -a epaths=("${(@f)$(whence -pa "$cmd" 2>/dev/null)}")
    for p in "${epaths[@]}"; do
      [[ -z "$p" || ! -e "$p" ]] && continue
      found=1
      printf '\e[32m▸ external\e[0m  %s' "$p"
      local rp="$p"
      while [[ -L "$rp" ]]; do
        rp="$(readlink "$rp")"
        [[ "$rp" != /* ]] && rp="$(dirname "$p")/$rp"
        printf ' → %s' "$rp"
      done
      echo
      local ft="$(file -b "$rp" 2>/dev/null)"
      printf '  \e[2m%s\e[0m\n' "$ft"
      if [[ "$ft" == *text* || "$ft" == *script* ]]; then
        head -8 "$rp" 2>/dev/null | sed 's/^/  \x1b[2m/;s/$/\x1b[0m/'
      fi
    done

    (( !found )) && { printf '%s: \e[2mnot found\e[0m\n' "$cmd"; return 1 }
  done
}

_what_srcgrep() {
  local pattern="$1"
  local -a files=(~/.zshrc ~/.zshenv ~/.zprofile ~/.zlogin ~/.bash_profile ~/.bashrc ~/.profile)
  local -a dirs=()

  # Discover sourced files from all RC files (eval expands $VARS and $(cmds) in the live shell)
  for rc in "${files[@]}"; do
    [[ -f "$rc" ]] || continue
    local -a lines=(${(f)"$(grep -oE '(source|\.)[[:space:]]+.+' "$rc" 2>/dev/null)"})
    for line in "${lines[@]}"; do
      local target="${line#*(source|.)[[:space:]]}"
      target="${target%;*}"          # strip trailing ;
      target="${target%% \#*}"       # strip trailing comments
      target="${target//\"/}"        # strip quotes
      target="${target//\'/}"
      local resolved="$(eval echo "$target" 2>/dev/null)"
      [[ -f "$resolved" ]] && files+=("$resolved")
    done
  done

  # oh-my-zsh plugins, lib, and custom
  if [[ -d "${ZSH:-$HOME/.oh-my-zsh}" ]]; then
    dirs+=("${ZSH}/lib" "${ZSH}/custom")
    for p in ${plugins[@]}; do dirs+=("${ZSH}/plugins/$p"); done
  fi

  # Search individual files
  for f in "${files[@]}"; do
    [[ -f "$f" ]] || continue
    local match="$(grep -nE "$pattern" "$f" 2>/dev/null | head -1)"
    [[ -n "$match" ]] && { printf '  \e[2mdefined in %s:%s\e[0m\n' "${f/#$HOME/~}" "${match%%:*}"; return }
  done

  # Search directories
  for d in "${dirs[@]}"; do
    [[ -d "$d" ]] || continue
    local hit="$(grep -rnE "$pattern" "$d" --include='*.zsh' --include='*.sh' 2>/dev/null | head -1)"
    if [[ -n "$hit" ]]; then
      local hitfile="${hit%%:*}" hitrest="${hit#*:}"
      printf '  \e[2mdefined in %s:%s\e[0m\n' "${hitfile/#$HOME/~}" "${hitrest%%:*}"
      return
    fi
  done
}


# Aliases — sourced AFTER oh-my-zsh so its lib/directories.zsh can't clobber ll/l/la
DOTFILES_DIR="$(dirname "$(readlink ~/.zshrc)")"
[ -f "$DOTFILES_DIR/aliases.zsh" ] && . "$DOTFILES_DIR/aliases.zsh"

# Load secrets from ~/scripts/.env (gitignored)
[ -f ~/scripts/.env ] && export $(grep -v '^#' ~/scripts/.env | xargs)
