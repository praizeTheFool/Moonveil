#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================

# Moonveil Installer — whiptail TUI

# Arch Linux Only

# ============================================================

RESET="\e[0m"
BOLD="\e[1m"
PURPLE="\e[38;5;141m"
CYAN="\e[38;5;51m"
GREEN="\e[38;5;82m"
RED="\e[38;5;196m"
YELLOW="\e[38;5;226m"
DIM="\e[2m"

info()    { echo -e "  ${CYAN}${BOLD}➜${RESET}  $1"; }
success() { echo -e "  ${GREEN}${BOLD}✔${RESET}  $1"; }
error()   { echo -e "  ${RED}${BOLD}✘${RESET}  $1"; }
warn()    { echo -e "  ${YELLOW}${BOLD}!${RESET}  $1"; }

# Whiptail dimensions

H=20
W=70

# ============================================================

# Banner

# ============================================================

clear
echo -e "${PURPLE}${BOLD}"
cat << "EOF"

███╗   ███╗ ██████╗  ██████╗ ███╗   ██╗██╗   ██╗███████╗██╗██╗
████╗ ████║██╔═══██╗██╔═══██╗████╗  ██║██║   ██║██╔════╝██║██║
██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║██║   ██║█████╗  ██║██║
██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║╚██╗ ██╔╝██╔══╝  ██║██║
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║ ╚████╔╝ ███████╗██║███████╗
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝  ╚═══╝  ╚══════╝╚═╝╚══════╝

```
      A quiet, moonlit Hyprland environment.
```

EOF
echo -e "${RESET}"
echo -e "${DIM}  https://github.com/notcandy001/moonveil${RESET}\n"
sleep 1

# ============================================================

# Safety Checks

# ============================================================

if [ "$(id -u)" -eq 0 ]; then
whiptail --title "Moonveil Installer" --msgbox "Do NOT run as root.\nRun as your normal user." $H $W
exit 1
fi

if ! command -v pacman &>/dev/null; then
whiptail --title "Moonveil Installer" --msgbox "This installer requires Arch Linux." $H $W
exit 1
fi

if ! command -v whiptail &>/dev/null; then
echo "Installing whiptail…"
sudo pacman -S --needed --noconfirm libnewt
fi

if ! ping -c 1 archlinux.org &>/dev/null 2>&1; then
whiptail --title "Moonveil Installer" --msgbox "No internet connection detected.\nPlease connect and try again." $H $W
exit 1
fi

# ============================================================

# Welcome

# ============================================================
whiptail --title "🌙 Moonveil Installer" --yesno \
"Welcome to the Moonveil installer!

This will:
• Install all required packages
• Back up your existing configs
• Deploy Moonveil dotfiles
• Set up CrescentShell (Quickshell)
• Install Oh My Zsh + Powerlevel10k
• Set Zsh as your default shell

Continue with installation?" $H $W

if [ $? -ne 0 ]; then
clear
warn "Installation cancelled."
exit 0
fi

# ============================================================

# AUR Helper Selection

# ============================================================

AUR_CHOICE=$(whiptail --title "AUR Helper" --menu \
"Choose your AUR helper:" $H $W 2 \
"1" "yay  (recommended)" \
"2" "paru" \
3>&1 1>&2 2>&3)

case "$AUR_CHOICE" in
2)
AUR="paru"
AUR_REPO="https://aur.archlinux.org/paru-bin.git"
;;
*)
AUR="yay"
AUR_REPO="https://aur.archlinux.org/yay-bin.git"
;;
esac

# ============================================================

# Installation Options

# ============================================================

INSTALL_OPTS=$(whiptail --title "Installation Options" --checklist \
"Select what to install: (SPACE to toggle)" $H $W 5 \
"packages"   "Install all packages"          ON \
"dotfiles"   "Deploy dotfiles"               ON \
"shell"      "Set up Zsh + Oh My Zsh"        ON \
"wallpapers" "Clone wallpaper collection"    ON \
"autostart"  "Configure CrescentShell"       ON \
3>&1 1>&2 2>&3)

# ============================================================

# Helper: run with progress

# ============================================================

run_step() {
local title="$1"
local cmd="$2"
(
eval "$cmd" > /tmp/moonveil-install.log 2>&1
) &
local pid=$!
local i=0
while kill -0 $pid 2>/dev/null; do
i=$(( (i + 5) % 100 ))
echo $i
sleep 0.3
done | whiptail --title "🌙 Moonveil" --gauge "$title" 8 $W 0
wait $pid
return $?
}

# ============================================================

# Step 1: System Update

# ============================================================

whiptail --title "🌙 Moonveil" --infobox "Updating system packages…" 8 $W
sudo pacman -Syu --noconfirm > /tmp/moonveil-install.log 2>&1 || {
whiptail --title "Error" --msgbox "System update failed.\nCheck /tmp/moonveil-install.log" $H $W
exit 1
}
success "System updated"

# ============================================================

# Step 2: Core Dependencies

# ============================================================

whiptail --title "🌙 Moonveil" --infobox "Installing core dependencies…" 8 $W
sudo pacman -S --needed --noconfirm \
base-devel git curl wget unzip zsh \
networkmanager network-manager-applet nm-connection-editor \
power-profiles-daemon upower \
fastfetch > /tmp/moonveil-install.log 2>&1 || {
whiptail --title "Error" --msgbox "Failed to install core deps.\nCheck /tmp/moonveil-install.log" $H $W
exit 1
}
sudo systemctl enable -now NetworkManager 2>/dev/null || true
sudo systemctl enable -now power-profiles-daemon 2>/dev/null || true
success "Core dependencies installed"

# ============================================================

# Step 3: AUR Helper

# ============================================================

if command -v "$AUR" &>/dev/null; then
success "$AUR already installed"
else
whiptail --title "🌙 Moonveil" --infobox "Installing $AUR…" 8 $W
tmpdir=$(mktemp -d)
git clone --depth=1 "$AUR_REPO" "$tmpdir/$AUR" > /tmp/moonveil-install.log 2>&1
(cd "$tmpdir/$AUR" && makepkg -si --noconfirm >> /tmp/moonveil-install.log 2>&1)
rm -rf "$tmpdir"
success "$AUR installed"
fi

# ============================================================

# Step 4: Moonveil Packages

# ============================================================

if [[ "$INSTALL_OPTS" == *"packages"* ]]; then
whiptail --title "🌙 Moonveil" --infobox "Installing Moonveil packages…\nThis may take a while ☕" 8 $W

```
"$AUR" -S --needed --noconfirm \
    hyprland xdg-desktop-portal-hyprland \
    quickshell-git \
    grim slurp wl-clipboard hyprpicker \
    nautilus pavucontrol \
    libnotify gnome-bluetooth-3.0 vte3 \
    imagemagick cava kitty \
    matugen adw-gtk-theme lxappearance bibata-cursor-theme \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk \
    noto-fonts-emoji otf-geist-mono \
    ttf-geist-mono-nerd otf-geist-mono-nerd otf-codenewroman-nerd \
    ttf-libre-barcode \
    eza > /tmp/moonveil-install.log 2>&1 || {
    whiptail --title "Error" --msgbox \
        "Package installation failed.\nCheck /tmp/moonveil-install.log" $H $W
    exit 1
}
```
success "All packages installed"

fi

# ============================================================

# Step 5: Clone Repositories

# ============================================================

MOONVEIL_DIR="$HOME/moonveil"
WALL_DIR="$HOME/wallpaper"

whiptail --title "🌙 Moonveil" --infobox "Cloning Moonveil repository…" 8 $W
if [ -d "$MOONVEIL_DIR/.git" ]; then
git -C "$MOONVEIL_DIR" pull > /tmp/moonveil-install.log 2>&1
success "Moonveil updated"
else
git clone --depth=1 https://github.com/notcandy001/moonveil.git
ls "$MOONVEIL_DIR" > /tmp/moonveil-install.log 2>&1
success "Moonveil cloned"
fi

if [[ "$INSTALL_OPTS" == *"wallpapers"* ]]; then
whiptail --title "🌙 Moonveil" --infobox "Cloning wallpaper collection…" 8 $W
if [ -d "$WALL_DIR/.git" ]; then
git -C "$WALL_DIR" pull > /tmp/moonveil-install.log 2>&1
success "Wallpapers updated"
else
git clone --depth=1 https://github.com/notcandy001/my-wal.git "$WALL_DIR"
ls "$WALL_DIR" > /tmp/moonveil-install.log 2>&1
success "Wallpapers cloned → ~/wallpaper"
fi
fi

# ============================================================

# Step 6: Backup

# ============================================================

whiptail --title "🌙 Moonveil" --infobox "Backing up existing configs…" 8 $W
BACKUP_DIR="$HOME/.moonveil-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
for item in .config .local .zshrc .p10k.zsh; do
[ -e "$HOME/$item" ] && cp -r "$HOME/$item" "$BACKUP_DIR/" 2>/dev/null || true
done
success "Backup saved → $BACKUP_DIR"

# ============================================================

# Step 7: Deploy Dotfiles

# ============================================================

if [[ "$INSTALL_OPTS" == *"dotfiles"* ]]; then
whiptail --title "🌙 Moonveil" --infobox "Deploying dotfiles…" 8 $W
mkdir -p "$HOME/.config" "$HOME/.local/bin"
cp -r "$MOONVEIL_DIR/dots/.config/"* "$HOME/.config/"
cp -r "$MOONVEIL_DIR/dots/.local/"*  "$HOME/.local/"
chmod +x "$HOME/.local/bin/"* 2>/dev/null || true
success "Dotfiles deployed"
fi

# ============================================================

# Step 8: Shell Setup

# ============================================================

if [[ "$INSTALL_OPTS" == *"shell"* ]]; then
whiptail --title "🌙 Moonveil" --infobox "Setting up shell…" 8 $W

```
SHELL_DIR="$MOONVEIL_DIR/dots/shell"
[ -f "$SHELL_DIR/zshrc" ]    && cp "$SHELL_DIR/zshrc"    "$HOME/.zshrc"
[ -f "$SHELL_DIR/p10k.zsh" ] && cp "$SHELL_DIR/p10k.zsh" "$HOME/.p10k.zsh"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        > /tmp/moonveil-install.log 2>&1
fi

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
[ ! -d "$P10K_DIR" ] && git clone --depth=1 \
    https://gitee.com/romkatv/powerlevel10k.git "$P10K_DIR" \
    > /tmp/moonveil-install.log 2>&1 || true

[ "$SHELL" != "$(which zsh)" ] && chsh -s "$(which zsh)"

success "Shell configured"
```

fi

# ============================================================

# Step 9: Font Cache

# ============================================================

whiptail --title "🌙 Moonveil" --infobox "Refreshing font cache…" 8 $W
fc-cache -fv > /tmp/moonveil-install.log 2>&1
success "Font cache refreshed"

# ============================================================

# Step 10: CrescentShell Autostart

# ============================================================

if [[ "$INSTALL_OPTS" == *"autostart"* ]]; then
HYPR_AUTOSTART="$HOME/.config/hypr/modules/autostart.conf"
if [ -f "$HYPR_AUTOSTART" ]; then
sed -i '/quickshell/d' "$HYPR_AUTOSTART"
echo "exec-once = qs -p ~/.config/quickshell/CrescentShell/shell.qml"
>> "$HYPR_AUTOSTART"
success "CrescentShell autostart configured"
else
warn "autostart.conf not found — add manually"
fi
fi

# ============================================================

# Done!

# ============================================================

whiptail --title "🌙 Installation Complete!" --msgbox \
"Moonveil has been installed successfully!

Moonveil     →  ~/moonveil
Wallpapers   →  ~/wallpaper
Backup       →  ~/.moonveil-backup-*
Shell        →  CrescentShell

Quick keybinds:
Super + A          Control center
Super + N          Notifications
Super + R          App launcher
Super + Tab        Overview
Super + L          Lock screen
Super + I          Settings

Log out and back in to apply all changes." $H $W

clear
echo -e "${PURPLE}${BOLD}"
cat << "EOF"

Installation Complete! 🌙

Log out and back in to start Moonveil.

EOF
echo -e "${RESET}"