#!/usr/bin/env bash
# CrescentShell: sets up matugen config to generate colors for the shell
# Run once on first startup

MATUGEN_CONFIG="$HOME/.config/matugen"
SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$MATUGEN_CONFIG/templates"

# Install colors.json template
cp -f "$SHELL_DIR/assets/matugen/colors.json" "$MATUGEN_CONFIG/templates/colors.json"

# Merge our template into existing config.toml, or create new one
TOML="$MATUGEN_CONFIG/config.toml"
if [ -f "$TOML" ]; then
    # Remove old crescentshell/ambxst template block if exists
    sed -i '/\[templates\.crescentshell\]/,/^$/d' "$TOML"
    sed -i '/\[templates\.ambxst\]/,/^$/d' "$TOML"
    # Append our template
    echo "" >> "$TOML"
    echo "[templates.crescentshell]" >> "$TOML"
    echo "input_path = '~/.config/matugen/templates/colors.json'" >> "$TOML"
    echo "output_path = '~/.local/state/quickshell/user/generated/colors.json'" >> "$TOML"
else
    cp -f "$SHELL_DIR/assets/matugen/config.toml" "$TOML"
fi

# Ensure output directory exists
mkdir -p "$HOME/.local/state/quickshell/user/generated"

echo "[CrescentShell] matugen setup done"
