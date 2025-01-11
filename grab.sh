#!/bin/bash

grab_parse_options() {
	local depth="1" regex=""
	while (( "$#" )); do
		case "$1" in
			-d)
				depth="$2"
				shift
				;;
			-r)
				regex="$2"
				shift
				;;
			*)
				echo "Usage: grab_files -d <depth> -r <regex>"
				return 1
				;;
		esac
		shift
	done
	eval "echo depth='$depth' regex='$regex'"
}

filter_files() {
	local depth="$1"
	local regex="$2"

	find "$PWD" -maxdepth "$depth" -type f | while read -r file; do
		if [ -z "$regex" ] || [[ "$file" =~ $regex ]]; then
			echo "$file"
		fi
	done
}

file_menu() {
	local IFS=$' '
	local files=($1)
	local num=1

	echo "${#files[@]} matching files found."

	for file in "${files[@]}"; do
		printf "%3d. %s\n" "$num" "$file"
		num=$((num + 1))
	done

	echo
	read -p "Select a file by number (or press q to quit): " selection

	case "$selection" in
		[qQ])
			echo "Quitting."
			return 1
			;;
		*[!0-9]* | 0)
			echo "Invalid selection."
			return 1
			;;
		*)
			if [ "$selection" -gt 0 ] && [ "$selection" -le "${#files[@]}" ]; then
				echo "Copying ${files[$((selection - 1))]} to clipboard ..."
				copy_to_clipboard $(echo "${files[$((selection - 1))]}" | perl -pe 'chomp if eof')
			else
				echo "Invalid selection."
				return 1
			fi
			;;
	esac
}

copy_to_clipboard() {
	local text="$1"
	if command -v pbcopy &>/dev/null; then
		printf "%s" "$text" | pbcopy
	elif command -v xclip &>/dev/null; then
		printf "%s" "$text" | xclip -selection clipboard
	else
		echo "Error: No clipboard utility found. Install pbcopy (Mac) or xclip (Linux)." >&2
		return 1
	fi
}

grab() {
	local depth="1" regex=""
	local options files selection

	options=$(grab_parse_options "$@")
	eval "$options"

	echo "here we are"
	files=($(filter_files "$depth" "$regex"))

	if [ "${#files[@]}" -eq 0 ]; then
		echo "No matching files found."
		return 1
	fi

	file_menu "${files[*]}"
}

