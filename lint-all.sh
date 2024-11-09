#!/bin/bash

# Linting and Fixing Script for Java, YAML, and JavaScript Files

set -e  # Exit immediately if a command exits with a non-zero status

echo "----------------------------------------"
echo "Starting linting and fixing process..."
echo "----------------------------------------"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install missing tools via Homebrew
install_if_missing() {
  if ! command_exists "$1"; then
    echo "Installing $1 via Homebrew..."
    brew install "$1" || { echo "Failed to install $1. Please install it manually."; exit 1; }
  else
    echo "$1 is already installed."
  fi
}

# Check for Homebrew and install if missing
if ! command_exists brew; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  echo "Homebrew is already installed."
fi

# Install required tools if they are missing
install_if_missing yq
install_if_missing dos2unix
install_if_missing yamllint
install_if_missing eslint

# Verify yq installation
echo "Verifying yq installation..."
yq_version=$(yq --version 2>/dev/null)
if [[ $yq_version == yq* ]]; then
  echo "yq is installed: $yq_version"
else
  echo "yq is not properly installed. Please reinstall yq."
  exit 1
fi

# 1. Spotless for Java files
echo "----------------------------------------"
echo "Running Spotless for Java files..."
find backend -name "pom.xml" -execdir mvn spotless:apply \;
echo "Spotless applied to all Java projects."
echo "----------------------------------------"

# 2. Fix YAML Files (automated fixes for common issues)
fix_yaml_files() {
  echo "Applying automated fixes to YAML files..."
  echo "----------------------------------------"

  # Define directories to process YAML files
  yaml_directories=("." "k8s")

  for dir in "${yaml_directories[@]}"; do
    echo "Processing YAML files in directory: $dir"
    # Find all YAML files in the directory and subdirectories, excluding .bak and .tmp files
    yaml_files=$(find "$dir" -type f \( -name '*.yaml' -o -name '*.yml' \) ! -name '*.bak' ! -name '*.tmp')

    for file in $yaml_files; do
      echo "Processing $file"

      # Check if file exists
      if [ ! -f "$file" ]; then
        echo "Warning: $file does not exist. Skipping."
        echo "----------------------------------------"
        continue
      fi

      # Create a backup before making changes
      cp "$file" "$file.bak"

      # a. Remove BOM if present
      if head -c 3 "$file" | grep -q $'\xef\xbb\xbf'; then
        echo "Removing BOM from $file"
        tail -c +4 "$file" > "$file.tmp" && mv "$file.tmp" "$file"
      else
        echo "No BOM found in $file"
      fi

      # b. Ensure '---' is on the first line with no leading spaces or characters
      first_line=$(head -n 1 "$file")
      if [[ "$first_line" =~ ^[[:space:]]*--- ]]; then
        echo "Cleaning up '---' in $file"
        sed -i '1s/^[[:space:]]*---$/---/' "$file"
      else
        echo "Adding document start '---' to $file"
        sed -i '1i---' "$file"
      fi

      # c. Remove any '---' lines after the first line
      sed -i '2,${/^---/d}' "$file"

      # d. Remove leading spaces from the second line to fix indentation issues
      #    This assumes that the second line should start at column 1
      second_line=$(sed -n '2p' "$file")
      if [[ "$second_line" =~ ^[[:space:]]+ ]]; then
        echo "Removing leading spaces from the second line of $file"
        sed -i '2s/^[[:space:]]*//' "$file"
      else
        echo "No leading spaces found on the second line of $file"
      fi

      # e. Convert Windows-style line endings to Unix
      dos2unix "$file" >/dev/null 2>&1
      echo "Converted line endings to Unix style for $file"

      # f. Ensure newline at end of file
      if [ -n "$(tail -c1 "$file")" ] && [ "$(tail -c1 "$file")" != $'\n' ]; then
        echo "Adding newline at end of $file"
        echo "" >> "$file"
      else
        echo "No need to add newline at end of $file"
      fi

      # g. Reformat YAML using yq to fix indentation and syntax (also removes comments)
      echo "Reformatting $file with yq (this will remove all comments)"
      if ! yq eval -i '.' "$file"; then
        echo "Error: yq failed to process $file"
        echo "Skipping further processing for $file"
        echo "----------------------------------------"
        continue
      fi

      # h. Remove any remaining comments using sed
      echo "Removing all comments from $file"
      # Remove full-line comments
      sed -i '/^\s*#/d' "$file"
      # Remove inline comments
      sed -i 's/#.*$//' "$file"

      # i. Handle line length (notify if lines exceed 80 characters)
      long_lines=$(awk 'length($0) > 80' "$file")
      if [ -n "$long_lines" ]; then
        echo "Warning: The following lines in $file exceed 80 characters:"
        awk 'length($0) > 80' "$file" | nl
      else
        echo "No lines exceed 80 characters in $file"
      fi

      echo "Finished processing $file"
      echo "----------------------------------------"
    done
  done
}

fix_yaml_files

# 3. Run yamllint on YAML files to identify remaining issues
echo "Running yamllint for YAML files..."
yamllint ./**/*.yaml || {
  echo "YAML linting completed with some issues. Please review the above warnings/errors."
}
echo "yamllint completed."
echo "----------------------------------------"

# 4. ESLint for JavaScript files
echo "Running ESLint for JavaScript files..."
if [ -d "frontend/fintech-payment-frontend" ]; then
  (
    cd frontend/fintech-payment-frontend
    if [ -f package.json ]; then
      echo "Found package.json. Installing npm dependencies..."
      npm install
    fi
    echo "Running ESLint with --fix..."
    npx eslint '**/*.js' --fix || {
      echo "ESLint encountered some issues. Please review the above errors."
    }
    echo "ESLint completed."
  )
else
  echo "No JavaScript frontend directory found. Skipping ESLint."
fi

# 5. Cleanup Unnecessary Backup and Temporary Files
cleanup_backup_files() {
  echo "Cleaning up unnecessary backup (.bak) and temporary (.tmp) files..."
  echo "----------------------------------------"

  # Define directories to clean up
  cleanup_directories=("." "k8s")

  for dir in "${cleanup_directories[@]}"; do
    echo "Cleaning up in directory: $dir"
    # Find and delete all .bak and .tmp files
    find "$dir" -type f \( -name '*.bak' -o -name '*.tmp' \) -exec rm -f {} +
    echo "Removed .bak and .tmp files in $dir"
    echo "----------------------------------------"
  done
}

cleanup_backup_files

echo "----------------------------------------"
echo "Linting and fixing process completed!"
echo "----------------------------------------"
