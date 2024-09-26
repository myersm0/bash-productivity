#!/bin/bash

# Check if a command-line tool for clipboard is available
if command -v xclip &> /dev/null; then
	CLIP_CMD="xclip -selection clipboard"
elif command -v pbcopy &> /dev/null; then
	CLIP_CMD="pbcopy"
else
	echo "Clipboard command not found. Install 'xclip' on Linux or use 'pbcopy' on macOS."
	exit 1
fi

cat_files_with_headers() {
	for file in "$@"; do
		if [[ -f "$file" ]]; then
			echo -e "==> $file <=="
			cat "$file"
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
	if [[ $# -gt 0 ]]; then
		# If arguments are passed, treat them as file paths
		output=$(cat_files_with_headers "$@")
		copy_to_clipboard "$output"
	else
		# If no arguments, read file paths from stdin (e.g., from find or piping)
		files=()
		while IFS= read -r file; do
			files+=("$file")
		done

		if [[ ${#files[@]} -eq 0 ]]; then
			echo "No files provided."
			exit 1
		fi

		output=$(cat_files_with_headers "${files[@]}")
		copy_to_clipboard "$output"
	fi
}
