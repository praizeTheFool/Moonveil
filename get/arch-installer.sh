#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================

# Moonveil Installer

# Arch Linux Only

# ============================================================

RESET=”\e[0m”
BOLD=”\e[1m”
DIM=”\e[2m”
PURPLE=”\e[38;5;141m”
CYAN=”\e[38;5;51m”
GREEN=”\e[38;5;82m”
RED=”\e[38;5;196m”
YELLOW=”\e[38;5;226m”

info()    { echo -e “  ${CYAN}${BOLD}➜${RESET}  $1”; }
success() { echo -e “  ${GREEN}${BOLD}✔${RESET}  $1”; }
error()   { echo -e “  ${RED}${BOLD}✘${RESET}  $1”; }
warn()    { echo -e “  ${YELLOW}${BOLD}!${RESET}  $1”; }
section() { echo -e “\n${PURPLE}${BOLD}── $1 ${RESET}\n”; }

# ============================================================

# Banner

# ============================================================

clear
echo -e “${PURPLE}${BOLD}”
cat << “EOF”

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
echo -e “${RESET}”
echo -e “${DIM}  https://github.com/notcandy001/moonveil${RESET}\n”
sleep 1

# ============================================================

# Safety Checks

# ============================================================

section “Checking requirements”

if [ “$(id -u)” -eq 0 ]; then
error “Do NOT run as root. Run as your normal user.”
exit 1
fi
success “Not running as root”

if ! command -v pacman &>/dev/null; then
error “This installer requires Arch Linux.”
exit 1
fi
success “Arch Linux detected”

if ! ping -c 1 archlinux.org &>/dev/null 2>&1; then
error “No internet connection. Please connect and try again.”
exit 1
fi
success “Internet connection OK”

# ============================================================

# Confirm

# ============================================================

echo
echo -e “${YELLOW}${BOLD}  This installer will:${RESET}”
echo -e “${DIM}  • Install all required packages”
echo -e “  • Back up your existing ~/.config and ~/.local”
echo -e “  • Deploy Moonveil dotfiles”
echo -e “  • Set up CrescentShell (Quickshell)”
echo -e “  • Install Oh My Zsh + Powerlevel10k”
echo -e “  • Set Zsh as your default shell${RESET}”
echo
read -rp “  Continue? [y/N] “ confirm
if [[ ! “$confirm” =~ ^[Yy]$ ]]; then
echo
warn “Installation cancelled.”
exit 0
fi

# ============================================================

# System Update

# ============================================================

section “Updating system”
info “Running pacman -Syu…”
sudo pacman -Syu –noconfirm
success “System updated”

# ============================================================

# Core Dependencies (pacman)

# ============================================================

section “Installing core dependencies”
info “Installing base tools…”
sudo pacman -S –needed –noconfirm   
base-devel git curl wget unzip zsh   
networkmanager network-manager-applet nm-connection-editor   
power-profiles-daemon upower   
fastfetch

info “Enabling system services…”
sudo systemctl enable –now NetworkManager
sudo systemctl enable –now power-profiles-daemon
success “Core dependencies installed”

# ============================================================

# AUR Helper

# ============================================================

section “AUR Helper”

echo -e “  Which AUR helper would you like to use?\n”
echo -e “  ${BOLD}1)${RESET} yay  ${DIM}(recommended)${RESET}”
echo -e “  ${BOLD}2)${RESET} paru”
echo
read -rp “  Enter choice [1-2, default: 1]: “ aur_choice

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

if command -v “$AUR” &>/dev/null; then
success “$AUR is already installed”
else
info “Installing $AUR…”
tmpdir=$(mktemp -d)
git clone –depth=1 “$AUR_REPO” “$tmpdir/$AUR”
(cd “$tmpdir/$AUR” && makepkg -si –noconfirm)
rm -rf “$tmpdir”
success “$AUR installed”
fi

# ============================================================

# Moonveil Packages

# ============================================================

section “Installing Moonveil packages”
info “This may take a while…”

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

success “All packages installed”

# ============================================================

# Clone Repositories

# ============================================================

section “Cloning repositories”

MOONVEIL_DIR=”$HOME/moonveil”
WALL_DIR=”$HOME/wallpaper”

info “Cloning Moonveil dotfiles…”
if [ -d “$MOONVEIL_DIR/.git” ]; then
git -C “$MOONVEIL_DIR” pull
success “Moonveil updated”
else
git clone –depth=1 https://github.com/notcandy001/moonveil.git “$MOONVEIL_DIR”
success “Moonveil cloned”
fi

info “Cloning wallpaper collection…”
if [ -d “$WALL_DIR/.git” ]; then
git -C “$WALL_DIR” pull
success “Wallpapers updated”
else
git clone –depth=1 https://github.com/notcandy001/my-wal.git “$WALL_DIR”
success “Wallpapers cloned → ~/wallpaper”
fi

# ============================================================

# Backup Existing Config

# ============================================================

section “Backing up existing configs”

BACKUP_DIR=”$HOME/.moonveil-backup-$(date +%Y%m%d-%H%M%S)”
mkdir -p “$BACKUP_DIR”

for item in .config .local .zshrc .p10k.zsh; do
if [ -e “$HOME/$item” ]; then
cp -r “$HOME/$item” “$BACKUP_DIR/” 2>/dev/null || true
info “Backed up ~/$item”
fi
done

success “Backup saved → $BACKUP_DIR”

# ============================================================

# Deploy Dotfiles

# ============================================================

section “Deploying dotfiles”

mkdir -p “$HOME/.config” “$HOME/.local/bin”

info “Copying configs…”
cp -r “$MOONVEIL_DIR/dots/.config/”* “$HOME/.config/”

info “Copying local binaries…”
cp -r “$MOONVEIL_DIR/dots/.local/”* “$HOME/.local/”
chmod +x “$HOME/.local/bin/”* 2>/dev/null || true

success “Dotfiles deployed”

# ============================================================

# Shell Setup

# ============================================================

section “Setting up shell”

SHELL_DIR=”$MOONVEIL_DIR/dots/shell”

# Copy shell configs

if [ -d “$SHELL_DIR” ]; then
[ -f “$SHELL_DIR/zshrc” ]   && cp “$SHELL_DIR/zshrc”   “$HOME/.zshrc”
[ -f “$SHELL_DIR/p10k.zsh” ] && cp “$SHELL_DIR/p10k.zsh” “$HOME/.p10k.zsh”
success “Shell config installed”
fi

# Oh My Zsh

if [ ! -d “$HOME/.oh-my-zsh” ]; then
info “Installing Oh My Zsh…”
RUNZSH=no CHSH=no sh -c   
“$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)”
success “Oh My Zsh installed”
else
success “Oh My Zsh already installed”
fi

# Powerlevel10k

P10K_DIR=”${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k”
if [ ! -d “$P10K_DIR” ]; then
info “Installing Powerlevel10k…”
git clone –depth=1 https://gitee.com/romkatv/powerlevel10k.git “$P10K_DIR”
success “Powerlevel10k installed”
else
success “Powerlevel10k already installed”
fi

# Set Zsh as default

if [ “$SHELL” != “$(which zsh)” ]; then
info “Setting Zsh as default shell…”
chsh -s “$(which zsh)”
success “Default shell changed to Zsh”
fi

# ============================================================

# Font Cache

# ============================================================

section “Refreshing fonts”
fc-cache -fv &>/dev/null
success “Font cache refreshed”

# ============================================================

# CrescentShell Autostart

# ============================================================

section “Configuring CrescentShell”

HYPR_AUTOSTART=”$HOME/.config/hypr/modules/autostart.conf”

if [ -f “$HYPR_AUTOSTART” ]; then
# Remove old quickshell lines
sed -i ‘/quickshell/d’ “$HYPR_AUTOSTART”
# Add correct autostart
echo “exec-once = qs -p ~/.config/quickshell/CrescentShell/shell.qml” >> “$HYPR_AUTOSTART”
success “CrescentShell autostart configured”
else
warn “Could not find autostart.conf — add this manually to your Hyprland config:”
echo -e “\n  ${DIM}exec-once = qs -p ~/.config/quickshell/CrescentShell/shell.qml${RESET}\n”
fi

# ============================================================

# Done!

# ============================================================

sleep 1
clear

echo -e “${PURPLE}${BOLD}”
cat << “EOF”

███╗   ███╗ ██████╗  ██████╗ ███╗   ██╗██╗   ██╗███████╗██╗██╗
████╗ ████║██╔═══██╗██╔═══██╗████╗  ██║██║   ██║██╔════╝██║██║
██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║██║   ██║█████╗  ██║██║
██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║╚██╗ ██╔╝██╔══╝  ██║██║
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║ ╚████╔╝ ███████╗██║███████╗
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝  ╚═══╝  ╚══════╝╚═╝╚══════╝

```
               Installation Complete!
```

EOF
echo -e “${RESET}”

echo -e “${DIM}”
echo -e “  Moonveil     →  ~/moonveil”
echo -e “  Wallpapers   →  ~/wallpaper”
echo -e “  Backup       →  ~/.moonveil-backup-*”
echo -e “  Shell        →  CrescentShell (Quickshell)”
echo -e “${RESET}”

echo -e “${PURPLE}${BOLD}  Quick keybinds:${RESET}”
echo -e “${DIM}”
echo -e “  Super + A          Control center”
echo -e “  Super + N          Notifications”
echo -e “  Super + R          App launcher”
echo -e “  Super + Tab        Workspace overview”
echo -e “  Super + L          Lock screen”
echo -e “  Super + I          Settings”
echo -e “  Super + Shift + Escape   Power menu”
echo -e “${RESET}”

echo -e “  ${YELLOW}Log out and back in to apply all changes.${RESET}\n”
