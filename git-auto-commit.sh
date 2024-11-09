#!/bin/bash

# =====================================================
# Git Auto Commit Script
# =====================================================
# This script automates the process of committing and
# pushing changes to a GitHub repository.
#
# Usage:
#   ./git-auto-commit.sh "Your commit message"
#   ./git-auto-commit.sh          # Generates a default commit message
# =====================================================

# Function to display usage information
usage() {
    echo "Usage: $0 [commit message]"
    echo ""
    echo "If no commit message is provided, a default message with the current date and time will be used."
    exit 1
}

# Check if Git is installed
if ! command -v git &> /dev/null
then
    echo "Error: Git is not installed. Please install Git before running this script."
    exit 1
fi

# Check if inside a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null
then
    echo "Error: This script must be run inside a Git repository."
    exit 1
fi

# Fetch the commit message from the first argument, if provided
if [ $# -ge 1 ]; then
    COMMIT_MESSAGE="$*"
else
    # Generate a default commit message with current date and time
    COMMIT_MESSAGE="Auto-commit on $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Check for any changes
if git diff-index --quiet HEAD --; then
    echo "No changes detected. Nothing to commit."
    exit 0
else
    echo "Changes detected. Proceeding with commit."
fi

# Add all changes to staging
git add .

# Commit the changes with the commit message
git commit -m "$COMMIT_MESSAGE"

# Pull remote changes to avoid conflicts
echo "Pulling the latest changes from the remote repository..."
if ! git pull --rebase; then
    echo "Error: Failed to pull the latest changes from the remote repository."
    exit 1
fi

# Push the commit to the current branch's upstream
echo "Pushing changes to the remote repository..."
if git push; then
    echo "Changes have been pushed successfully."
else
    echo "Error: Failed to push changes."
    exit 1
fi