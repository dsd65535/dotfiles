venv() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <name of virtual environment>"
	else
		source ~/.local/share/virtualenvs/${1}/bin/activate
	fi
}

mkvenv() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <name of virtual environment>"
	else
		python3 -m venv ~/.local/share/virtualenvs/${1}
	fi
}

rmvenv() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <name of virtual environment>"
	else
		rm -rf ~/.local/share/virtualenvs/${1}
	fi
}

check() {
	reorder-python-imports $@ || :
	black $@
	pylint --enable=useless-suppression $@
	mypy --disallow-untyped-calls --disallow-untyped-defs --disallow-incomplete-defs $@
}

rshark() {
	ssh $1 tcpdump -U -w - -i $2 $3 | wireshark -k -i -
}

opn() {
	for file in "$@"; do
		echo $file
		xdg-open "$file"
	done
}

lastfile() {
	find "${@:-.}" -maxdepth 1 -type f -printf '%T@.%p\0' | \
		sort -znr -t. -k1,2 | \
		while IFS= read -r -d '' -r record ; do
			printf '%s' "$record" | cut -d. -f3-
			break
		done
}

ssh_noh() {
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q "$@"
}

scp_noh() {
	scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q "$@"
}

dump() {
	if [ "$#" -ne 2 ]; then
		echo "Usage: ${FUNCNAME[0]} <base_addr> <length>"
	else
		for offset in $(seq ${2}); do
			address=$(( ${1} - 4 + 4 * ${offset} ))
			printf "0x%X: " ${address}
			devmem ${address}
		done
	fi
}

diffl() {
	if [ "$#" -ne 2 ]; then
		echo "Usage: ${FUNCNAME[0]} <file 0> <file 1>"
	else
		mkdir -p ${1}
		cd ${1}
		l1=$(cat $1 | wc -l)
		l2=$(cat $2 | wc -l)
		l=$(( l1 > l2 ? l2 : l1 ))
		diff <(head -n ${l} ${1}) <(head -n ${l} ${2})
	fi
}

mc() {
	if [ "$#" -ne 1 ]; then
		echo "Usage: ${FUNCNAME[0]} <name of directory>"
	else
		mkdir -p ${1}
		cd ${1}
	fi
}
