#!/usr/bin/env sh
# install-skill.sh — Install a general-purpose agent skill from the catalog either locally or centrally.
#
# Usage:
#   sh scripts/install-skill.sh [options]
#
# Options:
#   --skill <name>   Name of the skill to install (e.g., codebase-health)
#   --target <type>  Specify "local" or "central"
#   --path <path>    Custom destination path
#   --copy           Force copying files instead of creating symlinks
#
# The script is interactive if run without parameters.

set -e

# Compute repository paths
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
CATALOG_PATH="$REPO_ROOT/catalog/skills"
COPY_MODE=false
SKILL_NAME=""
TARGET=""
CUSTOM_PATH=""

# ── Argument parsing ────────────────────────────────────────────────────────

while [ $# -gt 0 ]; do
  case "$1" in
    --skill)
      SKILL_NAME="$2"
      shift 2
      ;;
    --target)
      TARGET="$2"
      shift 2
      ;;
    --path)
      CUSTOM_PATH="$2"
      shift 2
      ;;
    --copy)
      COPY_MODE=true
      shift
      ;;
    -h|--help)
      echo "Usage: sh scripts/install-skill.sh [options]"
      echo "Options:"
      echo "  --skill <name>   The folder name of the skill to install"
      echo "  --target <type>  Target: 'local' (inside a repo) or 'central' (centralized config)"
      echo "  --path <path>    Custom installation path"
      echo "  --copy           Copy files instead of creating symlinks"
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      exit 1
      ;;
  esac
done

echo "============================================="
echo "      AGENT SKILL INSTALLATION TOOL          "
echo "============================================="

# 1. Verify catalog exists
if [ ! -d "$CATALOG_PATH" ]; then
  echo "error: catalog path not found at $CATALOG_PATH" >&2
  exit 1
fi

# 2. Get list of available skills
AVAILABLE_SKILLS=$(find "$CATALOG_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

if [ -z "$AVAILABLE_SKILLS" ]; then
  echo "error: no skills found in catalog at $CATALOG_PATH" >&2
  exit 1
fi

# 3. Choose skill if omitted
if [ -z "$SKILL_NAME" ]; then
  echo ""
  echo "Available Skills in Catalog:"
  i=1
  # Create a temporary array-like structure in sh
  for skill in $AVAILABLE_SKILLS; do
    echo "  [$i] $skill"
    i=$((i+1))
  done
  
  max=$((i-1))
  selection=""
  while [ -z "$selection" ]; do
    printf "\nSelect a skill number (1-$max): "
    read -r choice
    if [ "$choice" -ge 1 ] && [ "$choice" -le "$max" ] 2>/dev/null; then
      selection="$choice"
    else
      echo "Invalid choice. Please select a number between 1 and $max."
    fi
  done
  
  # Retrieve the chosen skill name
  curr=1
  for skill in $AVAILABLE_SKILLS; do
    if [ "$curr" -eq "$selection" ]; then
      SKILL_NAME="$skill"
      break
    fi
    curr=$((curr+1))
  done
else
  # Verify selected skill exists
  if [ ! -d "$CATALOG_PATH/$SKILL_NAME" ]; then
    echo "error: skill '$SKILL_NAME' not found in catalog." >&2
    echo "Available: $AVAILABLE_SKILLS" >&2
    exit 1
  fi
fi

# 4. Choose target if omitted
if [ -z "$TARGET" ]; then
  echo ""
  echo "Where would you like to install the skill?"
  echo "  [1] Local Repository (install to current directory's .codex, .claude, .gemini, and .github surfaces)"
  echo "  [2] Central User Profile (install centrally for all projects in your user configuration)"
  
  choice=""
  while [ -z "$choice" ]; do
    printf "\nSelect installation target (1 or 2): "
    read -r t_choice
    if [ "$t_choice" = "1" ] || [ "$t_choice" = "2" ]; then
      choice="$t_choice"
    else
      echo "Invalid selection. Please enter 1 or 2."
    fi
  done
  
  if [ "$choice" = "1" ]; then
    TARGET="local"
  else
    TARGET="central"
  fi
fi

SOURCE_SKILL_DIR="$CATALOG_PATH/$SKILL_NAME"
echo ""
echo "Selected Skill: $SKILL_NAME"
echo "Selected Target: $TARGET"

# Helper function to install skill files
install_skill_files() {
  src="$1"
  dest="$2"
  
  # Remove existing destination if it exists (idempotent overwrite)
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    rm -rf "$dest"
  fi
  
  dest_parent=$(dirname "$dest")
  mkdir -p "$dest_parent"
  
  if [ "$COPY_MODE" = false ]; then
    # Create symlink
    echo "  link  $dest  ->  $src"
    ln -s "$src" "$dest" || {
      echo "  [!] Symlinking failed. Falling back to copy mode..."
      COPY_MODE=true
    }
  fi
  
  if [ "$COPY_MODE" = true ]; then
    echo "  copy  $dest  <-  $src"
    cp -R "$src" "$dest"
  fi
}

# 5. Perform Installation
if [ "$TARGET" = "local" ]; then
  if [ -z "$CUSTOM_PATH" ]; then
    CUSTOM_PATH="."
  fi
  
  DEST_ROOT=$(cd "$CUSTOM_PATH" && pwd)
  echo "Installing to local repository: $DEST_ROOT"
  
  # Wire to standard agent surfaces
  install_skill_files "$SOURCE_SKILL_DIR" "$DEST_ROOT/.codex/skills/$SKILL_NAME"
  install_skill_files "$SOURCE_SKILL_DIR" "$DEST_ROOT/.claude/skills/$SKILL_NAME"
  install_skill_files "$SOURCE_SKILL_DIR" "$DEST_ROOT/.gemini/skills/$SKILL_NAME"
  install_skill_files "$SOURCE_SKILL_DIR" "$DEST_ROOT/.github/skills/$SKILL_NAME"
  
else
  # Central/Global installation
  DEST_PATHS=""
  if [ -z "$CUSTOM_PATH" ]; then
    # Targets for central users:
    DEST_PATHS="$HOME/.gemini/config/skills/$SKILL_NAME
$HOME/.gemini/antigravity-ide/skills/$SKILL_NAME
$HOME/.claude/skills/$SKILL_NAME
$HOME/.codex/skills/$SKILL_NAME"
  else
    DEST_PATHS="$CUSTOM_PATH/$SKILL_NAME"
  fi
  
  echo "$DEST_PATHS" | while read -r dest; do
    if [ -n "$dest" ]; then
      install_skill_files "$SOURCE_SKILL_DIR" "$dest"
    fi
  done
fi

echo ""
echo "Installation Completed Successfully! ✓"
echo "============================================="
