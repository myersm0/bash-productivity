# Initialize a variable to keep track of the last logged history line
LAST_LOGGED_HISTORY_LINE=0

# Function to log commands with timestamp and current directory using Base64 encoding
log_command() {
  # Get the current history line number
  local current_history_line
  current_history_line=$(history 1 | awk '{print $1}')

  # Check if we have already logged this command
  if [[ "$current_history_line" == "$LAST_LOGGED_HISTORY_LINE" ]]; then
    return
  fi

  # Update the last logged history line
  LAST_LOGGED_HISTORY_LINE="$current_history_line"

  # Get the timestamp
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  # Get the current directory
  local current_dir="$PWD"

  # Get the last command from history
  local command
  command=$(history 1 | sed 's/^[ ]*[0-9]\+[ ]*//')

  # Base64 encode the current directory and command
  local current_dir_b64
  current_dir_b64=$(printf '%s' "$current_dir" | base64)
  local command_b64
  command_b64=$(printf '%s' "$command" | base64)

  # Append to the custom history file
  echo "$timestamp,$current_dir_b64,$command_b64" >> "$HOME/.bash_history_extended"
}

# Set the PROMPT_COMMAND to call log_command before the prompt is displayed
PROMPT_COMMAND="log_command"

