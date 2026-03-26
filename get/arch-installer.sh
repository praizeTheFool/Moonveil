#!/usr/bin/env bash
set -Eeuo pipefail

#---------------- Colors ----------------#

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

H=20
W=70
TMP_LOG="/tmp/moonveil-install.log"
: > "$TMP_LOG"

#---------------- Banner ----------------#

clear
echo -e "${PURPLE}${BOLD}"
cat << "EOF"

███╗   ███╗ ██████╗  ██████╗ ███╗   ██╗██╗   ██╗███████╗██╗██╗
████╗ ████║██╔═══██╗██╔═══██╗████╗  ██║██║   ██║██╔════╝██║██║
██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║██║   ██║█████╗  ██║██║
██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║╚██╗ ██╔╝██╔══╝  ██║██║
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║ ╚████╔╝ ███████╗██║███████╗
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝  ╚═══╝  ╚══════╝╚═╝╚══════╝

      A quiet, moonlit Hyprland environment.

EOF
echo -e "${RESET}"
echo -e "${DIM}  https://github.com/notcandy001/moonveil${RESET}\n"
sleep 1

#---------------- Safety ----------------#

if [ "$(id -u)" -eq 0 ]; then
  whiptail --msgbox "Do NOT run as root." $H $W
  exit 1
fi

if ! command -v pacman &>/dev/null; then
  whiptail --msgbox "Arch Linux required." $H $W
  exit 1
fi

if ! command -v whiptail &>/dev/null; then
  sudo pacman -S --needed --noconfirm libnewt
fi

sudo -v || {
  whiptail --msgbox "Sudo failed." $H $W
  exit 1
}

#---------------- Welcome ----------------#

whiptail --yesno "Install Moonveil?" $H $W || exit 0

#---------------- AUR ----------------#

AUR="yay"
AUR_REPO="https://aur.archlinux.org/yay-bin.git"

#---------------- Update ----------------#

sudo pacman -Syu --noconfirm

#---------------- Core ----------------#

sudo pacman -S --needed --noconfirm \
base-devel git curl wget unzip zsh \
networkmanager network-manager-applet nm-connection-editor \
power-profiles-daemon upower fastfetch

sudo systemctl enable -now NetworkManager 2>/dev/null || true

#---------------- AUR Install ----------------#

if ! command -v yay &>/dev/null; then
  tmp=$(mktemp -d)
  git clone "$AUR_REPO" "$tmp/yay"
  cd "$tmp/yay"
  makepkg -si --noconfirm
  cd -
  rm -rf "$tmp"
fi

#---------------- PACKAGE INSTALL (FIXED) ----------------#

(
yay -S --needed --noconfirm \
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
ttf-libre-barcode eza
) 2>&1 | tee "$TMP_LOG" | \
whiptail --title "Installing Packages" --textbox /dev/stdin 20 $W

success "Packages installed"

#---------------- Clone ----------------#

git clone https://github.com/notcandy001/moonveil.git "$HOME/moonveil" || true

#---------------- Dotfiles ----------------#

cp -r "$HOME/moonveil/dots/.config/"* "$HOME/.config/" 2>/dev/null || true
cp -r "$HOME/moonveil/dots/.local/"* "$HOME/.local/" 2>/dev/null || 

#---------------- DONE ----------------#

whiptail --title "🌙 Installation Complete!" --msgbox \
"Moonveil has been installed successfully!

📁 Locations:
Moonveil     →  ~/moonveil
Dotfiles     →  ~/.config & ~/.local
Backup       →  ~/.moonveil-backup-*
Wallpapers   →  ~/wallpaper

🖥 Environment:
Shell        →  CrescentShell (QuickShell)

⌨ Keybinds:
Super + A    →  Control Center
Super + N    →  Notifications
Super + R    →  App Launcher
Super + Tab  →  Overview
Super + L    →  Lock Screen
Super + I    →  Settings

⚠ Important:
Log out and log back in to apply all changes." 20 70

clear
echo -e "${PURPLE}${BOLD}"
cat << "EOF"

███╗   ███╗ ██████╗  ██████╗ ███╗   ██╗██╗   ██╗███████╗██╗██╗
████╗ ████║██╔═══██╗██╔═══██╗████╗  ██║██║   ██║██╔════╝██║██║
██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║██║   ██║█████╗  ██║██║
██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║╚██╗ ██╔╝██╔══╝  ██║██║
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║ ╚████╔╝ ███████╗██║███████╗
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝  ╚═══╝  ╚══════╝╚═╝╚══════╝

        Installation Complete! 🌙

        Welcome to Moonveil

EOF
echo -e "${RESET}"
