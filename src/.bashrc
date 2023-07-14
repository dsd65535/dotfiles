# Source global startup files
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User-specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
	PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Source user-specific startup files
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi
unset rc

. "$HOME/.cargo/env"
export PATH=$PATH:${CARGO_HOME:-~/.cargo}/bin


## History settings ##

# Append to HISTFILE instead of overwriting it
# This is already set on most systems
shopt -s histappend

# Use a separate HISTFILE for each TTY
# This has the added benefit of ensuring nothing
# else messes with the common ~/.bash_history file
history_dir=${HOME}/.bash_history.d
mkdir -p ${history_dir}
export HISTFILE=${history_dir}/tty_$(basename $(tty))

# Don't truncate HISTFILE
export HISTFILESIZE=
export HISTSIZE=

# Save all commands
export HISTCONTROL=
export HISTIGNORE=

# Save timestamps
export HISTTIMEFORMAT="[%F %T] "

# Save commands right away in case session terminates early
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
