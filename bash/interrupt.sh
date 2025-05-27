#!/bin/bash

handle_interrupt() {
    echo "Interrupt received. Cleaning up..."
    # Add cleanup actions here, e.g., deleting temp files, closing connections
    exit 1 # Exit with an error code to indicate interruption
}
# Set the trap for SIGINT (Ctrl+C)
trap handle_interrupt SIGINT

# Your main script logic here
echo "Script started. Press Ctrl+C to interrupt."

while true; do
  echo "Running..."
  sleep 1
done

echo "This line will not be reached if the script is interrupted."
