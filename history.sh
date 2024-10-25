LAST_LOGGED_HISTORY_LINE=0

log_command() {
	local current_history_line
	current_history_line=$(history 1 | awk '{print $1}')
	[[ "$current_history_line" == "$LAST_LOGGED_HISTORY_LINE" ]] && return
	LAST_LOGGED_HISTORY_LINE="$current_history_line"

	local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
	local current_dir="$PWD"
	local command=$(history 1 | sed 's/^[ ]*[0-9]\+[ ]*//')

	local current_dir_b64=$(printf '%s' "$current_dir" | base64 -w0)
	local command_b64=$(printf '%s' "$command" | base64 -w0)

	echo "$timestamp,$current_dir_b64,$command_b64" >> "$HOME/.bash_history_extended"
}

# Set the PROMPT_COMMAND to call log_command before the prompt is displayed
PROMPT_COMMAND="log_command"

