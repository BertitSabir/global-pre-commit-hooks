#!/usr/bin/env bash
set -euo pipefail

# Remove global git hooks configuration
git config --global --unset core.hooksPath

echo "Global pre-commit hooks configuration removed."
echo "Note: The config files in ~/.config/git/hooks and ~/.config/pre-commit are still present."
