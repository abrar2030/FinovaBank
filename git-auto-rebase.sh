#!/bin/bash

# =====================================================
# Git Auto Rebase Script
# =====================================================
# This script automates the process of rebasing the current
# branch onto a target branch (e.g., main or develop).
#
# Usage:
#   ./git-auto-rebase.sh [target-branch] [remote-name]
#
# If no target branch is provided, 'main' is used by default.
# =====================================================

# Function to display usage information
usage() {
    echo "Usage: $0 [target-branch] [remote-name]"
    echo ""
    echo "If no target branch is provided, 'main' is used by default."
    echo "If no remote name is provided, 'origin' is used by default."
    exit 1
}

# Function to check if Git is installed
check_git() {
    if ! command -v git &> /dev/null
    then
        echo "Error: Git is not installed. Please install Git before running this script."
        exit 1
    fi
}

# Function to check if inside a Git repository
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree &> /dev/null
    then
        echo "Error: This script must be run inside a Git repository."
        exit 1
    fi
}

# Function to fetch latest changes from remote
fetch_latest() {
    REMOTE=$1
    echo "Fetching latest changes from remote '$REMOTE'..."
    git fetch --all "$REMOTE"
}

# Function to switch to target branch and pull latest
switch_to_target_branch() {
    TARGET_BRANCH=$1
    REMOTE=$2
    echo "Switching to target branch: $TARGET_BRANCH"
    git checkout "$TARGET_BRANCH"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to checkout branch '$TARGET_BRANCH'. Ensure the branch exists."
        exit 1
    fi

    echo "Pulling latest changes for '$TARGET_BRANCH' from '$REMOTE'..."
    git pull "$REMOTE" "$TARGET_BRANCH"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to pull latest changes for '$TARGET_BRANCH'."
        exit 1
    fi
}

# Function to switch back to the original branch
switch_back_to_original_branch() {
    ORIGINAL_BRANCH=$1
    echo "Switching back to original branch: $ORIGINAL_BRANCH"
    git checkout "$ORIGINAL_BRANCH"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to checkout branch '$ORIGINAL_BRANCH'."
        exit 1
    fi
}

# Function to perform rebase
perform_rebase() {
    TARGET_BRANCH=$1
    echo "Rebasing current branch onto '$TARGET_BRANCH'..."
    git rebase "$TARGET_BRANCH"

    if [ $? -ne 0 ]; then
        echo "Rebase encountered conflicts. Please resolve them manually."
        echo "After resolving conflicts, run: git rebase --continue"
        echo "If you need to abort the rebase, run: git rebase --abort"
        exit 1
    fi
}

# Function to push the rebased branch
push_rebased_branch() {
    CURRENT_BRANCH=$(git branch --show-current)
    REMOTE=$1
    echo "Do you want to push the rebased branch '$CURRENT_BRANCH' to remote '$REMOTE'? (y/n)"
    read -r push_confirmation
    if [[ $push_confirmation == "y" ]]; then
        echo "Pushing rebased branch '$CURRENT_BRANCH' to remote '$REMOTE'..."
        git push --force-with-lease "$REMOTE" "$CURRENT_BRANCH"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to push rebased branch '$CURRENT_BRANCH' to remote."
            exit 1
        fi
    else
        echo "Push skipped. You can manually push your changes later using: git push --force-with-lease"
    fi
}

# Main function to handle the rebase process
main() {
    # Check for help flag
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        usage
    fi

    # Set target branch and remote
    TARGET_BRANCH=${1:-main}
    REMOTE=${2:-origin}

    # Perform prerequisite checks
    check_git
    check_git_repo

    # Get the current branch name
    ORIGINAL_BRANCH=$(git branch --show-current)
    echo "Current branch: $ORIGINAL_BRANCH"
    echo "Target branch for rebase: $TARGET_BRANCH"

    # Prevent rebasing onto the same branch
    if [ "$ORIGINAL_BRANCH" == "$TARGET_BRANCH" ]; then
        echo "Error: Rebasing a branch onto itself is not allowed. Please switch to a different branch before running the script."
        exit 1
    fi

    # Ensure working directory is clean
    if ! git diff-index --quiet HEAD -- || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        echo "Error: You have uncommitted or untracked changes. Please commit or stash them before rebasing."
        exit 1
    fi

    # Fetch latest changes
    fetch_latest "$REMOTE"

    # Switch to target branch and pull latest
    switch_to_target_branch "$TARGET_BRANCH" "$REMOTE"

    # Switch back to original branch
    switch_back_to_original_branch "$ORIGINAL_BRANCH"

    # Perform rebase
    perform_rebase "$TARGET_BRANCH"

    # Push the rebased branch
    push_rebased_branch "$REMOTE"
}

# Invoke main with all script arguments
main "$@"
