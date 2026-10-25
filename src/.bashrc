# Source global startup files
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Source global completions
if [ -d /usr/local/etc/bash_completion.d/ ]; then
	for rc in /usr/local/etc/bash_completion.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi
unset rc

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

# Source aliases
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# Source cargo
if [ -f "$HOME/.cargo/env" ]; then
	. "$HOME/.cargo/env"
	export PATH=$PATH:${CARGO_HOME:-~/.cargo}/bin
fi


## History settings ##

# Append to HISTFILE instead of overwriting it
# This is already set on most systems
shopt -s histappend

# Use a separate HISTFILE for each TTY
# This has the added benefit of ensuring nothing
# else messes with the common ~/.bash_history file
history_dir=${HOME}/.bash_history.d
mkdir -p ${history_dir}
export HISTFILE=${history_dir}/$(tty | tr ' /' '__')

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

rh() {
	if command -v rg &> /dev/null; then
		rg "$@" ${history_dir}
	else
		grep -rn ${history_dir} -e "$@"
	fi
}

# hf [file] [pattern] - show a history file like `history`, optionally filtered
hf() {
	local f=${1:-$HISTFILE}
	[[ -f $f ]] || f=${history_dir}/$f
	gawk -v fmt="$HISTTIMEFORMAT" -v pat="$2" '
		/^#[0-9]+$/ { ts = strftime(fmt, substr($0, 2)); next }
		{ n++ }
		pat == "" || $0 ~ pat { printf "%5d  %s%s\n", n, ts, $0 }
	' "$f"
}

# rht pattern - like rh, but with timestamps, grouped by file
rht() {
	gawk -v fmt="$HISTTIMEFORMAT" -v pat="$1" '
		BEGINFILE { n = 0; ts = ""; hdr = 0 }
		/^#[0-9]+$/ { ts = strftime(fmt, substr($0, 2)); next }
		{ n++ }
		$0 ~ pat {
			if (!hdr++) printf "%s%s\n", (seen++ ? "\n" : ""), FILENAME
			printf "%5d  %s%s\n", n, ts, $0
		}
	' "${history_dir}"/*
}

rhs() {
	gawk -v fmt="$HISTTIMEFORMAT" -v pat="$1" '
		BEGINFILE { t = 0; name = FILENAME; sub(".*/", "", name) }
		/^#[0-9]+$/ { t = substr($0, 2); next }
		pat == "" || $0 ~ pat { printf "%d\t%s%-12s  %s\n", t, strftime(fmt, t), name, $0 }
	' "${history_dir}"/* | sort -s -t $'\t' -k1,1n | cut -f2-
}


## Prompt settings ##

PS1="\[\e[0;35m\]\h\[\e[0m\]:\[\e[0;36m\]\w\[\e[0m\]\$ "


## macOS settings ##
export GPG_TTY=$(tty)
export BASH_SILENCE_DEPRECATION_WARNING=1
