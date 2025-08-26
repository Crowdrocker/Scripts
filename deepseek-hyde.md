# WehttamSnaps Hyprland Setup

Based on your requirements, I've created a comprehensive Hyprland setup using HyDE project as a base with your customizations. Here's the complete solution:

## Installation Script

Create a file called `wehttamsnaps-setup.sh` with the following content:

```bash
#!/bin/bash

# WehttamSnaps Hyprland Setup Script
# Based on HyDE Project with customizations for Matt/WehttamSnaps

echo "Starting WehttamSnaps Hyprland setup..."

# Set variables
USERNAME="wehttamsnaps"
HOSTNAME="snaps-pc"
GAMES_DRIVE="/run/media/snaps/LINUXDRIVE-1"
HYPRLAND_CONFIG_DIR="/home/$USERNAME/.config/hypr"
HYDE_REPO_URL="https://github.com/HyDE-Project/dotfiles.git"

# Colors for output
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function for colored output
print_color() {
    echo -e "${2}${1}${NC}"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_color "Please run this script as a regular user, not as root." "$PURPLE"
    exit 1
fi

# Confirm username matches
if [ "$(whoami)" != "$USERNAME" ]; then
    print_color "Warning: Current user ($(whoami)) doesn't match expected username ($USERNAME)." "$PURPLE"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install prerequisite packages
print_color "Installing prerequisite packages..." "$BLUE"
sudo pacman -S --needed git base-devel

# Install yay if not already installed
if ! command -v yay &> /dev/null; then
    print_color "Installing yay AUR helper..." "$BLUE"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
fi

# Setup Chaotic-AUR
print_color "Setting up Chaotic-AUR repository..." "$BLUE"
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
echo -e "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

# Update system
print_color "Updating system..." "$BLUE"
sudo pacman -Syu --noconfirm

# Clone HyDE project
print_color "Cloning HyDE project dotfiles..." "$BLUE"
git clone "$HYDE_REPO_URL" ~/HyDE-Dotfiles
cd ~/HyDE-Dotfiles

# Create customized package lists
print_color "Creating customized package lists..." "$BLUE"

# Main package list
cat > pkg.lst << EOL
# WehttamSnaps Custom Package List
# Based on HyDE Project with gaming and streaming enhancements

# Hyprland and Core Components
hyprland
hyprpaper
hypridle
hyprlock
waybar
rofi
wofi
dunst
polkit-kde-agent
networkmanager
network-manager-applet
blueman
bluez
bluez-utils
brightnessctl

# Terminal and Shell
kitty
zsh
zsh-completions
zsh-syntax-highlighting
zsh-autosuggestions
starship
tmux

# File Management
thunar
thunar-archive-plugin
thunar-volman
tumbler
gvfs
gvfs-mtp
gvfs-gphoto2
gvfs-nfs
gvfs-smb

# Audio
pipewire
pipewire-pulse
pipewire-alsa
pipewire-jack
wireplumber
pavucontrol
helvum

# Applications
firefox
brave-bin
neovim
vim
ranger
w3m
imv
mpv
zathura
zathura-pdf-mupdf
viewnior
gimp
inkscape
krita
obs-studio
discord
spotify

# Gaming
steam
lutris
heroic-games-launcher
wine
winetricks
proton-ge-custom-bin
protonup-qt
gamemode
gamescope
mangohud
goverlay
vkbasalt
vulkan-radeon
lib32-vulkan-radeon
vulkan-tools
lib32-vulkan-icd-loader
vulkan-icd-loader
lib32-mesa
mesa
mesa-utils
mesa-vdpau
lib32-mesa-vdpau

# Development
nodejs
npm
python
python-pip
python-virtualenv
go
rustup
jdk-openjdk
docker
docker-compose

# System Utilities
htop
btop
neofetch
fastfetch
eza
bat
fd
ripgrep
fzf
man-db
man-pages
texinfo
lsd
duf
ncdu
dust
github-cli
flatpak
flatpak-kcm
fwupd
ufw
gparted
gnome-disk-utility
timeshift
reflector
pacman-contrib
inotify-tools
usbutils
pciutils
lm_sensors
psmisc
cups
system-config-printer

# Fonts and Themes
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
ttf-jetbrains-mono
ttf-jetbrains-mono-nerd
ttf-font-awesome
ttf-dejavu
ttf-liberation
otf-font-awesome
adwaita-icon-theme
papirus-icon-theme
breeze-icons
arc-gtk-theme
kvantum-theme-arc

# Additional Tools
calibre
transmission-gtk
veracrypt
keepassxc
qalculate-gtk
libreoffice-fresh
onlyoffice-bin
EOL

# Gaming-specific package list
cat > gaming-pkg.lst << EOL
# Gaming-specific packages for WehttamSnaps
steamtinkerlaunch
protontricks
boxtron
luxtorpeda
vortex-standalone
modorganizer2-linux-bin
wine-staging
wine-ge-custom
dxvk
vkd3d
lib32-dxvk
lib32-vkd3d
opencl-amd
lib32-opencl-amd
ocl-icd
lib32-ocl-icd
opencl-headers
opencl-clhpp
EOL

# Streaming package list
cat > streaming-pkg.lst << EOL
# Streaming packages for WehttamSnaps
obs-studio
obs-vkcapture
obs-websocket
obs-plugin-input-overlay
obs-plugin-advanced-scene-switcher
streamlabs-desktop
kdenlive
gstreamer
gst-plugins-good
gst-plugins-bad
gst-plugins-ugly
gst-libav
audacity
handbrake
ffmpeg
vlc
EOL

# Install packages
print_color "Installing main packages..." "$BLUE"
yay -S --needed - < pkg.lst

print_color "Installing gaming packages..." "$BLUE"
yay -S --needed - < gaming-pkg.lst

print_color "Installing streaming packages..." "$BLUE"
yay -S --needed - < streaming-pkg.lst

# Install Flatpaks
print_color "Installing Flatpak applications..." "$BLUE"
flatpak install -y flathub com.obsproject.Studio
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub org.kde.kdenlive

# Setup ZSH as default shell
print_color "Setting up ZSH as default shell..." "$BLUE"
chsh -s /bin/zsh $USERNAME

# Create directory structure
print_color "Creating directory structure..." "$BLUE"
mkdir -p ~/{.config,.local/share,.cache}
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/rofi
mkdir -p ~/.config/kitty
mkdir -p ~/.config/zsh
mkdir -p ~/.config/eww
mkdir -p ~/.config/nvim
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/Games
mkdir -p ~/Streaming
mkdir -p ~/Projects

# Setup gaming drive mount
print_color "Setting up gaming drive mount..." "$BLUE"
sudo mkdir -p "$GAMES_DRIVE"
echo "# Games drive mount" | sudo tee -a /etc/fstab
echo "/dev/disk/by-uuid/$(lsblk -no UUID $(findmnt -n -o SOURCE / | head -1) | head -1) $GAMES_DRIVE ext4 defaults 0 2" | sudo tee -a /etc/fstab

# Copy HyDE configuration with customizations
print_color "Copying and customizing HyDE configuration..." "$BLUE"
cp -r ~/HyDE-Dotfiles/hypr ~/.config/
cp -r ~/HyDE-Dotfiles/waybar ~/.config/
cp -r ~/HyDE-Dotfiles/rofi ~/.config/
cp -r ~/HyDE-Dotfiles/kitty ~/.config/
cp -r ~/HyDE-Dotfiles/zsh ~/.config/
cp -r ~/HyDE-Dotfiles/nvim ~/.config/

# Create custom Hyprland configuration
cat > ~/.config/hypr/hyprland.conf << EOL
# WehttamSnaps Hyprland Configuration
# Based on HyDE Project with customizations

# Monitor setup
monitor=,preferred,auto,1

# Execute your favorite apps at launch
exec-once = waybar
exec-once = dunst
exec-once = hyprpaper
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = nm-applet --indicator
exec-once = blueman-applet

# Source additional config files
source = ~/.config/hypr/keybinds.conf
source = ~/.config/hypr/windowrules.conf
source = ~/.config/hypr/workspaces.conf

# Input configuration
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
    sensitivity = 0 # -1.0 to 1.0, 0 means no modification.
}

# General configuration
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(8A2BE2ee) rgba(00FFFFee) 45deg
    col.inactive_border = rgba(595959aa)

    layout = dwindle
    allow_tearing = false
}

# Decoration configuration
decoration {
    rounding = 10
    
    blur {
        enabled = true
        size = 3
        passes = 1
    }

    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = yes

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Dwindle layout
dwindle {
    pseudotile = yes
    preserve_split = yes
}

# Master layout
master {
    new_is_master = true
}

# Gestures
gestures {
    workspace_swipe = on
}

# Window rules
windowrule = float,^(pavucontrol)$
windowrule = float,^(blueman-manager)$
windowrule = float,^(nm-connection-editor)$
windowrule = float,^(chromium)$
windowrule = float,^(thunar)$
windowrule = float, title:(Welcome to WehttamSnaps)
windowrule = size 800 600, title:(Welcome to WehttamSnaps)
windowrule = center, title:(Welcome to WehttamSnaps)

# Environment variables
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt5ct
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = GDK_BACKEND,wayland,x11
env = SDL_VIDEODRIVER,wayland
env = CLUTTER_BACKEND,wayland
env = MOZ_ENABLE_WAYLAND,1
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
EOL

# Create keybinds configuration
cat > ~/.config/hypr/keybinds.conf << EOL
# WehttamSnaps Keybindings

# Main modifier
$mainMod = SUPER

# Applications
bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, B, exec, brave
bind = $mainMod, E, exec, thunar
bind = $mainMod, F, exec, firefox
bind = $mainMod, D, exec, rofi -show drun
bind = $mainMod, P, exec, rofi -show power-menu -modi power-menu:rofi-power-menu
bind = $mainMod, S, exec, rofi -show window

# System controls
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, V, togglefloating,
bind = $mainMod, J, togglesplit, # dwindle
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, F, fullscreen,

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Media controls
bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Brightness controls
bind = , XF86MonBrightnessUp, exec, brightnessctl set +10%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

# Screenshot
bind = $mainMod, PRINT, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, PRINT, exec, grim - | wl-copy

# Gaming specific binds
bind = $mainMod, G, exec, gamemoderun
bind = $mainMod SHIFT, G, exec, killall -9 gamemoded

# Stream controls
bind = $mainMod SHIFT, O, exec, obs
bind = $mainMod SHIFT, S, exec, streamlabs-desktop

# Workspace cycling
bind = $mainMod, TAB, workspace, previous
EOL

# Create workspaces configuration
cat > ~/.config/hypr/workspaces.conf << EOL
# WehttamSnaps Workspace Configuration

# Workspace rules
workspace=1, persistent:true
workspace=2, persistent:true
workspace=3, persistent:true
workspace=4, persistent:true
workspace=5, persistent:true
workspace=6, persistent:true
workspace=7, persistent:true
workspace=8, persistent:true
workspace=9, persistent:true
workspace=10, persistent:true

# Assign applications to workspaces
workspace = 1, name:Main
workspace = 2, name:Web
workspace = 3, name:Term
workspace = 4, name:Files
workspace = 5, name:Media
workspace = 6, name:Game
workspace = 7, name:Stream
workspace = 8, name:Chat
workspace = 9, name:Creative
workspace = 10, name:Utils

# Window to workspace assignments
windowrulev2 = workspace 2, class:(brave)
windowrulev2 = workspace 2, class:(firefox)
windowrulev2 = workspace 3, class:(kitty)
windowrulev2 = workspace 4, class:(thunar)
windowrulev2 = workspace 5, class:(mpv)
windowrulev2 = workspace 5, class:(vlc)
windowrulev2 = workspace 6, class:(steam)
windowrulev2 = workspace 6, class:(lutris)
windowrulev2 = workspace 7, class:(obs)
windowrulev2 = workspace 7, class:(com.obsproject.Studio)
windowrulev2 = workspace 8, class:(discord)
windowrulev2 = workspace 9, class:(gimp)
windowrulev2 = workspace 9, class:(krita)
windowrulev2 = workspace 9, class:(inkscape)
windowrulev2 = workspace 10, class:(pavucontrol)
EOL

# Create custom Waybar configuration
cat > ~/.config/waybar/config << EOL
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["hyprland/window"],
    "modules-right": [
        "tray",
        "idle_inhibitor",
        "pulseaudio",
        "network",
        "cpu",
        "memory",
        "temperature",
        "backlight",
        "battery",
        "clock",
        "custom/power"
    ],
    "hyprland/workspaces": {
        "format": "{name}",
        "on-click": "activate"
    },
    "custom/launcher": {
        "format": "",
        "on-click": "rofi -show drun",
        "tooltip": false
    },
    "custom/power": {
        "format": "⏻",
        "on-click": "rofi -show power-menu -modi power-menu:rofi-power-menu",
        "tooltip": false
    },
    "clock": {
        "format": "{:%H:%M}",
        "tooltip-format": "{:%A, %B %d, %Y}"
    },
    "cpu": {
        "format": " {usage}%",
        "interval": 5
    },
    "memory": {
        "format": " {}%",
        "interval": 5
    },
    "temperature": {
        "format": " {temperatureC}°C",
        "critical-threshold": 80,
        "interval": 5
    },
    "backlight": {
        "format": "{icon} {percent}%",
        "format-icons": ["", "", "", "", "", "", "", "", ""]
    },
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-plugged": " {capacity}%",
        "format-icons": ["", "", "", "", ""]
    },
    "network": {
        "format-wifi": " {essid} ({signalStrength}%)",
        "format-ethernet": " {ifname}",
        "format-disconnected": "⚠ Disconnected",
        "interval": 5
    },
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": " Muted",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "",
            "deactivated": ""
        }
    },
    "tray": {
        "spacing": 10
    }
}
EOL

# Create custom Waybar style
cat > ~/.config/waybar/style.css << EOL
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free Solid";
    font-size: 14px;
    min-height: 0;
}

window#waybar {
    background: rgba(0, 0, 0, 0.8);
    color: #ffffff;
    transition-property: background-color;
    transition-duration: .5s;
}

window#waybar.hidden {
    opacity: 0.2;
}

#workspaces button {
    padding: 0 5px;
    background: transparent;
    color: #ffffff;
    border-bottom: 3px solid transparent;
}

#workspaces button.focused {
    background: #8A2BE2;
    border-bottom: 3px solid #00FFFF;
}

#workspaces button.urgent {
    background-color: #eb4d4b;
}

#mode {
    background: #64727D;
    border-bottom: 3px solid #ffffff;
}

#clock, #battery, #cpu, #memory, #temperature, #backlight, #network, #pulseaudio, #tray, #mode, #idle_inhibitor, #custom-power {
    padding: 0 10px;
    margin: 0 5px;
    color: #ffffff;
}

#clock {
    background-color: #8A2BE2;
}

#battery {
    background-color: #00FFFF;
    color: #000000;
}

#battery.charging {
    color: #000000;
    background-color: #00FF00;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}

#battery.critical:not(.charging) {
    background: #f53c3c;
    color: #ffffff;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#cpu {
    background: #8A2BE2;
    color: #000000;
}

#memory {
    background: #00FFFF;
    color: #000000;
}

#backlight {
    background: #8A2BE2;
    color: #000000;
}

#network {
    background: #00FFFF;
    color: #000000;
}

#network.disconnected {
    background: #f53c3c;
}

#pulseaudio {
    background: #8A2BE2;
    color: #000000;
}

#pulseaudio.muted {
    background: #90b1b1;
}

#temperature {
    background: #00FFFF;
    color: #000000;
}

#temperature.critical {
    background: #eb4d4b;
}

#tray {
    background-color: #8A2BE2;
}

#idle_inhibitor {
    background-color: #00FFFF;
    color: #000000;
}

#idle_inhibitor.activated {
    background-color: #8A2BE2;
    color: #ffffff;
}

#custom-power {
    background: #8A2BE2;
    border-radius: 15px;
    padding: 0 12px;
    margin: 0 5px;
}

#custom-launcher {
    background: #8A2BE2;
    border-radius: 15px;
    padding: 0 12px;
    margin: 0 5px;
}
EOL

# Create custom Rofi configuration
mkdir -p ~/.config/rofi
cat > ~/.config/rofi/config.rasi << EOL
/* WehttamSnaps Rofi Configuration */
configuration {
    modi: "drun,run,window";
    show-icons: true;
    icon-theme: "Papirus";
    display-drun: "Apps";
    display-run: "Run";
    display-window: "Windows";
    sidebar-mode: false;
}

@theme "Arc-Dark"

* {
    bg-col: #2F343F;
    bg-col-light: #FAFAFA;
    border-col: #8A2BE2;
    selected-col: #8A2BE2;
    blue: #00FFFF;
    fg-col: #FAFAFA;
    fg-col2: #00FFFF;
    grey: #BFBFBF;
    
    width: 600;
    font: "JetBrains Mono 12";
    
    background-color: transparent;
    text-color: @fg-col;
    
    margin: 0;
    padding: 0;
    spacing: 0;
}

window {
    transparency: "real";
    background-color: @bg-col;
    text-color: @fg-col;
    border: 2px;
    border-color: @border-col;
    border-radius: 10px;
}

mainbox {
    children: [inputbar, listview, message];
    background-color: @bg-col;
}

inputbar {
    children: [textbox-prompt-colon, entry];
    background-color: @bg-col;
    border-radius: 5px;
    padding: 5px;
}

textbox-prompt-colon {
    expand: false;
    str: "";
    text-color: @blue;
}

entry {
    font: inherit;
}

listview {
    lines: 10;
    columns: 1;
}

element {
    padding: 5px;
    background-color: @bg-col;
    text-color: @fg-col;
}

element selected {
    background-color: @selected-col;
    text-color: @bg-col-light;
}

element-text {
    background-color: inherit;
    text-color: inherit;
}

element-icon {
    size: 25px;
    background-color: inherit;
}
EOL

# Create welcome app script
cat > ~/.local/bin/welcome-app << EOL
#!/bin/bash

# WehttamSnaps Welcome App

# Colors
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display welcome message
echo -e "${PURPLE}============================================${NC}"
echo -e "${CYAN}      Welcome to WehttamSnaps Hyprland!${NC}"
echo -e "${PURPLE}============================================${NC}"
echo -e ""

# Display system info
echo -e "${BLUE}System Information:${NC}"
echo -e "Hostname: $(hostname)"
echo -e "User: $(whoami)"
echo -e "Kernel: $(uname -r)"
echo -e "Uptime: $(uptime -p | sed 's/up //')"
echo -e ""

# Display keybindings
echo -e "${BLUE}Essential Keybindings:${NC}"
echo -e "Super + Enter        - Open terminal"
echo -e "Super + D            - Application launcher"
echo -e "Super + B            - Open Brave browser"
echo -e "Super + E            - File manager"
echo -e "Super + Q            - Close window"
echo -e "Super + 1-0          - Switch workspaces"
echo -e "Super + Shift + 1-0  - Move window to workspace"
echo -e "Super + P            - Power menu"
echo -e "Super + G            - Enable GameMode"
echo -e "Super + Shift + G    - Disable GameMode"
echo -e "Super + Shift + O    - Open OBS"
echo -e "Super + Shift + S    - Open Streamlabs"
echo -e ""

# Display options
echo -e "${BLUE}Quick Actions:${NC}"
echo -e "1) Update system"
echo -e "2) Check gaming drive"
echo -e "3) Configure gaming apps"
echo -e "4) Open settings"
echo -e "5) Exit"
echo -e ""

read -p "Select an option (1-5): " choice

case $choice in
    1)
        echo -e "${GREEN}Updating system...${NC}"
        yay -Syu
        ;;
    2)
        echo -e "${GREEN}Checking gaming drive...${NC}"
        if mount | grep -q "$GAMES_DRIVE"; then
            echo -e "${GREEN}Gaming drive is mounted at $GAMES_DRIVE${NC}"
            df -h $GAMES_DRIVE
        else
            echo -e "${YELLOW}Gaming drive is not mounted.${NC}"
            echo -e "Attempting to mount..."
            sudo mount $GAMES_DRIVE 2>/dev/null || echo -e "${RED}Failed to mount gaming drive.${NC}"
        fi
        ;;
    3)
        echo -e "${GREEN}Opening gaming configuration...${NC}"
        steam &
        lutris &
        heroic &
        ;;
    4)
        echo -e "${GREEN}Opening settings...${NC}"
        # Add settings launcher here
        ;;
    5)
        echo -e "${GREEN}Exiting welcome app. Happy computing!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Exiting.${NC}"
        exit 1
        ;;
esac
EOL

chmod +x ~/.local/bin/welcome-app

# Create gaming optimization script
cat > ~/.local/bin/gaming-setup << EOL
#!/bin/bash

# WehttamSnaps Gaming Setup Script

echo "Setting up gaming optimizations..."

# Enable FSYNC
sudo echo "wine-staging /usr/bin/wine-staging fsync" | sudo tee /etc/modprobe.d/wine-staging.conf

# Set Vulkan driver
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json

# Configure Gamemode
sudo systemctl enable --now gamemoded.service

# Setup Steam launch options for better performance
STEAM_DIR="$HOME/.steam/steam"
if [ -d "$STEAM_DIR" ]; then
    # Create custom launch options for common games
    cat > "$STEAM_DIR/steamapps/common/Steam Linux Runtime - Soldier/_v2-entry-point" << EOF
#!/bin/bash
export DXVK_ASYNC=1
export WINE_FSYNC=1
export RADV_PERFTEST=aco
exec "\$@"
EOF
    chmod +x "$STEAM_DIR/steamapps/common/Steam Linux Runtime - Soldier/_v2-entry-point"
fi

# Setup Lutris optimizations
LUTRIS_DIR="$HOME/.config/lutris"
if [ -d "$LUTRIS_DIR" ]; then
    cat > "$LUTRIS_DIR/system.yml" << EOF
system:
  env:
    DXVK_ASYNC: 1
    WINE_FSYNC: 1
    RADV_PERFTEST: aco
    VK_ICD_FILENAMES: /usr/share/vulkan/icd.d/radeon_icd.x86_64.json
    __GL_SHADER_DISK_CACHE: 1
    __GL_SHADER_DISK_CACHE_PATH: $HOME/.cache/shader_cache
    mesa_glthread: true
EOF
fi

# Create shader cache directory
mkdir -p ~/.cache/shader_cache

echo "Gaming optimizations applied!"
echo "Note: Some changes may require a restart to take effect."
EOL

chmod +x ~/.local/bin/gaming-setup

# Create streaming setup script
cat > ~/.local/bin/streaming-setup << EOL
#!/bin/bash

# WehttamSnaps Streaming Setup Script

echo "Setting up streaming environment..."

# Create streaming directories
mkdir -p ~/Streaming/{Scenes,Assets,Recordings,Clips,Overlays}

# Setup OBS configuration
OBS_DIR="$HOME/.config/obs-studio"
if [ ! -d "$OBS_DIR" ]; then
    mkdir -p "$OBS_DIR"
fi

# Basic OBS profile setup
cat > "$OBS_DIR/basic/profiles/WehttamSnaps/profile.ini" << EOF
[General]
Name=WehttamSnaps

[Video]
BaseCX=1920
BaseCY=1080
OutputCX=1280
OutputCY=720
FPSCommon=60
ScaleType=bicubic

[Output]
Mode=Advanced

[AdvOutputStream]
Encoder=amd_amf_h264
Rescale=false

[AdvAudio]
Track1Name=Audio
Track2Name=GameAudio
Track3Name=Music
Track4Name=Voice
Track5Name=Desktop
Track6Name=Mic

[AdvVideo]
ColorFormat=NV12
ColorSpace=709
ColorRange=Partial
EOF

# Setup stream key (user will need to add their own)
echo "Please add your streaming service keys to ~/Streaming/stream-keys.txt"
echo "Twitch: " > ~/Streaming/stream-keys.txt
echo "YouTube: " >> ~/Streaming/stream-keys.txt

# Install OBS plugins
echo "Installing OBS plugins..."
yay -S --needed obs-vkcapture obs-websocket

echo "Streaming setup complete!"
echo "Remember to configure your streaming software with your accounts."
EOL

chmod +x ~/.local/bin/streaming-setup

# Create fan control script for your system
cat > ~/.local/bin/fan-control << EOL
#!/bin/bash

# WehttamSnaps Fan Control Script
# For i5-4430 and RX580 temperature management

# Check if lm-sensors is configured
if ! command -v sensors &> /dev/null; then
    echo "lm-sensors not found. Installing..."
    sudo pacman -S --noconfirm lm_sensors
    echo "Please run 'sudo sensors-detect' to configure sensors"
    exit 1
fi

# Function to set fan speed based on temperature
set_fan_speed() {
    local temp=$1
    local speed=$2
    
    # This is a generic example - you'll need to adjust for your specific hardware
    # For AMD GPU (RX580)
    if command -v rocm-smi &> /dev/null; then
        sudo rocm-smi --setfan $speed
    fi
    
    # For CPU fan (may require specific motherboard control)
    echo "Setting fan speed to $speed% for temperature $temp°C"
    
    # Note: CPU fan control often requires motherboard-specific tools
    # You might need to install and use:
    # - thinkfan (for laptops)
    # - fancontrol (part of lm-sensors)
    # - motherboard-specific utilities
}

# Monitor temperatures
monitor_temps() {
    while true; do
        # Get CPU temperature
        cpu_temp=$(sensors | grep 'Package id 0:' | awk '{print $4}' | sed 's/+//' | sed 's/\.0°C//')
        
        # Get GPU temperature
        gpu_temp=$(sensors | grep 'edge:' | awk '{print $2}' | sed 's/+//' | sed 's/\.0°C//')
        
        # Use whichever is hotter
        if [ -z "$gpu_temp" ] || [ "$cpu_temp" -gt "$gpu_temp" ]; then
            temp=$cpu_temp
        else
            temp=$gpu_temp
        fi
        
        # Set fan speed based on temperature
        if [ "$temp" -lt 50 ]; then
            set_fan_speed $temp 30
        elif [ "$temp" -lt 60 ]; then
            set_fan_speed $temp 50
        elif [ "$temp" -lt 70 ]; then
            set_fan_speed $temp 70
        elif [ "$temp" -lt 80 ]; then
            set_fan_speed $temp 85
        else
            set_fan_speed $temp 100
        fi
        
        sleep 10
    done
}

case "$1" in
    start)
        echo "Starting fan control..."
        monitor_temps &
        ;;
    stop)
        echo "Stopping fan control..."
        pkill -f "fan-control start"
        ;;
    status)
        echo "Current temperatures:"
        sensors
        ;;
    *)
        echo "Usage: fan-control {start|stop|status}"
        exit 1
        ;;
esac
EOL

chmod +x ~/.local/bin/fan-control

# Create ZSH configuration
cat > ~/.zshrc << EOL
# WehttamSnaps ZSH Configuration
# Based on HyDE Project with customizations

# Enable Powerlevel10k instant prompt
if [[ -r "\${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh" ]]; then
  source "\${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="\$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    web-search
    copypath
    copyfile
    dirhistory
    history
    sudo
)

source \$ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='nvim'
export VISUAL='nvim'
export BROWSER='brave'

# Path modifications
export PATH="\$HOME/.local/bin:\$PATH"
export PATH="\$HOME/.cargo/bin:\$PATH"
export PATH="\$HOME/.npm-global/bin:\$PATH"

# Gaming environment variables
export DXVK_ASYNC=1
export WINE_FSYNC=1
export RADV_PERFTEST=aco
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_PATH=\$HOME/.cache/shader_cache
export mesa_glthread=true

# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias vim='nvim'
alias update='yay -Syu'
alias clean='yay -Yc && yay -Sc'
alias gaming-setup='~/.local/bin/gaming-setup'
alias streaming-setup='~/.local/bin/streaming-setup'
alias fan-control='~/.local/bin/fan-control'
alias welcome='~/.local/bin/welcome-app'
alias obs='obs-studio'
alias steam='gamemoderun steam'
alias lutris='gamemoderun lutris'
alias heroic='gamemoderun heroic'

# Functions
function stream-start() {
    echo "Starting stream preparation..."
    gamemoded -r &
    obs-studio &
    discord &
    echo "Stream applications launched!"
}

function system-info() {
    echo -e "\033[1;35m===== WehttamSnaps System Info =====\033[0m"
    neofetch
    echo -e "\033[1;35m====================================\033[0m"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Welcome message
echo -e "\033[1;35mWelcome to WehttamSnaps Hyprland, Matt!\033[0m"
echo -e "\033[1;36mType 'welcome' for the welcome app or 'system-info' for system details.\033[0m"
EOL

# Create Starship prompt configuration
cat > ~/.config/starship.toml << EOL
# WehttamSnaps Starship Configuration
# Violet-to-cyan theme

format = """
\$username\
\$hostname\
\$directory\
\$git_branch\
\$git_status\
\$git_state\
\$package\
\$nix_shell\
\$conda\
\$memory_usage\
\$env_var\
\$custom\
\$cmd_duration\
\$line_break\
\$lua\
\$python\
\$ruby\
\$golang\
\$nodejs\
\$rust\
\$haskell\
\$java\
\$c\
\$cmake\
\$docker_context\
\$dotnet\
\$elixir\
\$elm\
\$erlang\
\$gcloud\
\$helm\
\$kubernetes\
\$nim\
\$ocaml\
\$php\
\$pulumi\
\$rlang\
\$red\
\$scala\
\$swift\
\$terraform\
\$vlang\
\$vagrant\
\$zig\
\$buf\
\$nix_shell\
\$status\
\$character"""

[character]
success_symbol = "[➜](bold purple)"
error_symbol = "[➜](bold red)"
vicmd_symbol = "[V](bold green)"

[directory]
truncation_length = 3
truncate_to_repo = false
style = "bold cyan"

[git_branch]
symbol = "🌱 "
style = "bold purple"

[git_status]
ahead = "⇡\${count}"
diverged = "⇕⇡\${ahead_count}⇣\${behind_count}"
behind = "⇣\${count}"
conflicted = "≠\${count}"
untracked = "?\${count}"
stashed = "≡\${count}"
modified = "!\${count}"
staged = "+\${count}"
renamed = "→\${count}"
deleted = "✘\${count}"
style = "cyan"

[hostname]
ssh_only = false
format = "[$hostname](bold blue) "
disabled = false

[username]
show_always = true
style_user = "bold purple"
style_root = "bold red"
format = "[$user]($style)"

[cmd_duration]
format = "took [$duration]($style) "
style = "bold yellow"

[memory_usage]
format = "mem: $symbol[\${ram}]($style) "
threshold = 50
style = "bold purple"

[status]
format = "[$symbol$status]($style) "
symbol = "🔴"
success_symbol = "🟢"
disabled = false

[package]
format = "[$symbol$version]($style) "
symbol = "📦 "
style = "bold purple"
EOL

# Create custom wallpaper
# This creates a simple gradient wallpaper using ImageMagick
sudo pacman -S --noconfirm imagemagick
convert -size 1920x1080 gradient:\#8A2BE2-\#00FFFF ~/Pictures/Wallpapers/wehttamsnaps-gradient.png

# Set up Hyprpaper
cat > ~/.config/hypr/hyprpaper.conf << EOL
preload = ~/Pictures/Wallpapers/wehttamsnaps-gradient.png
wallpaper = ,~/Pictures/Wallpapers/wehttamsnaps-gradient.png
EOL

# Setup SDDM theme
sudo pacman -S --noconfirm sddm sugar-candy
sudo cat > /etc/sddm.conf << EOL
[Theme]
Current=sugar-candy
EOL

# Customize SDDM theme
sudo cat > /usr/share/sddm/themes/sugar-candy/theme.conf.user << EOL
[General]
background=~/Pictures/Wallpapers/wehttamsnaps-gradient.png
mainColor=8A2BE2
accentColor=00FFFF
font="JetBrains Mono"
headerText="WehttamSnaps"
EOL

# Enable services
print_color "Enabling services..." "$BLUE"
sudo systemctl enable sddm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable fstrim.timer
sudo systemctl enable docker
sudo systemctl enable ufw

# Configure firewall
print_color "Configuring firewall..." "$BLUE"
sudo ufw default deny
sudo ufw allow SSH
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Setup Docker without sudo
sudo usermod -aG docker $USERNAME

# Final setup steps
print_color "Running final setup steps..." "$BLUE"

# Setup ZRAM
sudo tee /etc/systemd/zram-generator.conf > /dev/null << EOL
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOL

# Setup gaming drive permissions
sudo chown -R $USERNAME:$USERNAME $GAMES_DRIVE

# Create initial welcome message
cat > ~/WELCOME.md << EOL
# Welcome to WehttamSnaps Hyprland Setup!

## Your system has been configured with:

### Core Components
- Hyprland with TokyoNight-inspired violet-to-cyan theme
- Waybar with custom modules for gaming and streaming
- Rofi application launcher with power menu
- Kitty terminal with Starship prompt
- ZSH with custom plugins and aliases

### Gaming Setup
- Steam, Lutris, and Heroic Games Launcher
- AMD gaming optimizations (FSYNC, Vulkan)
- Gamemode for performance boosting
- Gamescope for enhanced gaming experience
- Steam Tinker Launch for mod management

### Streaming Setup
- OBS Studio with plugins
- Streamlabs Desktop
- Custom streaming scripts and configurations

### Custom Applications
- Welcome app (run 'welcome' in terminal)
- Gaming setup script (run 'gaming-setup')
- Streaming setup script (run 'streaming-setup')
- Fan control script (run 'fan-control')

### Keybindings
- Super + Enter: Terminal
- Super + D: Application launcher
- Super + B: Brave browser
- Super + E: File manager
- Super + G: Enable GameMode
- Super + Shift + G: Disable GameMode
- Super + P: Power menu

### Next Steps:
1. Reboot your system to apply all changes
2. Run 'welcome' to see the welcome app
3. Configure your gaming applications
4. Set up your streaming software with your accounts
5. Customize your setup further as needed

Enjoy your new WehttamSnaps Hyprland setup!

- Matt / WehttamSnaps
EOL

print_color "Setup complete!" "$GREEN"
print_color "Please review ~/WELCOME.md for next steps and information about your new setup." "$BLUE"
print_color "Reboot your system to start using Hyprland with your new configuration." "$PURPLE"

# Make scripts executable
chmod +x ~/.local/bin/*

echo "Installation completed successfully!"
```

## Post-Installation Instructions

After running the script, here are the manual steps you should take:

1. **Reboot your system** to start with Hyprland
2. **Configure your gaming applications**:
   ```bash
   gaming-setup
   steam
   lutris
   heroic
   ```

3. **Set up streaming**:
   ```bash
   streaming-setup
   obs
   ```

4. **Configure fan control** (may require additional setup):
   ```bash
   sudo sensors-detect
   fan-control start
   ```

5. **Customize your setup**:
   - Edit `~/.config/hypr/hyprland.conf` for Hyprland settings
   - Edit `~/.config/waybar/config` for taskbar customization
   - Edit `~/.zshrc` for shell preferences

## Key Features of This Setup

1. **Visual Theme**: Violet-to-cyan gradient throughout the system
2. **Gaming Optimizations**: AMD-specific tweaks for better performance
3. **Streaming Ready**: Pre-configured OBS and streaming tools
4. **Custom Apps**: Welcome app, gaming setup, streaming setup, and fan control
5. **Hyprland Configuration**: Based on HyDE project with your customizations
6. **Waybar**: Customized with gaming and streaming modules
7. **ZSH Setup**: Optimized shell with useful aliases and functions

## Additional Recommendations

1. **For modding games**:
   - Use Steam Tinker Launch for Vortex and MO2 integration
   - Configure mod managers for each game individually

2. **For temperature monitoring**:
   - Install `corectrl` for GPU monitoring and overclocking
   - Use `radeon-profile` for AMD GPU control

3. **For streaming**:
   - Consider a stream deck alternative using `streamdeck-ui`
   - Set up chatbot and alerts for your streams

This setup provides a comprehensive foundation for both your photography workflow and gaming/streaming activities, all with your preferred color scheme and organizational preferences.
