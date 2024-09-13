#!/bin/bash

parse_options() {
	local prefix="" prefix_elements regex file_regex depth="1"
	while (( "$#" )); do
		case "$1" in
			-p)
				prefix="$PWD"
				;;
			-p*)
				prefix_elements=$(echo "$PWD" | awk -v n="${1#-p}" -F'/' '{if (NF > n) { for (i=1; i<=n; i++) printf "%s/", $i; } else print $0;}')
				;;
			-r)
				regex="$2"
				shift
				;;
			-c)
				file_regex="$2"
				shift
				;;
			-d)
			   depth="$2"
				shift
				;;
			-n)
			   max_results="$2"
				shift
				;;
			*)
				n="$1"
				;;
		esac
		shift
	done
	eval "echo prefix='$prefix' prefix_elements='$prefix_elements' regex='$regex' file_regex='$file_regex' depth='$depth' max_results='$max_results'"
}

# display numbered list of options for user
menu() {
	local IFS=$' \t\n' # Reset IFS to default setting
	local num n=1 opt item cmd

	# Print the menu options
	for item; do
		printf " %3d. %s\n" "$n" "${item%%:*}"
		n=$((n + 1))
	done

	echo

	# Read user input for selection
	if [ $# -lt 10 ]; then
		opt=-sn1
	else
		opt=
	fi

	read -p " go to:  " $opt num

	case $num in
		[qQ0] | "" ) return ;; # Quit on Q, q, 0, or empty input
		*[!0-9]* | 0*)
			printf "\aInvalid response: %s\n" "$num" >&2
			return 1
		;;
	esac

	echo

	# Execute the selected command if the number is valid
	if [ "$num" -le "$#" ]; then
		eval "${!num#*:}"
	else
		printf "\aInvalid response: %s\n" "$num" >&2
		return 1
	fi
}

add_to_history() {
	local dir="$PWD"
	local history_file="$HOME/.cd_history"
	echo "$dir" >> "$history_file"
}

filter_directories() {
	local dirs=("$@")
	local filtered_dirs=()

	for dir in "${dirs[@]}"; do
		local add=true

		# Apply prefix restriction
		if [ -n "$prefix" ] && [[ "$dir" != "$prefix"* ]]; then
			add=false
		fi
		if [ -n "$prefix_elements" ] && [[ "$dir" != "$prefix_elements"* ]]; then
			add=false
		fi
		# Apply regex restriction
		if [ -n "$regex" ] && [[ ! "$dir" =~ $regex ]]; then
			add=false
		fi
		# Apply file content regex restriction
		if [ -n "$file_regex" ]; then
			  test=$(find "$dir" -maxdepth 1 -type f -printf "%f\n" | grep -iE "$file_regex" | wc -l)
			  if [ $test -lt 1 ]; then
				add=false
			fi
		fi

		# Add the directory if it passed all filters
		if [ "$add" = true ]; then
			filtered_dirs+=("$dir")
		fi
	done
	echo "${filtered_dirs[@]}" | tr ' ' '\n'
}

# Function to list most frequently visited directories with menu
cdf() {
	local history_file="$HOME/.cd_history"
	local history_depth="100"  # Number of records to consider
	local max_results="15"
	local options
	options=$(parse_options "$@")
	eval "$options"
	local item

	if [ ! -f "$history_file" ]; then
		echo "No history file found at $history_file"
		return 1
	fi

	# Get the most frequently visited directories in the last N records
	mapfile -t item < <(tail -n "$history_depth" "$history_file" | sort | uniq -c | sort -nr | awk '{print $2}')

	# Apply filters
	filtered_item=($(filter_directories "${item[@]}"))
	mapfile -t filtered_item < <(printf '%s\n' "${filtered_item[@]}" | head -n $max_results | awk '{print $1 ":cd \"" $1 "\""}')

	if [ ${#filtered_item[@]} -eq 0 ]; then
		echo "No matching directories found."
	else
		menu "${filtered_item[@]}" quit:
	fi

}

# Function to list most recently visited directories with menu
cdr() {
	local history_file="$HOME/.cd_history"
	local history_depth="100"  # Number of records to consider
	local max_results="15"
	local options
	options=$(parse_options "$@")
	eval "$options"
	local item

	if [ ! -f "$history_file" ]; then
		echo "No history file found at $history_file"
		return 1
	fi

	# Get the most recent directories visited in the last N records
	mapfile -t item < <(tail -n "$history_depth" "$history_file" | tac | awk '!seen[$0]++' | awk '{print $1}')

	# Apply filters
	filtered_item=($(filter_directories "${item[@]}"))
	mapfile -t filtered_item < <(printf '%s\n' "${filtered_item[@]}" | head -n $max_results | awk '{print $1 ":cd \"" $1 "\""}')

	if [ ${#filtered_item[@]} -eq 0 ]; then
		echo "No matching directories found."
	else
		menu "${filtered_item[@]}" quit:
	fi
}

# Override the cd command to automatically add to the history file
cd() {
	builtin cd "$@" && add_to_history
}

goahead() {
	local depth="1"  # Default depth
	local regex="" file_regex="" dir IFS=$'\n' item

	# Parse options
	local options
	options=$(parse_options "$@")
	eval "$options"

	# Validate depth
	if ! [[ "$depth" =~ ^[0-9]+$ ]]; then
		echo "Error: Depth must be a number."
		echo "Usage: goahead -d <depth> [-r <regex>] [-c <regex>]"
		return 1
	fi
	echo "depth is $depth"

	# Recursively find directories up to the specified depth
	for dir in $(find "$PWD" -maxdepth "$depth" -type d | sort); do
		[ "$dir" = "$PWD" ] && continue

		# Check if the directory name matches the regex (if provided)
		if [ -n "$regex" ] && [[ ! "$dir" =~ $regex ]]; then
			continue
		fi

		# Check if the directory contains files matching the content regex (if provided)
		if [ -n "$file_regex" ]; then
			  test=$(find "$dir" -maxdepth 1 -type f -printf "%f\n" | grep -iE "$file_regex" | wc -l)
			  if [ $test -lt 1 ]; then
				continue
		   fi
		  fi

		# Add to the list if it passed all filters
		case ${item[*]} in
			*"$dir:"*) ;; # Skip duplicates
			*) item+=( "$dir:cd '$dir'" ) ;;
		esac
	done

	# Display the menu with the found directories
	if [ ${#item[@]} -eq 0 ]; then
		echo "No matching directories found."
	else
		menu "${item[@]}" quit:
	fi
}

gobehind() {
	local current_dir="$PWD"
	local parent_dir

	while true; do
		parent_dir=$(dirname "$current_dir")

		# List directories in the parent directory
		mapfile -t dirs < <(find "$parent_dir" -mindepth 1 -maxdepth 1 -type d | sort)

		# Remove the current directory from the list
		dirs=("${dirs[@]/$current_dir}")

		# Check the number of directories found
		if [ ${#dirs[@]} -eq 0 ]; then
			echo "No directories found beyond the root."
			return
		elif [ ${#dirs[@]} -eq 1 ]; then
			# Only one directory (the current directory), look further back
			current_dir="$parent_dir"
		else
			# Present a menu if there are multiple directories
			local item=()
			for dir in "${dirs[@]}"; do
				item+=( "$dir:cd '$dir'" )
			done

			menu "${item[@]}"
			return
		fi
	done
}


