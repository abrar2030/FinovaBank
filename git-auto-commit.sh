#!/bin/bash

# =====================================================
# Git Auto Commit Script
# =====================================================
# This script automates the process of committing and
# pushing changes to a GitHub repository.
# Always uses a fixed commit message for consistency.
# =====================================================

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed. Please install Git before running this script."
    exit 1
fi

# Check if inside a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: This script must be run inside a Git repository."
    exit 1
fi

# Fixed commit message
COMMIT_MESSAGE="Implement updates for better performance"

# =====================================================
# Check for any changes, including untracked files
# =====================================================
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes detected. Nothing to commit."
    exit 0
else
    echo "Changes detected. Proceeding with commit."
fi

# Add all changes (tracked + untracked) to staging
git add --all

# Commit the changes with the fixed commit message
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
