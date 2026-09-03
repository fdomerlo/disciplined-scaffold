#!/usr/bin/env bash
# scripts/install.sh — Installer for disciplined-scaffold across AI agent platforms
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
SKILL_NAME="$(basename "$SKILL_DIR")"

MODE="symlink"
ACTION="install"
TARGET_PROJECT=""

print_help() {
  cat <<EOF
Usage: ./scripts/install.sh [OPTIONS]

Installs $SKILL_NAME globally across AI coding tools or into a specific project.

Options:
  -g, --global           Install globally for Antigravity, Claude Code, and OpenCode (default)
  -p, --project <dir>    Install into a specific project workspace
  -c, --copy             Copy files instead of creating symbolic links
  -u, --uninstall        Remove installed symlinks/directories
  -h, --help             Show this help message

Global discovery paths configured automatically:
  - Antigravity (Desktop, IDE, CLI): ~/.gemini/config/skills/$SKILL_NAME
  - Claude Code CLI:                ~/.claude/skills/$SKILL_NAME
  - OpenCode / Generic Agents:      ~/.agents/skills/$SKILL_NAME

Examples:
  ./scripts/install.sh                     # Auto-link globally for all tools (Recommended)
  ./scripts/install.sh --copy              # Copy globally instead of symlinking
  ./scripts/install.sh -p ~/Projects/my-app # Install into a specific project repository
  ./scripts/install.sh --uninstall         # Remove global links
EOF
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--global)
      TARGET_PROJECT=""
      shift
      ;;
    -p|--project)
      TARGET_PROJECT="$2"
      shift 2
      ;;
    -c|--copy)
      MODE="copy"
      shift
      ;;
    -u|--uninstall)
      ACTION="uninstall"
      shift
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Error: Unknown option '$1'" >&2
      print_help
      exit 1
      ;;
  esac
done

install_to() {
  local parent_dir="$1"
  local label="$2"
  local dest="$parent_dir/$SKILL_NAME"

  if [[ "$ACTION" == "uninstall" ]]; then
    if [[ -L "$dest" || -d "$dest" ]]; then
      rm -rf "$dest"
      echo "  ✔ Removed $label: $dest"
    else
      echo "  - $label not present: $dest"
    fi
    return
  fi

  mkdir -p "$parent_dir"

  # Clean up existing target to avoid nested directory symlinks
  if [[ -L "$dest" || -d "$dest" ]]; then
    rm -rf "$dest"
  fi

  if [[ "$MODE" == "symlink" ]]; then
    ln -s "$SKILL_DIR" "$dest"
    echo "  ✔ [Symlink] $label -> $dest"
  else
    # Exclude git repository metadata when copying
    mkdir -p "$dest"
    tar --exclude='.git' -cf - -C "$SKILL_DIR" . | tar -xf - -C "$dest"
    echo "  ✔ [Copied]  $label -> $dest"
  fi
}

echo "=== $SKILL_NAME installer ==="
echo "Source: $SKILL_DIR"

if [[ -n "$TARGET_PROJECT" ]]; then
  TARGET_PROJECT="$(cd "$TARGET_PROJECT" 2>/dev/null && pwd || echo "$TARGET_PROJECT")"
  if [[ ! -d "$TARGET_PROJECT" ]]; then
    echo "Error: Project directory '$TARGET_PROJECT' does not exist." >&2
    exit 1
  fi
  echo "Target: Project workspace at $TARGET_PROJECT"
  echo ""
  install_to "$TARGET_PROJECT/.agents/skills" "Project Antigravity / .agents"
  install_to "$TARGET_PROJECT/.claude/skills" "Project Claude Code"
else
  echo "Target: Global user configuration (all projects on this machine)"
  echo ""
  install_to "$HOME/.gemini/config/skills" "Antigravity (Desktop, IDE, CLI)"
  install_to "$HOME/.claude/skills"        "Claude Code CLI"
  install_to "$HOME/.agents/skills"        "OpenCode / Generic Agents"
fi

echo ""
if [[ "$ACTION" == "install" ]]; then
  echo "Installation complete!"
  if [[ "$MODE" == "symlink" ]]; then
    echo "Tip: Because symlinks were used, any 'git pull' or local update to this repository will automatically take effect across all tools."
  fi
else
  echo "Uninstallation complete."
fi

