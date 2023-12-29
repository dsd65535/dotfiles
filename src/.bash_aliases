## Utility functions ##

mkcd() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <name of directory>"
		return 1
	fi

	mkdir -p ${1}
	cd ${1}
}

diff_head() {
	if [ "$#" -ne 2 ]; then
		echo "Usage: ${FUNCNAME[0]} <file 0> <file 1>"
		return 1
	fi

	line_count_1=$(cat $1 | wc -l)
	line_count_2=$(cat $2 | wc -l)
	line_count=$(( line_count_1 > line_count_2 ? line_count_2 : line_count_1 ))
	diff <(head -n ${line_count} ${1}) <(head -n ${line_count} ${2})
}

lastfile() {
	find "${@:-.}" -maxdepth 1 -type f -printf '%T@.%p\0' | \
		sort -znr -t. -k1,2 | \
		while IFS= read -r -d '' -r record ; do
			printf '%s' "$record" | cut -d. -f3-
			break
		done
}

dump() {
	if [ "$#" -ne 2 ]; then
		echo "Usage: ${FUNCNAME[0]} <base_addr> <length>"
		return 1
	fi

	for offset in $(seq ${2}); do
		address=$(( ${1} - 4 + 4 * ${offset} ))
		printf "0x%X: " ${address}
		devmem ${address} || return $?
	done
}

opn() {
	if command -v open &> /dev/null; then
		open "$@"
	else
		for file in "$@"; do
			echo $file
			xdg-open "$file"
		done
	fi
}


## Python-related functions ##

venv() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <name of virtual environment>"
		return 1
	fi

	source ~/.local/share/virtualenvs/${1}/bin/activate
}

mkvenv() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <name of virtual environment>"
		return 1
	fi

	python3 -m venv ~/.local/share/virtualenvs/${1}
}

rmvenv() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <name of virtual environment>"
		return 1
	fi

	rm -rf ~/.local/share/virtualenvs/${1}
}

check() {
	reorder-python-imports $@
	black $@ || return $?
	pylint --enable=useless-suppression $@ || return $?
	mypy --disallow-untyped-calls --disallow-untyped-defs \
		--disallow-incomplete-defs $@ || return $?
}


## Miscellaneous functions and aliases ##

rshark() {
	if [ "$#" -lt 2 ]; then
		echo "Usage: ${FUNCNAME[0]} <hostname> <interface> [<option>...]"
		return 1
	fi

	ssh ${1} tcpdump -U -w - -i ${@:2} | wireshark -k -i -
}

alias ssh_noh="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
alias scp_noh="scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

dump_tmux() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <name of directory>"
		return 1
	fi

	mkdir -p ${1}
	for target in $(tmux list-panes -a -F "#S:#I.#P"); do
		tmux capture-pane -epS - -t ${target} > ${1}/${target}
	done
}


## Default flag aliases ##

if command -v rg &> /dev/null; then
	alias rg="rg --hidden"
fi
if command -v fd &> /dev/null; then
	alias fd="fd --hidden"
fi

# This is already set on most systems
alias ls 1>/dev/null 2>/dev/null || alias ls="ls --color=auto"
