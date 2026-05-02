HISTFILE=$HOME/.config/zsh/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# bindkey -e

# History sharing across terminal instances
setopt inc_append_history
setopt share_history

# Ignore duplicate commands in history
setopt histignorealldups

# Fix what zsh defines as a word
# Prevents deleting whole line when only a word/segment should be deleted
autoload -Uz select-word-style
select-word-style bash

# Auto-completion system
autoload -Uz compinit
compinit

# Allow auto-completion system
autoload -Uz bashcompinit
bashcompinit

# Tab completion and highlighted colors
eval "$(dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select

# Keybindings
bindkey "^[[1;5C" forward-word       # Ctrl + Right Arrow: Jump a word forward
bindkey "^[[1;5D" backward-word      # Ctrl + Left Arrow: Jump a word backward

bindkey "^[[H" beginning-of-line     # Home: Jump to start of line
bindkey "^[[1~" beginning-of-line    # Home (Alternative Code): Jump to start of line

bindkey "^[[F" end-of-line           # End: Jump to end of line
bindkey "^[[4~" end-of-line          # End (Alternative Code): Jump to end of line

# --- Deletion (Segment Aware) ---
bindkey "^[[3~" delete-char               # Delete: Delete char in front
bindkey "^H" backward-kill-word           # Ctrl + Backspace: Delete segment back
bindkey "^[[3;5~" kill-word               # Ctrl + Delete: Delete segment forward

# --- Line Killing ---
bindkey "^U" backward-kill-line           # Ctrl + Shift + Backspace: Delete whole line back
bindkey "^[[3;6~" kill-line               # Ctrl + Shift + Delete: Delete whole line forward

# --- System & Environment ---
# Ensure your binaries are discoverable
export PATH=$PATH:$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin
export EDITOR="/usr/bin/nano"

# Auto-suggest if command requires a package when not found
# Auto-suggest package if command is not found
command_not_found_handler () {
    if [ -x /usr/lib/command-not-found ]; then
        /usr/lib/command-not-found -- "$1"
        return $?
    elif [ -x /usr/share/command-not-found/command-not-found ]; then
        /usr/share/command-not-found/command-not-found -- "$1"
        return $?
    else
        printf "%s: command not found\n" "$1" >&2
        return 127
    fi
}

# --- Plugins & External Tools ---
# Load auto-suggestions (Ensure the file path is correct)
if [ -f $HOME/.config/zsh/auto-suggestion.zsh ]; then
    source $HOME/.config/zsh/auto-suggestion.zsh
fi

# Initialize Starship Prompt (Must be at the end)
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# --- Custom Aliases ---
# Automatically load any files named .aliases.*.zsh from home directory
for aliases_file in $(\ls -a $HOME | \grep -E "\.aliases.*\.zsh"); do
    source $HOME/$aliases_file
done

# Fast fetch on open
if command -v fastfetch &> /dev/null; then
    fastfetch
fi