#!/bin/bash

set -e

THEME_NAME="Nicos-Loader"
THEME_DIR="/boot/grub/themes/$THEME_NAME"
GRUB_CONFIG="/etc/default/grub"
GRUB_THEME_LINE="GRUB_THEME=\"$THEME_DIR/theme.txt\""

function install_theme() {
    echo "📦 Installing GRUB theme '$THEME_NAME'..."

    # Check if the theme directory already exists
    if [ -d "$THEME_DIR" ]; then
        echo "⚠️ Theme already exists at $THEME_DIR. Do you want to replace it? (y/N)"
        read -r confirm
        if [[ ! "$confirm" =~ ^[yY]$ ]]; then
            echo "❌ Installation cancelled."
            exit 1
        fi
        sudo rm -rf "$THEME_DIR"
    fi

    # Copy current directory (assumed to be the theme folder) to target
    echo "📁 Copying theme files to $THEME_DIR..."
    sudo cp -r "$(pwd)/$THEME_NAME" "$THEME_DIR"

    # Add or replace GRUB_THEME line
    if grep -q "^GRUB_THEME=" "$GRUB_CONFIG"; then
        echo "🔁 Replacing existing GRUB_THEME line in $GRUB_CONFIG..."
        sudo sed -i "s|^GRUB_THEME=.*|$GRUB_THEME_LINE|" "$GRUB_CONFIG"
    else
        echo "➕ Appending GRUB_THEME to $GRUB_CONFIG..."
        echo "$GRUB_THEME_LINE" | sudo tee -a "$GRUB_CONFIG" > /dev/null
    fi

    update_grub
    echo "✅ Theme '$THEME_NAME' installed successfully!"
}

function uninstall_theme() {
    echo "🗑️ Uninstalling theme '$THEME_NAME'..."

    # Remove the theme directory
    if [ -d "$THEME_DIR" ]; then
        sudo rm -rf "$THEME_DIR"
        echo "🧹 Removed $THEME_DIR"
    else
        echo "⚠️ Theme directory not found."
    fi

    # Remove GRUB_THEME line only if it matches this theme
    if grep -q "^GRUB_THEME=\"$THEME_DIR/theme.txt\"" "$GRUB_CONFIG"; then
        sudo sed -i "/^GRUB_THEME=\"$THEME_DIR\\/theme.txt\"/d" "$GRUB_CONFIG"
        echo "🧽 Removed GRUB_THEME line from $GRUB_CONFIG"
    fi

    update_grub
    echo "✅ Theme '$THEME_NAME' uninstalled successfully!"
}

function update_grub() {
    echo "🔄 Updating GRUB configuration..."
    if command -v update-grub &> /dev/null; then
        sudo update-grub
    elif command -v grub-mkconfig &> /dev/null; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    else
        echo "❌ GRUB update command not found!"
        exit 1
    fi
}

case "$1" in
    --install)
        install_theme
        ;;
    --uninstall)
        uninstall_theme
        ;;
    *)
        echo "Usage: $0 --install | --uninstall"
        exit 1
        ;;
esac
