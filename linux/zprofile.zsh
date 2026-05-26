# User-local bin dirs on PATH
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
    *":$HOME/bin:"*) ;;
    *) [ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH" ;;
esac

# Cowsay greeting (matches mac flow). Skip if non-interactive.
if [[ $- == *i* ]] && command -v cowsay >/dev/null 2>&1; then
    cowsay "Hello Femi :)"
fi
