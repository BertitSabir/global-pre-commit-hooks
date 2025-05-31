# Global Pre-commit Hooks Setup

This repository contains scripts and configuration to set up global pre-commit hooks that will run on all your Git repositories, regardless of whether they have their own pre-commit configuration.

## Special Thanks

Special thanks to [James Warman](https://warman.io/blog/2024/01/global-pre-commit/) for the original blog post and implementation that inspired this setup.

## Introduction

Pre-commit hooks are scripts that run before you commit your code to check for issues like:
- Secrets in your code (using Gitleaks)
- Code formatting issues (using Ruff for Python)
- YAML/JSON syntax errors
- Trailing whitespace and proper end-of-file newlines

This setup implements global pre-commit hooks that will run on every commit across all your repositories, even if they don't have their own pre-commit configuration.

## How It Works

This setup:

1. Configures Git to use a global hooks directory (`~/.config/git/hooks`)
2. Installs a pre-commit hook script in this directory
3. Creates a global pre-commit configuration file at `~/.config/pre-commit/pre-commit-config.yaml`
4. The hook script runs both the global pre-commit configuration and any project-specific configuration

## Prerequisites

- Git (latest version recommended)
- Python >= 3.13
- [uv](https://github.com/astral-sh/uv) installed as a CLI tool (for package management)

## Installation

```bash
# Clone this repository
git clone https://github.com/yourusername/global-pre-commit-hooks.git
cd global-pre-commit-hooks

# Make the installation script executable
chmod +x install.sh

# Run the installation script
./install.sh
```

## Uninstallation

To remove the global pre-commit hooks configuration:

```bash
# Make the uninstallation script executable
chmod +x uninstall.sh

# Run the uninstallation script
./uninstall.sh
```

## Testing the Setup

After installation, you can test the setup by creating a commit in any Git repository:

```bash
# In any Git repository
echo "test" > test.txt
git add test.txt
git commit -m "Test global pre-commit hooks"
```

You should see the pre-commit hooks run and check your code.

## Directory Structure

```
global-pre-commit-hooks/
├── install.sh            # Installation script
├── uninstall.sh          # Uninstallation script
├── pre-commit            # The global pre-commit hook script
├── pre-commit-config.yaml # Global pre-commit configuration
└── README.md             # This documentation
```

## Script Details

### pre-commit (hook script)

This is the script that gets installed in your global git hooks directory. It:
1. Runs the global pre-commit configuration
2. Runs any project-specific pre-commit configuration
3. Runs any existing git pre-commit hook

```bash
#!/usr/bin/env bash

set -euo pipefail

hook_dir="$(cd "$(dirname "$0")" && pwd)"

function run-pre-commit() {
  local configFile="$1"
  shift

  if type pre-commit &>/dev/null; then
    pre-commit hook-impl --hook-type=pre-commit --hook-dir="$hook_dir" --config="$configFile" -- "$@"
  else
    echo 'pre-commit not found.' 1>&2
    exit 1
  fi
}

if [ -f "$HOME/.config/pre-commit/pre-commit-config.yaml" ]; then
  run-pre-commit "$HOME/.config/pre-commit/pre-commit-config.yaml" "$@"
fi

if [ -f .pre-commit-config.yaml ]; then
  run-pre-commit .pre-commit-config.yaml "$@"
fi

if [ -e ./.git/hooks/pre-commit ]; then
  ./.git/hooks/pre-commit "$@"
fi
```

### pre-commit-config.yaml

This is the global pre-commit configuration file. It defines the hooks that will run on every commit:

```yaml
repos:
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v4.5.0
  hooks:
    - id: check-yaml
    - id: check-json
    - id: trailing-whitespace
    - id: end-of-file-fixer

- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: v0.2.0
  hooks:
    - id: ruff
      args: [--fix, --exit-non-zero-on-fix]
    - id: ruff-format

- repo: https://github.com/gitleaks/gitleaks
  rev: v8.18.1
  hooks:
    - id: gitleaks
```

### install.sh

This script sets up the global pre-commit hooks:

```bash
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
```

### uninstall.sh

This script removes the global pre-commit hooks configuration:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Remove global git hooks configuration
git config --global --unset core.hooksPath

echo "Global pre-commit hooks configuration removed."
echo "Note: The config files in ~/.config/git/hooks and ~/.config/pre-commit are still present."
```

## Customizing the Configuration

You can customize the global pre-commit hooks by editing:

```bash
~/.config/pre-commit/pre-commit-config.yaml
```

For more information on available hooks, visit:
- [Pre-commit hooks](https://github.com/pre-commit/pre-commit-hooks)
- [Ruff pre-commit hooks](https://github.com/astral-sh/ruff-pre-commit)
- [Gitleaks](https://github.com/gitleaks/gitleaks)

## Troubleshooting

### Temporarily bypassing hooks

To temporarily bypass all pre-commit hooks for a commit:

```bash
git commit -m "Your message" --no-verify
```

### Hook running twice

If you've run `pre-commit install` in a repository, the hook might run twice. This is expected and won't cause any issues.

### Permission denied

If you encounter permission issues, make sure the hook script is executable:

```bash
chmod +x ~/.config/git/hooks/pre-commit
```

### Testing hooks without committing

You can test the pre-commit hooks without creating a commit:

```bash
git hook run pre-commit
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
