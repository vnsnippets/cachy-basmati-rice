HISTFILE=$HOME/.config/zsh/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# History sharing across terminal instances
setopt share_history
setopt histignorealldups

# Fix what zsh defines as a word
autoload -Uz select-word-style
select-word-style bash

# Auto-completion system
autoload -Uz compinit
compinit
autoload -Uz bashcompinit
bashcompinit

# Tab completion and highlighted colors
eval "$(dircolors)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select

# --- Keybindings ---
bindkey "^[[1;5C" forward-word       
bindkey "^[[1;5D" backward-word      
bindkey "^[[H" beginning-of-line     
bindkey "^[[1~" beginning-of-line    
bindkey "^[[F" end-of-line           
bindkey "^[[4~" end-of-line          
bindkey "^[[3~" delete-char               
bindkey "^H" backward-kill-word           
bindkey "^[[3;5~" kill-word               
bindkey "^U" backward-kill-line           
bindkey "^[[3;6~" kill-line               

# --- System & Environment ---
export PATH=$PATH:$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin
export EDITOR="/usr/bin/micro"

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
if [ -f $HOME/.config/zsh/auto-suggestion.zsh ]; then
    source $HOME/.config/zsh/auto-suggestion.zsh
fi

# Initialize Starship Prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# --- Custom Aliases (Optimized Native Zsh Loop) ---
for aliases_file in $HOME/.aliases.*.zsh(N); do
    source $aliases_file
done

# Fast fetch on open
if command -v fastfetch &> /dev/null; then
    fastfetch
fi

# --- ZSH Plugins Sourced Last ---
# Load History Substring Search
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
# Added required bindings for substring search to function
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Load Syntax Highlighting (MUST BE THE ABSOLUTE LAST LINE)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/vnsnippets/Downloads/google-cloud-cli-linux-x86_64/google-cloud-sdk/path.zsh.inc' ]; then . '/home/vnsnippets/Downloads/google-cloud-cli-linux-x86_64/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/vnsnippets/Downloads/google-cloud-cli-linux-x86_64/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/vnsnippets/Downloads/google-cloud-cli-linux-x86_64/google-cloud-sdk/completion.zsh.inc'; fi
