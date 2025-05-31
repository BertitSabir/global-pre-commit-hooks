#!/usr/bin/env bash
set -euo pipefail

# Create required directories
mkdir -p ~/.config/git/hooks
mkdir -p ~/.config/pre-commit

# Copy pre-commit hook to global git hooks directory
cp pre-commit ~/.config/git/hooks/
chmod +x ~/.config/git/hooks/pre-commit

# Copy pre-commit config to global pre-commit config directory
cp pre-commit-config.yaml ~/.config/pre-commit/pre-commit-config.yaml

# Check for Git
if ! command -v git &> /dev/null; then
    echo "Error: Git is required but not found"
    exit 1
fi

# Configure git to use global hooks
git config --global core.hooksPath ~/.config/git/hooks

# Check for Python version >= 3.13
python_version=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if [ "$(printf '%s\n' "3.13" "$python_version" | sort -V | head -n1)" != "3.13" ]; then
    echo "Error: Python version >= 3.13 is required (found $python_version)"
    exit 1
fi

# Check for uv CLI tool
if ! command -v uv &> /dev/null; then
    echo "Error: 'uv' CLI tool is required but not found"
    echo "Please install it from https://github.com/astral-sh/uv"
    exit 1
fi

# Install pre-commit if not already installed
if ! command -v pre-commit &> /dev/null; then
    echo "Installing pre-commit using uv..."
    uv tool install pre-commit
fi

echo "Global pre-commit hooks setup completed successfully!"
