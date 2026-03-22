#!/usr/bin/env bash
set -Eeuo pipefail

# ==================================================

# Moonveil Installer

# Arch Linux Only

# ==================================================

RESET=”\e[0m”
BOLD=”\e[1m”
PURPLE=”\e[38;5;141m”
CYAN=”\e[38;5;51m”
GREEN=”\e[38;5;82m”
RED=”\e[38;5;196m”

info() { echo -e “${CYAN}➜ $1${RESET}”; }
success() { echo -e “${GREEN}✔ $1${RESET}”; }
error() { echo -e “${RED}✘ $1${RESET}”; }

clear
echo -e “${PURPLE}${BOLD}”
cat << “EOF”
__  ___                            _ __
/  |/  /___  ____  ____ _   _____  (*) /
/ /|*/ / __ / __ / __ \ | / / _ / / /
/ /  / / /*/ / /*/ / / / / |/ /  **/ / /  
/*/  /*/_***/_***/*/ /*/|***/_**/*/_/  
Moonveil Installer
EOF
echo -e “${RESET}”

# –––––––––––––––––––––––––

# Safety

# –––––––––––––––––––––––––

if [ “$(id -u)” -eq 0 ]; then
error “Do NOT run as root.”
exit 1
fi

if ! command -v pacman &>/dev/null; then
error “Arch Linux required.”
exit 1
fi

# –––––––––––––––––––––––––

# Update System

# –––––––––––––––––––––––––

info “Updating system…”
sudo pacman -Syu –noconfirm

# –––––––––––––––––––––––––

# Core Dependencies

# –––––––––––––––––––––––––

info “Installing core dependencies…”
sudo pacman -S –needed –noconfirm   
base-devel git curl wget unzip zsh   
networkmanager network-manager-applet nm-connection-editor   
power-profiles-daemon upower   
fastfetch

sudo systemctl enable NetworkManager
sudo systemctl enable power-profiles-daemon

# –––––––––––––––––––––––––

# Choose AUR Helper

# –––––––––––––––––––––––––

echo
echo “Select AUR helper:”
echo “1) yay”
echo “2) paru”
echo
read -rp “Enter choice [1-2]: “ aur_choice

case “$aur_choice” in
2)
AUR=“paru”
AUR_REPO=“https://aur.archlinux.org/paru-bin.git”
;;
*)
AUR=“yay”
AUR_REPO=“https://aur.archlinux.org/yay-bin.git”
;;
esac

if ! command -v “$AUR” &>/dev/null; then
info “Installing $AUR…”
tmpdir=$(mktemp -d)
git clone “$AUR_REPO” “$tmpdir/$AUR”
(cd “$tmpdir/$AUR” && makepkg -si –noconfirm)
rm -rf “$tmpdir”
fi

# –––––––––––––––––––––––––

# Install Moonveil Stack

# –––––––––––––––––––––––––

info “Installing Moonveil packages…”

“$AUR” -S –needed –noconfirm   
hyprland xdg-desktop-portal-hyprland   
quickshell-git   
grim slurp wl-clipboard hyprpicker   
nautilus pavucontrol   
libnotify gnome-bluetooth-3.0 vte3   
imagemagick cava kitty   
matugen adw-gtk-theme lxappearance bibata-cursor-theme   
ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk   
noto-fonts-emoji otf-geist-mono   
ttf-geist-mono-nerd otf-geist-mono-nerd otf-codenewroman-nerd   
ttf-libre-barcode   
eza

# –––––––––––––––––––––––––

# Clone Repositories

# –––––––––––––––––––––––––

MOONVEIL_DIR=”$HOME/moonveil”
WALL_DIR=”$HOME/wallpaper”

info “Cloning Moonveil…”
[ -d “$MOONVEIL_DIR/.git” ] && git -C “$MOONVEIL_DIR” pull ||   
git clone –depth=1 https://github.com/notcandy001/moonveil.git “$MOONVEIL_DIR”

info “Cloning Wallpapers…”
[ -d “$WALL_DIR/.git” ] && git -C “$WALL_DIR” pull ||   
git clone –depth=1 https://github.com/notcandy001/my-wal.git “$WALL_DIR”

# –––––––––––––––––––––––––

# Backup

# –––––––––––––––––––––––––

info “Creating backup…”
BACKUP_DIR=”$HOME/.moonveil-backup-$(date +%Y%m%d-%H%M%S)”
mkdir -p “$BACKUP_DIR”

cp -r “$HOME/.config” “$BACKUP_DIR/” 2>/dev/null || true
cp -r “$HOME/.local” “$BACKUP_DIR/” 2>/dev/null || true
cp -r “$HOME/.zshrc” “$BACKUP_DIR/” 2>/dev/null || true
cp -r “$HOME/.p10k.zsh” “$BACKUP_DIR/” 2>/dev/null || true

success “Backup saved to $BACKUP_DIR”

# –––––––––––––––––––––––––

# Deploy Configs

# –––––––––––––––––––––––––

info “Deploying configs…”

mkdir -p “$HOME/.config”
mkdir -p “$HOME/.local”

cp -r “$MOONVEIL_DIR/dots/.config/”* “$HOME/.config/”
cp -r “$MOONVEIL_DIR/dots/.local/”* “$HOME/.local/”

success “Configs deployed.”

# –––––––––––––––––––––––––

# Shell Configuration

# –––––––––––––––––––––––––

info “Installing shell configuration…”

SHELL_DIR=”$MOONVEIL_DIR/dots/shell”

if [ -d “$SHELL_DIR” ]; then
[ -f “$SHELL_DIR/zshrc” ] && cp “$SHELL_DIR/zshrc” “$HOME/.zshrc”
[ -f “$SHELL_DIR/p10k.zsh” ] && cp “$SHELL_DIR/p10k.zsh” “$HOME/.p10k.zsh”
success “Shell configuration installed.”
fi

# –––––––––––––––––––––––––

# Oh My Zsh

# –––––––––––––––––––––––––

info “Installing Oh My Zsh…”

if [ ! -d “$HOME/.oh-my-zsh” ]; then
RUNZSH=no CHSH=no sh -c   
“$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)”
fi

# –––––––––––––––––––––––––

# Powerlevel10k

# –––––––––––––––––––––––––

info “Installing Powerlevel10k…”

git clone –depth=1 https://gitee.com/romkatv/powerlevel10k.git   
“${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k” 2>/dev/null || true

# –––––––––––––––––––––––––

# Set ZSH as Default Shell

# –––––––––––––––––––––––––

if [ “$SHELL” != “$(which zsh)” ]; then
chsh -s “$(which zsh)”
fi

# –––––––––––––––––––––––––

# Font Cache

# –––––––––––––––––––––––––

info “Refreshing font cache…”
fc-cache -fv

# –––––––––––––––––––––––––

# Enable CrescentShell autostart

# –––––––––––––––––––––––––

info “Setting up CrescentShell autostart…”
HYPR_AUTOSTART=”$HOME/.config/hypr/modules/autostart.conf”
if [ -f “$HYPR_AUTOSTART” ]; then
if ! grep -q “crescentshell” “$HYPR_AUTOSTART”; then
echo “exec-once = qs -p ~/.config/quickshell/CrescentShell/shell.qml” >> “$HYPR_AUTOSTART”
fi
fi

success “CrescentShell autostart configured.”

# –––––––––––––––––––––––––

# Done

# –––––––––––––––––––––––––

sleep 1
clear

echo -e “${PURPLE}${BOLD}”
cat << “EOF”
__  ___                            _ __
/  |/  /___  ____  ____ _   _____  (*) /
/ /|*/ / __ / __ / __ \ | / / _ / / /
/ /  / / /*/ / /*/ / / / / |/ /  **/ / /  
/*/  /*/_***/_***/*/ /*/|***/_**/*/_/

```
     Moonveil Installation Complete!
```

Moonveil directory : ~/moonveil
Wallpapers         : ~/wallpaper
Configs deployed   : ~/.config
Shell config       : ~/.zshrc

CrescentShell      : ~/.config/quickshell/CrescentShell
Start shell        : qs -p ~/.config/quickshell/CrescentShell/shell.qml

Lock screen        : Super + L
Control center     : Super + A
Notifications      : Super + N
App launcher       : Super + R
Overview           : Super + Tab
Settings           : Super + I

EOF
echo -e “${RESET}”
