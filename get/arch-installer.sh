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

#---------------- Safety Checks ----------------#

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
  whiptail --msgbox "Sudo authentication failed." $H $W
  exit 1
}

#---------------- Welcome ----------------#

whiptail --title " Moonveil Installer" --yesno \
"Welcome to Moonveil installer!

This will install everything needed.

Continue?" $H $W || exit 0

#---------------- AUR Selection ----------------#

AUR_CHOICE=$(whiptail --menu "Choose AUR helper" $H $W 2 \
"1" "yay (recommended)" \
"2" "paru" \
3>&1 1>&2 2>&3)

if [ "$AUR_CHOICE" = "2" ]; then
  AUR="paru"
  AUR_REPO="https://aur.archlinux.org/paru-bin.git"
else
  AUR="yay"
  AUR_REPO="https://aur.archlinux.org/yay-bin.git"
fi

#---------------- System Update ----------------#

whiptail --infobox "Updating system..." 8 $W
sudo pacman -Syu --noconfirm 2>&1 | tee "$TMP_LOG"

#---------------- Core Dependencies ----------------#

whiptail --infobox "Installing core dependencies..." 8 $W
sudo pacman -S --needed --noconfirm \
base-devel git curl wget unzip zsh \
networkmanager network-manager-applet nm-connection-editor \
power-profiles-daemon upower fastfetch \
2>&1 | tee "$TMP_LOG"

sudo systemctl enable -now NetworkManager 2>/dev/null || true
sudo systemctl enable -now power-profiles-daemon 2>/dev/null || true

#---------------- AUR Install ----------------#

if command -v "$AUR" &>/dev/null; then
  success "$AUR already installed"
else
  tmpdir=$(mktemp -d)
  git clone --depth=1 "$AUR_REPO" "$tmpdir/$AUR" 2>&1 | tee "$TMP_LOG"
  cd "$tmpdir/$AUR"

  makepkg -si --noconfirm --needed 2>&1 | tee "$TMP_LOG" | \
    whiptail --title "Installing $AUR" --textbox /dev/stdin 20 $W

  cd -
  rm -rf "$tmpdir"
  success "$AUR installed"
fi

#---------------- Package Install ----------------#

(
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
ttf-libre-barcode eza
) 2>&1 | tee "$TMP_LOG" | \
whiptail --title " Installing Packages" --textbox /dev/stdin 20 $W

success "All packages installed"

#---------------- Clone Repo ----------------#

MOONVEIL_DIR="$HOME/moonveil"

if [ -d "$MOONVEIL_DIR/.git" ]; then
  git -C "$MOONVEIL_DIR" pull
else
  git clone https://github.com/notcandy001/moonveil.git "$MOONVEIL_DIR"
fi

#---------------- Dotfiles ----------------#

mkdir -p "$HOME/.config" "$HOME/.local/bin"

cp -r "$MOONVEIL_DIR/dots/.config/"* "$HOME/.config/" 2>/dev/null || true
cp -r "$MOONVEIL_DIR/dots/.local/"* "$HOME/.local/" 2>/dev/null || true

chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

success "Dotfiles deployed"

#---------------- Final Screen ----------------#

whiptail --title " Installation Complete!" --msgbox \
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

Log out and back in to apply all changes." 20 70

clear
echo -e "${PURPLE}${BOLD}"
cat << 'EOF'

Installation Complete! 

Log out and back in to start Moonveil.

EOF
echo -e "${RESET}"
