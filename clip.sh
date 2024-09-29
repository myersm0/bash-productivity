#!/bin/bash

# Check if a command-line tool for clipboard is available
if command -v xclip &> /dev/null; then
	CLIP_CMD="xclip -selection clipboard"
elif command -v pbcopy &> /dev/null; then
	CLIP_CMD="pbcopy"
else
	echo "Clipboard command not found. Install 'xclip' on Linux or use 'pbcopy' on macOS."
fi

cat_files_with_headers() {
	local header_enabled=$1
	local max_lines=$2
	shift 2

	for file in "$@"; do
		if [[ -f "$file" ]]; then
			if [[ "$header_enabled" == "true" ]]; then
				echo -e "==> $file <=="
			fi
			if [[ "$max_lines" -gt 0 ]]; then
				head -n "$max_lines" "$file"
			else
				cat "$file"
			fi
			echo ""  # Add a blank line between file contents
		else
			echo "File $file not found."
		fi
	done
}

copy_to_clipboard() {
	local content="$1"
	echo "$content" | $CLIP_CMD
	echo "Copied content to clipboard."
}

clip() {
	# Default values for options
	header_enabled=false
	max_lines=0  # 0 means no limit

	while getopts "hn:" opt; do
		case $opt in
			h)
				header_enabled=true
				;;
			n)
				max_lines=$OPTARG
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				return 1
				;;
		esac
	done
	shift $((OPTIND - 1))

	# If no arguments, read from stdin (for piping)
	if [[ $# -eq 0 ]]; then
		files=()
		while IFS= read -r file; do
			files+=("$file")
		done

		if [[ ${#files[@]} -eq 0 ]]; then
			echo "No files provided."
			return 1
		fi
		output=$(cat_files_with_headers "$header_enabled" "$max_lines" "${files[@]}")
	else
		# Collect output with headers and line limit
		output=$(cat_files_with_headers "$header_enabled" "$max_lines" "$@")
	fi

	copy_to_clipboard "$output"
}

