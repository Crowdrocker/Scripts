#!/usr/bin/env bash
# Arch Linux setup script: Hyprland + curated fonts + gaming optimizations + TokyoNight theme
# Target: Photography, Graphic Design, Video Editing, Gaming

set -e

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

# ------------------------
# Remove font bloat
# ------------------------
echo ">>> Removing unnecessary fonts..."
sudo pacman -Rns --noconfirm \
    gsfonts \
    xorg-fonts* \
    ttf-bitstream-vera \
    ttf-ms-fonts \
    adobe-source-han-sans-* \
    adobe-source-han-serif-* \
    noto-fonts-extra || true

# ------------------------
# Core utilities
# ------------------------
echo ">>> Installing core utilities..."
sudo pacman -S --needed --noconfirm \
    base-devel git curl wget unzip \
    polkit gvfs ntfs-3g p7zip unrar zip unzip \
    pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    networkmanager bluez bluez-utils \
    sddm thunar pavucontrol \
    wl-clipboard grim slurp swappy \
    xdg-user-dirs

# ------------------------
# Hyprland desktop
# ------------------------
echo ">>> Installing Hyprland environment..."
sudo pacman -S --needed --noconfirm \
    hyprland \
    hyprpaper \
    waybar \
    wofi \
    foot \
    kitty \
    ttf-font-awesome  # icons for Waybar

# ------------------------
# Fonts (curated set)
# ------------------------
echo ">>> Installing curated fonts..."
sudo pacman -S --needed --noconfirm \
    # Core
    ttf-dejavu \
    noto-fonts \
    noto-fonts-emoji \
    \
    # Adobe professional set
    adobe-source-sans-fonts \
    adobe-source-serif-fonts \
    adobe-source-code-pro-fonts \
    \
    # Design/UI
    ttf-opensans \
    ttf-roboto \
    ttf-ubuntu-font-family \
    ttf-fira-sans \
    ttf-fira-code \
    \
    # Gaming/UI compatibility
    ttf-liberation \
    ttf-droid

# ------------------------
# Gaming packages
# ------------------------
echo ">>> Installing gaming tools..."
sudo pacman -S --needed --noconfirm \
    steam \
    lutris \
    mangohud \
    goverlay \
    gamemode \
    wine wine-mono wine-gecko \
    winetricks \
    protonup-qt \
    vulkan-radeon lib32-vulkan-radeon \
    lib32-mesa lib32-mesa-demos \
    mesa-utils \
    dxvk-bin \
    vkbasalt

# ------------------------
# Configs (TokyoNight theme)
# ------------------------
echo ">>> Setting up Hyprland configs..."
mkdir -p ~/.config/{hypr,waybar,wofi,hyprpaper}

# Hyprland config
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# Hyprland TokyoNight Config

monitor=,preferred,auto,1

exec-once = waybar &
exec-once = wofi --show drun &
exec-once = hyprpaper &

input {
    kb_layout = us
    follow_mouse = 1
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(7aa2f7ff) rgba(bb9af7ff) 45deg
    col.inactive_border = rgba(1a1b26cc)
}

decoration {
    rounding = 6
    blur = yes
    blur_size = 5
    blur_passes = 3
}

animations {
    enabled = yes
    bezier = ease,0.25,0.1,0.25,1
    animation = windows,1,7,ease
    animation = border,1,10,ease
    animation = fade,1,7,ease
}

# Keybinds
bind = SUPER, RETURN, exec, kitty
bind = SUPER, D, exec, wofi --show drun
bind = SUPER, Q, killactive,
bind = SUPER, E, exec, thunar
bind = SUPER, F, fullscreen
bind = SUPER, V, togglefloating
bind = SUPER, C, exec, pavucontrol
bind = SUPER, M, exec, firefox
bind = SUPER, P, pseudo,
bind = SUPER, R, exec, reboot
bind = SUPER, SHIFT, Q, exit
EOF

# Waybar config
cat > ~/.config/waybar/config << 'EOF'
{
    "layer": "top",
    "position": "top",
    "modules-left": ["workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery"],

    "clock": {
        "format": "  {:%H:%M}    {:%Y-%m-%d}"
    }
}
EOF

cat > ~/.config/waybar/style.css << 'EOF'
* {
    font-family: "Fira Sans", "Roboto", "Noto Sans", sans-serif;
    font-size: 13px;
}

window#waybar {
    background-color: #1a1b26;
    color: #c0caf5;
    border-bottom: 2px solid #7aa2f7;
}

#workspaces button.active {
    background: #7aa2f7;
    color: #1a1b26;
}

#clock {
    color: #bb9af7;
}
EOF

# Wofi theme
cat > ~/.config/wofi/style.css << 'EOF'
window {
    border: 2px solid #7aa2f7;
    background-color: #1a1b26;
    color: #c0caf5;
    font-family: "Fira Sans";
}
EOF

# Hyprpaper wallpaper
cat > ~/.config/hyprpaper/hyprpaper.conf << 'EOF'
preload = ~/.config/hypr/wallpapers/tokyonight.png
wallpaper = ,~/.config/hypr/wallpapers/tokyonight.png
EOF

mkdir -p ~/.config/hypr/wallpapers
curl -Lo ~/.config/hypr/wallpapers/tokyonight.png \
    https://raw.githubusercontent.com/enkia/tokyo-night-vscode-theme/master/icons/icon.png

# ------------------------
# SDDM TokyoNight theme
# ------------------------
echo ">>> Installing SDDM TokyoNight theme..."
git clone https://github.com/Keyitdev/sddm-astronaut-theme.git /tmp/sddm-tokyonight
sudo mkdir -p /usr/share/sddm/themes/tokyonight
sudo cp -r /tmp/sddm-tokyonight/* /usr/share/sddm/themes/tokyonight
rm -rf /tmp/sddm-tokyonight

# Apply theme
sudo mkdir -p /etc/sddm.conf.d
cat <<EOF | sudo tee /etc/sddm.conf.d/theme.conf
[Theme]
Current=tokyonight
EOF

# ------------------------
# OBS Studio + Streaming Tools
# ------------------------
echo ">>> Installing OBS Studio and streaming essentials..."
sudo pacman -S --needed --noconfirm \
    obs-studio \
    vlc \
    ffmpeg \
    obs-studio-plugins \
    obs-websocket

# ------------------------
# OBS TokyoNight Profile
# ------------------------
echo ">>> Setting up OBS TokyoNight profile..."
mkdir -p ~/.config/obs-studio/basic/profiles/TokyoNight
cat > ~/.config/obs-studio/basic/profiles/TokyoNight/basic.ini << 'EOF'
[General]
Name=TokyoNight
[Video]
BaseCX=1280
BaseCY=720
OutputCX=1280
OutputCY=720
FPSNumerator=60
FPSDenominator=1
[Output]
Mode=Advanced
EOF 

mkdir -p ~/.config/obs-studio/basic/scenes
cat > ~/.config/obs-studio/basic/scenes/TokyoNight.json << 'EOF'
{
  "name": "TokyoNight",
  "sources": [
    {
      "name": "Game Capture",
      "type": "game_capture",
      "settings": {}
    },
    {
      "name": "Camera",
      "type": "dshow_input",
      "settings": {
        "width": 640,
        "height": 360
      }
    },
    {
      "name": "Overlay",
      "type": "image_source",
      "settings": {
        "file": "~/.config/obs-studio/tokyonight/overlay.png"
      }
    }
  ]
}
EOF
mkdir -p ~/.config/obs-studio/tokyonight
curl -Lo ~/.config/obs-studio/tokyonight/overlay.png \
    https://raw.githubusercontent.com/enkia/tokyo-night-vscode-theme/master/icons/icon.png

# ------------------------
# TokyoNight Stinger Transition
# ------------------------
echo ">>> Installing TokyoNight OBS stinger..."
mkdir -p ~/.config/obs-studio/tokyonight

# Download prebuilt .webm stinger
curl -Lo ~/.config/obs-studio/tokyonight/stinger.webm \
    https://github.com/CrowdRocker/assets/raw/main/tokyonight-stinger.webm

# OBS scene transition config
mkdir -p ~/.config/obs-studio/basic/scenes
cat > ~/.config/obs-studio/basic/scenes/transitions.json << 'EOF'
{
  "current_transition": "TokyoNight Stinger",
  "transitions": [
    {
      "name": "TokyoNight Stinger",
      "type": "stinger_transition",
      "settings": {
        "path": "~/.config/obs-studio/tokyonight/stinger.webm",
        "transition_point_type": "time",
        "transition_point": 500
      }
    }
  ]
}
EOF

# ------------------------
# GTK + Icon + Cursor Theme
# ------------------------
echo ">>> Installing GTK, icon, and cursor themes..."

# Install AUR helper if not already
if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
fi

# Install themes
yay -S --needed --noconfirm \
    tokyonight-gtk-theme \
    papirus-icon-theme \
    capitaine-cursors

# Apply GTK theme
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Tokyonight-Dark-B
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Fira Sans 11
gtk-cursor-theme-name=Capitaine Cursors
gtk-cursor-theme-size=24
EOF

cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini


# ------------------------
# Enable services
# ------------------------
echo ">>> Enabling services..."
sudo systemctl enable sddm.service
sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service

echo ">>> Setup complete!"
echo "Reboot, log into Hyprland via SDDM, and enjoy TokyoNight!"
