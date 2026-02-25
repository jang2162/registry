#!/usr/bin/env bash

# Convert templated variables to shell variables
SESSION_NAME='${SESSION_NAME}'

# Function to check if zellij is installed
check_zellij() {
  if ! command -v zellij &> /dev/null; then
    echo "zellij is not installed. Please run the zellij setup script first."
    exit 1
  fi
}

# Function to handle a single session
handle_session() {
  local session_name="$1"

  # Check if session exists by trying to attach with options
  # zellij attach will fail if session doesn't exist
  if zellij list-sessions 2>/dev/null | awk '{print $1}' | grep -q "$session_name"; then
    echo "Session '$session_name' exists, attaching to it..."
    zellij attach "$session_name"
  else
    echo "Session '$session_name' does not exist, creating it..."
    zellij --session "$session_name"
  fi
}

# Main function
main() {
  # Check if zellij is installed
  check_zellij
  handle_session "${SESSION_NAME}"
}

# Run the main function
main