# Bash port of the `what` command inspector. Sourced from linux/bashrc.sh.
# The richer zsh version (with alias-chain following and source-file detection)
# lives at ../lib/what.zsh.

what() {
    [ -z "$1" ] && { echo "Usage: what <command> [<command>...]"; return 1; }
    for cmd in "$@"; do
        [ "$#" -gt 1 ] && printf '\n\e[1m━━━ %s ━━━\e[0m\n' "$cmd"
        local found=0

        # Alias
        if alias "$cmd" >/dev/null 2>&1; then
            found=1
            printf '\e[36m▸ alias\e[0m  %s\n' "$(alias "$cmd")"
        fi

        # Function
        if declare -F "$cmd" >/dev/null 2>&1; then
            found=1
            printf '\e[33m▸ function\e[0m\n'
            declare -f "$cmd" | head -30
        fi

        # Builtin / keyword
        local t
        t="$(type -t "$cmd" 2>/dev/null)"
        if [ "$t" = "builtin" ]; then
            found=1
            printf '\e[35m▸ builtin\e[0m  %s\n' "$cmd"
        elif [ "$t" = "keyword" ]; then
            found=1
            printf '\e[31m▸ keyword\e[0m  %s\n' "$cmd"
        fi

        # External (all PATH matches)
        while IFS= read -r p; do
            [ -z "$p" ] && continue
            found=1
            printf '\e[32m▸ external\e[0m  %s\n' "$p"
            local rp="$p"
            while [ -L "$rp" ]; do
                local t2; t2="$(readlink "$rp")"
                case "$t2" in /*) rp="$t2" ;; *) rp="$(dirname "$rp")/$t2" ;; esac
                printf '  → %s\n' "$rp"
            done
            local ft; ft="$(file -b "$rp" 2>/dev/null)"
            [ -n "$ft" ] && printf '  \e[2m%s\e[0m\n' "$ft"
        done < <(type -ap "$cmd" 2>/dev/null)

        [ "$found" -eq 0 ] && { printf '%s: \e[2mnot found\e[0m\n' "$cmd"; return 1; }
    done
}
