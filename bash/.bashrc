# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Detect the active wireless interface and assign its IP to $IP
active_interface=$(ip link show | awk '/state UP/ && /wl/ {print $2}' | sed 's/://')
export IP=$(ip -4 addr show "$active_interface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')


# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Set colors
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
BLUE="\[\033[0;34m\]"
YELLOW="\[\033[0;33m\]"
MAGENTA="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
WHITE="\[\033[0;37m\]"
NO_COLOR="\[\033[0m\]"

# Set PS1 prompt
PS1="${WHITE}┌── ${NO_COLOR}[${YELLOW}\u@${BLUE}\h ${WHITE}\w${NO_COLOR}]\n${WHITE}└─▪ ${NO_COLOR}"

# define aliases
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias l='ls -CF'
alias ..='cd ..'
alias da='deactivate'
alias .python='.venv/bin/python'
alias .pip='.venv/bin/pip'
alias .activate='.venv/bin/activate'
alias .hic='history | grep'

shopt -s histappend
PROMPT_COMMAND='history -a'


# functions
# find in js and jsx files
findjs() {
    find $1 -type f \( -name "*.js" -o -name "*.jsx" \) -exec grep --color -Hn "$2" {} +
}

# find in ts and tsx files
findts() {
    find $1 -type f \( -name "*.ts" -o -name "*.tsx" \) -exec grep --color -Hn "$2" {} +
}

# find in python files
findpy() {
    find $1 -type f \( -name "*.py" \) -exec grep --color -Hn "$2" {} +
}

# Replaces a string in all files with given extensions in a directory
refactor() {
  local mode=""
  local dir=""
  local old_string=""
  local new_string=""
  local extensions=()
  local help_text="Usage: refactor [-t|-i] -e <extensions> <directory> <old_string> <new_string>"

  # Reset OPTIND in case getopts is reused in the same shell session
  OPTIND=1

  # Parse the flags
  while getopts "tie:" opt; do
    case $opt in
      t)
        mode="trial"
        echo "Trial mode"
        ;;
      i)
        mode="insert"
        echo "Insert mode"
        ;;
      e)
        IFS=',' read -r -a extensions <<< "$OPTARG"
        ;;
      *)
        echo $help_text
        return 1
        ;;
    esac
  done
  shift $((OPTIND - 1))

  # Check if the correct number of arguments are provided
  if [ "$#" -ne 3 ]; then
    echo $help_text
    return 1
  fi

  # Assign the arguments
  dir="$1"
  old_string="$2"
  new_string="$3"

  # Ensure mode is set correctly
  if [ -z "$mode" ]; then
    echo "Your mode is $mode -> Error: You must specify either -t (trial) or -i (in-place) mode."
    return 1
  fi

  # Ensure extensions are provided
  if [ "${#extensions[@]}" -eq 0 ]; then
    echo "Error: You must provide at least one file extension using the -e flag."
    return 1
  fi

  # Build the find command with arbitrary extensions
  local find_expr=""
  for ext in "${extensions[@]}"; do
    find_expr+=" -name \"*.$ext\" -o"
  done
  # Remove the trailing '-o'
  find_expr="${find_expr% -o}"

    # Build the complete find command
  local find_command="find $dir \( $find_expr \) -exec grep -l "$old_string" {} +"

  # Perform the find and replace operation
  if [ "$mode" == "trial" ]; then
    echo $find_command
    sh -c "$find_command" | xargs -I {} sh -c 'sed -n "s#'"$old_string"'#'"$new_string"'#gp" {} | sed "s#^#{}: # " | grep --color -E "^.*:|'"$new_string"'"'
  elif [ "$mode" == "insert" ]; then
    sh -c "$find_command" | xargs -I {} sh -c 'sed -i "s#'"$old_string"'#'"$new_string"'#g" {} && echo "{}: updated"'
  fi
}


# replaces a string in all js and jsx files in a directory
sedjs() {
  local mode=""
  local dir=""
  local old_string=""
  local new_string=""

  # Parse the flags
  while getopts "ti" opt; do
    case $opt in
      t)
        mode="trial"
        echo "Trial mode"
        ;;
      i)
        mode="insert"
        echo "Insert mode"
        ;;
      *)
        echo "Usage: sedJs [-t|-i] <directory> <old_string> <new_string>"
        return 1
        ;;
    esac
  done
  shift $((OPTIND - 1))


  # Check if the correct number of arguments are provided
  if [ "$#" -ne 3 ]; then
    echo "Usage: sedJs [-t|-i] <directory> <old_string> <new_string>"
    return 1
  fi

  # Assign the arguments
  dir="$1"
  old_string="$2"
  new_string="$3"

  # Ensure mode is set correctly
  if [ "$mode" == "trial" ]; then
    find "$dir" \( -name "*.js" -o -name "*.jsx" \) -exec grep -l "$old_string" {} + | xargs -I {} sh -c 'sed -n "s#'"$old_string"'#'"$new_string"'#gp" {} | sed "s#^#{}: # " | grep --color -E "^.*:|'"$new_string"'"'
  elif [ "$mode" == "insert" ]; then
    find "$dir" \( -name "*.js" -o -name "*.jsx" \) -exec grep -l "$old_string" {} + | xargs -I {} sh -c 'sed -i "s#'"$old_string"'#'"$new_string"'#g" {} && echo "{}: updated"'
  else
    echo "Error: You must specify either -t (trial) or -i (in-place) mode."
    return 1
  fi
}


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

alias firefox-wayland='env MOZ_ENABLE_WAYLAND=1 GDK_BACKEND=wayland firefox'
