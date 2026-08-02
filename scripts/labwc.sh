#!/usr/bin/env bash

# ──────────────────────────────────────────────
# Forçar execução com bash (antes do set -euo pipefail)
# ──────────────────────────────────────────────
if [ -z "$BASH_VERSION" ]; then
  echo -e "\033[0;31m✘\033[0m Este script precisa ser executado com bash, não com sh."
  echo "  Use: bash labwc.sh"
  exit 1
fi

set -euo pipefail

# ──────────────────────────────────────────────
# Cores e funções
# ──────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; MAG='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

step()  {
  echo ""
  echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  ${CYAN}┃${NC} ${MAG}★${NC} ${BOLD}$1${NC}"
  echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
info()  { echo -e "  ${CYAN}→${NC} $1"; }
ok()    { echo -e "  ${GREEN}✔${NC} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; }
err()   { echo -e "  ${RED}✘${NC} $1"; }

run() {
  info "$1"
  shift
  "$@"
  echo -e "  ${GREEN}✔${NC} concluído"
}

quote() {
  local quotes=(
    "O terminal é o melhor amigo do admin. — ditado popular"
    "Se não quebrou, você não mexeu o suficiente. — Lei de Murphy"
    "Linux: porque um terminal é mais leve que 5 cliques."
    "Arch btw. — todo usuário Arch"
    "Wayland é o futuro. E ele chegou."
    "Labwc: o compositor leve que usa o rc.xml que você já conhece."
    "Sway por um lado, Openbox por outro — Labwc no meio."
    "Leve, estável e configurável. Quem precisa de mais?"
    "Pacman -Syu resolve. Sempre."
    "RTFM: a documentação é sua melhor amiga."
    "Sudo faz tudo. Inclusive café. — quase."
    "Systemd: amado por uns, odiado por outros, usado por todos."
    "AUR: porque no AUR tem de tudo, até alma gêmea."
    "Yay — porque compilar na mão é coisa do passado."
    "Tema escuro é mais que preferência, é estilo de vida."
  )
  echo -e "  ${YELLOW}💬${NC} ${quotes[$RANDOM % ${#quotes[@]}]}"
}

banner() {
  echo ""
  echo -e "  ${RED}██╗${GREEN}     ${YELLOW}██╗${BLUE}██╗${MAG} ██████╗ ${RED}██╗${GREEN}  ${YELLOW}██╗${BLUE} ██████╗ ${MAG}██████╗ "
  echo -e "  ${RED}██║${GREEN}     ${YELLOW}██║${BLUE}██║${MAG}██╔════╝ ${RED}██║${GREEN}  ${YELLOW}██║${BLUE}██╔═══██╗${MAG}██╔══██╗"
  echo -e "  ${RED}██║${GREEN} ██╗ ${YELLOW}██║${BLUE}██║${MAG}██║      ${RED}██║${GREEN}  ${YELLOW}██║${BLUE}██║   ██║${MAG}██████╔╝"
  echo -e "  ${RED}██║${GREEN} ██║ ${YELLOW}██║${BLUE}██║${MAG}██║      ${RED}██║${GREEN}  ${YELLOW}██║${BLUE}██║   ██║${MAG}██╔══██╗"
  echo -e "  ${RED}██║${GREEN}██╔╝ ${YELLOW}██║${BLUE}██║${MAG}╚██████╗ ${RED}██║${GREEN}  ${YELLOW}██║${BLUE}╚██████╔╝${MAG}██████╔╝"
  echo -e "  ${RED}╚═╝${GREEN}╚═╝  ${YELLOW}╚═╝${BLUE}╚═╝${MAG} ╚═════╝ ${RED}╚═╝${GREEN}  ${YELLOW}╚═╝${BLUE} ╚═════╝ ${MAG}╚═════╝ "
  echo -e "${NC}"
  echo -e "  ${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "  ${CYAN}▓${NC}            ${BOLD}Labwc + Waybar${NC}            ${CYAN}▓${NC}"
  echo -e "  ${CYAN}▓${NC}     ${YELLOW}Instalação Completa — Arch Linux${NC}    ${CYAN}▓${NC}"
  echo -e "  ${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "  ${MAG}✦${NC}  ${BOLD}By eusouobn${NC}  ${MAG}✦${NC}"
  echo ""
  quote
  echo ""
}

# ──────────────────────────────────────────────
# Verificação: não rodar como root
# ──────────────────────────────────────────────
if [ "$EUID" -eq 0 ]; then
  echo -e "\033[0;31m✘\033[0m NÃO execute este script como root (sudo)."
  echo "  Execute como usuário normal. O script usará sudo automaticamente."
  exit 1
fi

# ──────────────────────────────────────────────
# --reset: limpa tudo antes de reinstalar
# ──────────────────────────────────────────────
RESET_MODE=false
for arg in "$@"; do
  case "$arg" in
    --reset) RESET_MODE=true ;;
  esac
done

if [ "$RESET_MODE" = true ]; then
  echo ""
  echo -e "  ${RED}███  MODO RESET  ███${NC}"
  echo ""
  echo -e "  ${YELLOW}⚠${NC} Isso vai APAGAR completamente:"
  echo -e "     ~/.config/labwc/"
  echo -e "     ~/.config/waybar/"
  echo -e "     ~/.config/fuzzel/"
  echo -e "     ~/.config/nwg-look/"
  echo -e "     ~/.config/gtk-3.0/ ~/.config/gtk-4.0/"
  echo -e "     ~/.config/xsettingsd/ ~/.config/kdeglobals"
  echo -e "     ~/.config/scripts/"
  echo -e "     /tmp/labwc-dotfiles/"
  echo ""
  echo -n "  ${RED}⌨${NC} Tem certeza? (digite ${BOLD}SIM${NC} para confirmar): "
  read -r CONFIRM
  if [ "$CONFIRM" != "SIM" ]; then
    echo -e "  ${GREEN}✔${NC} Cancelado."
    exit 0
  fi

  echo ""
  echo -e "  ${RED}→${NC} Limpando configs antigas..."
  rm -rf "$HOME/.config/labwc"
  rm -rf "$HOME/.config/waybar"
  rm -rf "$HOME/.config/fuzzel"
  rm -rf "$HOME/.config/nwg-look"
  rm -rf "$HOME/.config/gtk-3.0"
  rm -rf "$HOME/.config/gtk-4.0"
  rm -rf "$HOME/.config/xsettingsd"
  rm -rf "$HOME/.config/scripts"
  rm -f  "$HOME/.config/kdeglobals"
  rm -rf /tmp/labwc-dotfiles

  # Re-clonar dotfiles limpos do GitHub
  echo -e "  ${CYAN}→${NC} Re-clonando dotfiles do GitHub..."
  git clone https://github.com/eusouobn/labwc.git /tmp/labwc-dotfiles
  mkdir -p "$HOME/.config"
  cp -r /tmp/labwc-dotfiles/.config/* "$HOME/.config/"
  chmod +x "$HOME/.config/scripts/"*.sh 2>/dev/null || true
  ok "Dotfiles limpos restaurados do GitHub"
  echo ""
  echo -e "  ${GREEN}✔${NC} Reset completo! Continuando com instalação..."
  echo ""
fi

# ──────────────────────────────────────────────
# 1. Boas-vindas
# ──────────────────────────────────────────────
banner

echo -e "  ${YELLOW}⚠${NC} Este script irá transformar seu Arch recém-instalado"
echo -e "     em um ambiente Labwc + Waybar completo."
echo -e "  ${YELLOW}⚠${NC} Certifique-se de estar conectado à internet."
echo ""
echo -n "  ${CYAN}⌨${NC} Pressione ENTER para iniciar a instalação... "
read -r
echo ""

# ──────────────────────────────────────────────
# Verificar sudo
# ──────────────────────────────────────────────
if ! command -v sudo &>/dev/null; then
  echo -e "\033[0;31m✘\033[0m 'sudo' não está instalado."
  echo "  Entre como root e instale: pacman -S sudo"
  echo "  Depois configure: echo \"$USER ALL=(ALL) ALL\" >> /etc/sudoers"
  exit 1
fi

info "Verificando acesso sudo... (digite sua senha se solicitado)"
if ! sudo -v; then
  echo -e "\033[0;31m✘\033[0m Você não tem permissão sudo."
  echo "  Entre como root e configure: echo \"$USER ALL=(ALL) ALL\" >> /etc/sudoers"
  exit 1
fi
ok "Acesso sudo confirmado"

# ──────────────────────────────────────────────
# 2. Detectar pendrive com configs
# ──────────────────────────────────────────────
step "🔍 Procurando backup em pendrive..."

PENDRIVE=""
for mount in /run/media/"$USER"/* /mnt/* /media/*; do
  [ -d "$mount" ] && [ -f "$mount/labwc.tar.gz" ] && PENDRIVE="$mount" && break
done

if [ -n "$PENDRIVE" ]; then
  info "Pendrive detectado em: $PENDRIVE"
  quote
else
  warn "Nenhum pendrive com labwc.tar.gz encontrado."
  warn "Suas configs serão restauradas do git (se disponível)."
fi

# ──────────────────────────────────────────────
# 3. Otimizar compilação + ferramentas básicas
# ──────────────────────────────────────────────
step "⚙️ Otimizando sistema para compilação..."

run "Sincronizando bancos e instalando nano, git..." sudo pacman -Sy --needed --noconfirm nano git

if ! sudo pacman -Qi base-devel &>/dev/null; then
  run "Instalando base-devel..." sudo pacman -S --needed --noconfirm base-devel
fi

CORES=$(nproc)
MAKEFLAGS="-j$((CORES + 1))"
if grep -q "^#MAKEFLAGS" /etc/makepkg.conf 2>/dev/null; then
  sudo sed -i "s/^#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"$MAKEFLAGS\"/" /etc/makepkg.conf
  ok "MAKEFLAGS ajustado para $MAKEFLAGS ($CORES núcleos + 1)"
elif ! grep -q "^MAKEFLAGS" /etc/makepkg.conf 2>/dev/null; then
  echo "MAKEFLAGS=\"$MAKEFLAGS\"" | sudo tee -a /etc/makepkg.conf > /dev/null
  ok "MAKEFLAGS definido como $MAKEFLAGS"
else
  info "MAKEFLAGS já configurado"
fi

if ! command -v yay &>/dev/null; then
  info "Preparando AUR helper (yay)..."
  rm -rf /tmp/yay-bin
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
  rm -rf /tmp/yay-bin
  ok "yay instalado com sucesso"
  quote
fi

# ──────────────────────────────────────────────
# 4. Pacotes oficiais
# ──────────────────────────────────────────────
OFFICIAL_PACKAGES=(
  # ── Compositor / WM ──
  labwc waybar swaybg
  nwg-look wlr-randr grim slurp wl-clipboard
  fuzzel dmenu
  konsole alacritty

  # ── Arquivos / utilitários ──
  ark kde-cli-tools
  unrar unzip ntfs-3g exfat-utils dosfstools
  dolphin dolphin-plugins kio-admin kate
  xdg-user-dirs xdg-utils

  # ── Apps ──
  firefox firefox-i18n-pt-br telegram-desktop mpv audacious gimp obs-studio
  gsmartcontrol kdiskmark psensor htop hwinfo fastfetch
  kcalc gwenview uget gnome-disk-utility

  # ── Rede ──
  networkmanager network-manager-applet wpa_supplicant ethtool
  inetutils nss-mdns

  # ── Áudio ──
  pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber
  pavucontrol alsa-utils alsa-firmware libpulse

  # ── Bluetooth ──
  bluez bluez-utils

  # ── Impressão ──
  cups print-manager system-config-printer hplip python-pyqt5

  # ── GNOME VFS ──
  gvfs gvfs-afc gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb

  # ── Drivers / GPU (AMD) ──
  xf86-video-amdgpu xf86-video-ati
  vulkan-radeon lib32-vulkan-radeon lib32-vulkan-icd-loader
  lib32-mesa mesa-demos mesa-utils libva-utils
  xorg-xdpyinfo amd-ucode

  # ── Temas / fontes ──
  papirus-icon-theme
  ttf-ubuntu-font-family ttf-ubuntu-nerd ttf-firacode-nerd

  # ── Codecs / multimídia ──
  a52dec faac faad2 frei0r-plugins libdca libdv libmad
  libmpeg2 movit wavpack
  jasper libtheora x264 xvidcore
  ffmpeg ffmpegthumbnailer
  gst-libav gst-plugin-pipewire gst-plugins-base gst-plugins-good
  gst-plugins-bad gst-plugins-ugly

  # ── Sistema ──
  base base-devel git nano sudo vim wget
  linux linux-firmware mkinitcpio grub efibootmgr
  fwupd sysfsutils smartmontools fuse2 glfw go
  android-tools android-udev usbutils
  python-pip python-pipx tk
  opencode lightdm lightdm-gtk-greeter
)

step "📦 Instalando pacotes oficiais..."
info "${#OFFICIAL_PACKAGES[@]} pacotes — isso pode levar alguns minutos..."
info "Labwc, Waybar, Thunar, Dolphin, Firefox, áudio, Bluetooth, impressão..."
echo ""

sudo pacman -S --needed --noconfirm "${OFFICIAL_PACKAGES[@]}"
echo ""
ok "Pacotes oficiais instalados"
quote

# ──────────────────────────────────────────────
# 4b. Pacotes AUR
# ──────────────────────────────────────────────
AUR_PACKAGES=(
  openbox-themes
)

step "🌟 Instalando pacotes AUR..."
info "openbox-themes (temas de decoração para o Labwc)..."
echo ""

# Verificar se yay está instalado
if ! command -v yay &>/dev/null; then
  warn "yay não encontrado — instalando..."
  rm -rf /tmp/yay-bin
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  (cd /tmp/yay-bin && makepkg -si --noconfirm)
  rm -rf /tmp/yay-bin
fi

yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
echo ""
ok "Pacotes AUR instalados"
quote

# ──────────────────────────────────────────────
# 5. Nerd Fonts
# ──────────────────────────────────────────────
NERD_FONTS=(
  ttf-firacode-nerd
  ttf-ubuntu-nerd
)

step "🔤 Instalando Nerd Fonts..."
info "FiraCode Nerd + Ubuntu Nerd..."
echo ""

sudo pacman -S --needed --noconfirm "${NERD_FONTS[@]}"
echo ""
run "Atualizando cache de fontes..." sudo fc-cache -f
ok "Nerd Fonts instaladas — seu terminal nunca mais será o mesmo"
quote

# ──────────────────────────────────────────────
# 5b. Verificar instalação do Labwc
# ──────────────────────────────────────────────
step "🔍 Verificando instalação do Labwc..."

if command -v labwc &>/dev/null; then
  ok "Labwc detectado: $(labwc --version 2>/dev/null || echo 'versão desconhecida')"
else
  err "Labwc não encontrado no PATH."
  info "Instale manualmente: sudo pacman -S labwc"
fi
quote

# ──────────────────────────────────────────────
# 6. Clonar dotfiles do GitHub (sempre sobrescrever)
# ──────────────────────────────────────────────
step "📥 Baixando dotfiles do GitHub..."
info "De https://github.com/eusouobn/labwc.git"
echo ""

# Clonar e copiar (sempre sobrescreve)
rm -rf /tmp/labwc-dotfiles
git clone https://github.com/eusouobn/labwc.git /tmp/labwc-dotfiles
mkdir -p "$HOME/.config"
cp -r /tmp/labwc-dotfiles/.config/* "$HOME/.config/"

ok "Dotfiles baixados do GitHub!"

# Tornar scripts executáveis
chmod +x "$HOME/.config/scripts/"*.sh 2>/dev/null || true
ok "Scripts tornados executáveis"
quote

# ──────────────────────────────────────────────
# 6a. Corrigir caminhos absolutos para o usuário atual
# ──────────────────────────────────────────────
step "🔄 Adaptando configs para seu usuário..."
info "Substituindo caminhos absolutos para o usuário atual"
find "$HOME/.config" -type f \( -name "*.json" -o -name "*.conf" -o -name "*.ini" \) \
  -exec sed -i "s|/home/[^/]*/|$HOME/|g" {} + 2>/dev/null || true
ok "Caminhos ajustados para $USER"
quote

# ──────────────────────────────────────────────
# 6b. Instalar arquivos do etc/ (hooks, udev, udisks2)
# ──────────────────────────────────────────────
step "⚙️ Instalando hooks e regras do sistema..."

DOTFILES_REPO="/tmp/labwc-dotfiles"
if [ ! -d "$DOTFILES_REPO" ]; then
  git clone --depth=1 https://github.com/eusouobn/labwc.git "$DOTFILES_REPO" 2>/dev/null || true
fi

# Hook do pacman — reconstruir cache KDE automaticamente
if [ -f "$DOTFILES_REPO/etc/pacman.d/hooks/kde-cache.hook" ]; then
  sudo mkdir -p /etc/pacman.d/hooks
  sudo cp "$DOTFILES_REPO/etc/pacman.d/hooks/kde-cache.hook" /etc/pacman.d/hooks/
  ok "Hook instalado — kbuildsycoca6 roda após toda transação do pacman"
fi

# Udisks2 — escrita síncrona para USB
if [ -f "$DOTFILES_REPO/etc/udisks2/mount_options.conf" ]; then
  sudo mkdir -p /etc/udisks2
  sudo cp "$DOTFILES_REPO/etc/udisks2/mount_options.conf" /etc/udisks2/
  sudo systemctl restart udisks2 2>/dev/null || true
  ok "udisks2 configurado — USBs escrevem direto no disco (sem cache)"
fi

# Botão Power com countdown
if [ -f "$DOTFILES_REPO/etc/udev/rules.d/power-button.sh" ]; then
  sudo install -Dm755 "$DOTFILES_REPO/etc/udev/rules.d/power-button.sh" /usr/local/bin/power-button.sh
  sudo cp "$DOTFILES_REPO/etc/systemd/system/power-button.service" /etc/systemd/system/power-button.service
  sudo cp "$DOTFILES_REPO/etc/udev/rules.d/99-power-button.rules" /etc/udev/rules.d/99-power-button.rules
  sudo udevadm control --reload-rules 2>/dev/null || true
  sudo systemctl daemon-reload 2>/dev/null || true
  ok "Botão Power: desligamento com 10s de delay + notificação"
fi
quote

# ──────────────────────────────────────────────
# 6c. Configuração NVIDIA para Wayland
# ──────────────────────────────────────────────
if lspci | grep -qi nvidia; then
  step "🎮 Configurando NVIDIA para Wayland..."

  # Kernel parameters para NVIDIA + Wayland
  if [ -f /etc/default/grub ]; then
    if ! grep -q "nvidia_drm.modeset=1" /etc/default/grub; then
      sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1 nvidia_drm.fbdev=1"/' /etc/default/grub
      sudo grub-mkconfig -o /boot/grub/grub.cfg
      ok "GRUB: nvidia_drm.modeset=1 adicionado"
    else
      info "GRUB já configurado para NVIDIA"
    fi
  fi

  # Modprobe para NVIDIA
  sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<'EOF'
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia_drm modeset=1 fbdev=1
EOF
  ok "Modprobe: nvidia.conf configurado"

  # Instalar headers do kernel para compilar módulos NVIDIA
  KERNEL_PKG=$(pacman -Q linux 2>/dev/null | awk '{print $1}')
  if [ -n "$KERNEL_PKG" ]; then
    sudo pacman -S --needed --noconfirm "${KERNEL_PKG}-headers"
    ok "Headers do kernel instalados"
  fi

  # Hooks do initramfs
  sudo mkdir -p /etc/mkinitcpio.conf.d
  sudo tee /etc/mkinitcpio.conf.d/nvidia.conf > /dev/null <<'EOF'
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
EOF
  sudo mkinitcpio -P
  ok "Initramfs: módulos NVIDIA incluídos"

  # Variáveis de ambiente para Wayland
  sudo mkdir -p /etc/environment.d
  sudo tee /etc/environment.d/nvidia.conf > /dev/null <<'EOF'
LIBVA_DRIVER_NAME=nvidia
NVD_BACKEND=direct
__GLX_VENDOR_LIBRARY_NAME=nvidia
GBM_BACKEND=nvidia-drm
EOF
  mkdir -p "$HOME/.config/environment.d"
  cp /etc/environment.d/nvidia.conf "$HOME/.config/environment.d/nvidia.conf"
  ok "Variáveis de ambiente NVIDIA configuradas"

  info "Reinicie para aplicar as mudanças do NVIDIA"
  quote
fi

# ──────────────────────────────────────────────
# 7. LightDM
# ──────────────────────────────────────────────
step "🚀 Configurando LightDM..."

sudo mkdir -p /etc/lightdm
if grep -q "^greeter-session=lightdm-gtk-greeter" /etc/lightdm/lightdm.conf 2>/dev/null; then
  info "LightDM greeter já configurado"
else
  sudo sed -i 's/^#greeter-session=.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf 2>/dev/null || true
  echo "greeter-session=lightdm-gtk-greeter" | sudo tee -a /etc/lightdm/lightdm.conf > /dev/null
  ok "LightDM com greeter GTK configurado"
fi

if [ -n "$PENDRIVE" ] && [ -f "$PENDRIVE/lightdm.conf.tar.gz" ]; then
  sudo tar -xzf "$PENDRIVE/lightdm.conf.tar.gz" -C /etc/
  info "Configurações do LightDM restauradas do pendrive"
fi
quote

# ──────────────────────────────────────────────
# 8. Ativar serviços
# ──────────────────────────────────────────────
step "⚡ Ativando serviços do sistema..."

info "Bluetooth..."
sudo systemctl enable --now bluetooth || true
ok "Bluetooth ativado"

info "PipeWire (áudio)..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>&1 || true
ok "PipeWire ativado"

info "LightDM (login)..."
sudo systemctl enable lightdm 2>&1 || true
ok "LightDM pronto para iniciar"

quote

# ──────────────────────────────────────────────
# 8b. Configurar gerenciamento de energia
# ──────────────────────────────────────────────
step "🔋 Configurando gerenciamento de energia..."

# Desabilitar suspensão automática do systemd-logind
if [ -f /etc/systemd/logind.conf ]; then
  sudo cp /etc/systemd/logind.conf /etc/systemd/logind.conf.bak 2>/dev/null || true
fi

sudo tee /etc/systemd/logind.conf > /dev/null <<'LOGIND'
[Login]
# Não suspender/hibernar em idle — apenas desligar monitor
IdleAction=ignore
IdleActionSec=infinity
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
# Botão Power: ignora logind (script customizado via udev)
HandlePowerKey=ignore
LOGIND

ok "systemd-logind configurado: sem suspensão automática"

info "Monitor será desligado após 30 minutos de inatividade"
info "Sistema NÃO será suspenso ou hibernado"
quote

# ──────────────────────────────────────────────
# 9. Configurar tema escuro
# ──────────────────────────────────────────────
step "🌙 Aplicando tema escuro..."

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

write_gtk_dark() {
  cat > "$1" << 'EOF'
[Settings]
gtk-theme-name=Arc-Darkest
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Ubuntu 12
gtk-cursor-theme-name=Adwaita
gtk-application-prefer-dark-theme=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF
}

write_gtk_dark "$HOME/.config/gtk-3.0/settings.ini"
write_gtk_dark "$HOME/.config/gtk-4.0/settings.ini"

command -v nwg-look &>/dev/null && nwg-look -a 2>&1 || true

# Reforça dark theme (nwg-look pode sobrescrever)
write_gtk_dark "$HOME/.config/gtk-3.0/settings.ini"
write_gtk_dark "$HOME/.config/gtk-4.0/settings.ini"

# Sincronizar com gsettings (Firefox e apps GNOME leem daqui)
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Darkest' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
  ok "gsettings sincronizado (gtk-theme, color-scheme, icon-theme)"
fi

# Papirus-Dark no kdeglobals (Dolphin/KDE)
mkdir -p "$HOME/.config"
if [ -f "$HOME/.config/kdeglobals" ]; then
  if grep -q "^\[Icons\]" "$HOME/.config/kdeglobals"; then
    if grep -q "^Theme=" "$HOME/.config/kdeglobals"; then
      sed -i 's/^Theme=.*/Theme=Papirus-Dark/' "$HOME/.config/kdeglobals"
    else
      sed -i '/^\[Icons\]/a Theme=Papirus-Dark' "$HOME/.config/kdeglobals"
    fi
  else
    echo -e "\n[Icons]\nTheme=Papirus-Dark" >> "$HOME/.config/kdeglobals"
  fi
fi

# Garantir que Papirus-Dark está instalado (pacote oficial)
if pacman -Qi papirus-icon-theme &>/dev/null; then
  ok "Papirus-Dark já instalado via pacman"
else
  warn "Papirus-Dark não encontrado — instale: sudo pacman -S papirus-icon-theme"
fi

command -v nwg-look &>/dev/null && nwg-look -a > /dev/null 2>&1 || true
ok "Tema escuro aplicado — suave para os olhos"
quote

# ──────────────────────────────────────────────
# 10. Apps padrão
# ──────────────────────────────────────────────
step "🐬 Definindo apps padrão..."
info "Associando pastas ao Dolphin..."
xdg-mime default org.kde.dolphin.desktop inode/directory
xdg-mime default org.kde.dolphin.desktop x-scheme-handler/trash

# mpv — vídeos
xdg-mime default mpv.desktop video/mp4
xdg-mime default mpv.desktop video/x-matroska
xdg-mime default mpv.desktop video/webm
xdg-mime default mpv.desktop video/x-msvideo
xdg-mime default mpv.desktop video/quicktime
xdg-mime default mpv.desktop video/x-flv

# audacious — áudio
xdg-mime default audacious.desktop audio/mpeg
xdg-mime default audacious.desktop audio/x-flac
xdg-mime default audacious.desktop audio/ogg
xdg-mime default audacious.desktop audio/x-wav
xdg-mime default audacious.desktop audio/aac
xdg-mime default audacious.desktop audio/mp4

# gwenview — imagens
xdg-mime default org.kde.gwenview.desktop image/png
xdg-mime default org.kde.gwenview.desktop image/jpeg
xdg-mime default org.kde.gwenview.desktop image/gif
xdg-mime default org.kde.gwenview.desktop image/webp
xdg-mime default org.kde.gwenview.desktop image/bmp
xdg-mime default org.kde.gwenview.desktop image/svg+xml

# kate — texto
xdg-mime default org.kde.kate.desktop text/plain
xdg-mime default org.kde.kate.desktop application/xml
xdg-mime default org.kde.kate.desktop application/x-shellscript

ok "Apps padrão: Dolphin, mpv, audacious, gwenview, kate"
quote

# ──────────────────────────────────────────────
# 10b. Firefox dark mode
# ──────────────────────────────────────────────
step "🔥 Configurando dark mode do Firefox..."

FF_LIB="/usr/lib/firefox"
if [ -d "$FF_LIB" ]; then
  sudo mkdir -p "$FF_LIB/defaults/pref"
  sudo tee "$FF_LIB/defaults/pref/autoconfig.js" > /dev/null << 'FFPREFEOF'
pref("general.config.filename", "autoconfig.cfg");
pref("general.config.obscure_value", 0);
pref("general.config.sandbox_enabled", false);
FFPREFEOF

  # autoconfig.cfg — segue o tema GTK automaticamente
  sudo tee "$FF_LIB/autoconfig.cfg" > /dev/null << 'FFCFGEOF'
// Segue o tema GTK (0=light, 1=dark, 2=auto/GTK)
defaultPref("ui.systemUsesDarkTheme", 2);
FFCFGEOF
  ok "Firefox: segue tema GTK automaticamente"
fi

# Para profiles existentes — injeta user.js
for prof_dir in "$HOME"/.mozilla/firefox/*.default-release; do
  [ -d "$prof_dir" ] || continue
  cat > "$prof_dir/user.js" << 'FFUSEREOF'
user_pref("ui.systemUsesDarkTheme", 2);
FFUSEREOF
  ok "Firefox dark mode: $prof_dir"
done 2>/dev/null || true
quote

# ──────────────────────────────────────────────
# 11. Auto-detecção de monitor + escala
# ──────────────────────────────────────────────
step "🖥️ Detectando monitores e configurando escala..."

# Função: detectar monitores via kernel DRM
detect_monitors() {
  local monitors=()

  for card in /sys/class/drm/card*-*/; do
    [ -d "$card" ] || continue
    local status_file="${card}status"
    [ -f "$status_file" ] || continue
    local status
    status=$(cat "$status_file" 2>/dev/null)
    [ "$status" = "connected" ] || continue
    local output_name
    output_name=$(basename "$card" | sed 's/card[0-9]*-//')
    monitors+=("$output_name")
  done

  if [ ${#monitors[@]} -eq 0 ]; then
    echo ""
    return 1
  fi

  # Para cada monitor detectado, pegar resolução e refresh rate
  for output in "${monitors[@]}"; do
    local width="" height="" refresh=""

    local card_dir=""
    for card in /sys/class/drm/card*-*/; do
      [ -d "$card" ] || continue
      local out_name
      out_name=$(basename "$card" | sed 's/card[0-9]*-//')
      if [ "$out_name" = "$output" ]; then
        card_dir="$card"
        break
      fi
    done

    if [ -n "$card_dir" ]; then
      # Ler EDID para resolução nativa
      if [ -f "${card_dir}edid" ]; then
        local edid_hex
        edid_hex=$(xxd -p "${card_dir}edid" 2>/dev/null)
        local edid_bin
        edid_bin=$(echo "$edid_hex" | xxd -r -p 2>/dev/null)

        # Procurar por descriptor com resolução
        local i
        for i in 54 72 90 108 126; do
          local tag
          tag=$(echo "$edid_bin" | dd bs=1 count=1 skip=$i 2>/dev/null | xxd -p)
          if [ "$tag" = "000000000000" ]; then
            local w h
            w=$(printf '%d' "0x$(echo "$edid_bin" | dd bs=1 count=1 skip=$((i+2)) 2>/dev/null | xxd -p)")
            h=$(printf '%d' "0x$(echo "$edid_bin" | dd bs=1 count=1 skip=$((i+1)) 2>/dev/null | xxd -p)")
            if [ "$w" -gt 0 ] && [ "$h" -gt 0 ]; then
              width=$w
              height=$h
              break
            fi
          fi
        done
      fi

      # Fallback: ler preferred mode do kernel
      if [ -z "$width" ] && [ -f "${card_dir}modes" ]; then
        local first_mode
        first_mode=$(head -1 "${card_dir}modes" 2>/dev/null)
        if [ -n "$first_mode" ]; then
          width=$(echo "$first_mode" | cut -d'x' -f1)
          height=$(echo "$first_mode" | cut -d'x' -f2 | cut -d' ' -f1)
        fi
      fi

      # Ler refresh rate (maior disponível)
      if [ -z "$refresh" ] && [ -f "${card_dir}modes" ]; then
        local best_refresh="0"
        while IFS= read -r mode_line; do
          local mode_refresh
          mode_refresh=$(echo "$mode_line" | grep -oP '\d+\.\d+' | head -1)
          if [ -n "$mode_refresh" ]; then
            if command -v bc &>/dev/null; then
              if [ "$(echo "$mode_refresh > $best_refresh" | bc 2>/dev/null)" = "1" ]; then
                best_refresh="$mode_refresh"
              fi
            else
              best_refresh="$mode_refresh"
            fi
          fi
        done < "${card_dir}modes"
        [ "$best_refresh" != "0" ] && refresh="$best_refresh"
      fi
    fi

    [ -n "$width" ] && [ -n "$height" ] && echo "$output ${width}x${height} ${refresh:-60.000}"
  done
}

# Função: calcular escala baseada na resolução vertical
get_scale_for_height() {
  local height="$1"
  if [ "$height" -ge 2160 ]; then
    echo "2.0"
  elif [ "$height" -ge 1440 ]; then
    echo "1.5"
  else
    echo "1.0"
  fi
}

# Detectar monitores
MONITORS_FOUND=$(detect_monitors) || true

AUTOSTART="$HOME/.config/labwc/autostart"
mkdir -p "$HOME/.config/labwc"

# Remover linhas wlr-randr existentes do autostart (serão regeneradas)
if [ -f "$AUTOSTART" ]; then
  sed -i '/^wlr-randr/d' "$AUTOSTART"
fi

if [ -n "$MONITORS_FOUND" ]; then
  info "Monitores detectados:"
  echo "$MONITORS_FOUND" | while read -r line; do
    info "  $line"
  done
  echo ""

  while IFS= read -r line; do
    local_output=$(echo "$line" | awk '{print $1}')
    local_res=$(echo "$line" | awk '{print $2}')
    local_width=$(echo "$local_res" | cut -d'x' -f1)
    local_height=$(echo "$local_res" | cut -d'x' -f2)
    local_scale=$(get_scale_for_height "$local_height")

    echo "wlr-randr --output $local_output --scale $local_scale" >> "$AUTOSTART"
    info "  ${local_output}: ${local_width}x${local_height} escala ${local_scale}"
  done <<< "$MONITORS_FOUND"

  ok "Escalas adicionadas ao autostart do Labwc"
else
  warn "Nenhum monitor detectado — mantendo autostart atual"
fi
quote

# ──────────────────────────────────────────────
# 12. Otimização de I/O e memória para desktop
# ──────────────────────────────────────────────
step "⚡ Otimizando I/O e memória para desktop..."

# I/O Scheduler: NVMe=none, SSD=mq-deadline, HDD=bfq
for disk in /sys/block/nvme*/queue/scheduler /sys/block/sd*/queue/scheduler; do
  [ -f "$disk" ] || continue
  disk_name=$(echo "$disk" | cut -d'/' -f4)

  if echo "$disk_name" | grep -q "^nvme"; then
    echo "none" | sudo tee "$disk" > /dev/null
    echo "  ✔ $disk_name → none (NVMe)"
  elif echo "$disk_name" | grep -q "^sd"; then
    if [ -f "/sys/block/$disk_name/queue/rotational" ]; then
      rotational=$(cat "/sys/block/$disk_name/queue/rotational")
      if [ "$rotational" = "0" ]; then
        echo "mq-deadline" | sudo tee "$disk" > /dev/null
        echo "  ✔ $disk_name → mq-deadline (SSD SATA)"
      else
        echo "bfq" | sudo tee "$disk" > /dev/null
        echo "  ✔ $disk_name → bfq (HDD)"
      fi
    fi
  fi
done

# Dirty pages — flush mais frequente (evita travamento)
sudo sysctl -w vm.dirty_ratio=5 > /dev/null
sudo sysctl -w vm.dirty_background_ratio=2 > /dev/null
sudo sysctl -w vm.dirty_writeback_centisecs=300 > /dev/null
sudo sysctl -w vm.dirty_expire_centisecs=1500 > /dev/null
[ -f /proc/sys/vm/dirty_ratio_bytes ] && sudo sysctl -w vm.dirty_ratio_bytes=134217728 > /dev/null
sudo sysctl -w vm.page-cluster=3 > /dev/null
sudo sysctl -w vm.vfs_cache_pressure=50 > /dev/null

echo "  ✔ dirty_ratio: 5% (era 20%)"
echo "  ✔ dirty_background_ratio: 2% (era 10%)"

# Persistir no boot
sudo tee /etc/sysctl.d/99-desktop-io.conf > /dev/null <<'EOF'
# Otimizações de I/O e memória para desktop
vm.dirty_ratio = 5
vm.dirty_background_ratio = 2
vm.dirty_writeback_centisecs = 300
vm.dirty_expire_centisecs = 1500
vm.dirty_ratio_bytes = 134217728
vm.page-cluster = 3
vm.vfs_cache_pressure = 50
EOF

sudo tee /etc/udev/rules.d/60-ioscheduler.rules > /dev/null <<'EOF'
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF

ok "I/O otimizado — scheduler + dirty pages + cache"
info "Reinicie para aplicar o scheduler nos discos"
quote

# ──────────────────────────────────────────────
# 13. Pacman parallel downloads + TRIM
# ──────────────────────────────────────────────
step "📦 Configurando pacman + TRIM..."

# ParallelDownloads = 16
if grep -q "^#ParallelDownloads = 5" /etc/pacman.conf; then
  sudo sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 16/' /etc/pacman.conf
  ok "pacman: ParallelDownloads = 16"
elif grep -q "^ParallelDownloads" /etc/pacman.conf; then
  sudo sed -i 's/^ParallelDownloads = .*/ParallelDownloads = 16/' /etc/pacman.conf
  ok "pacman: ParallelDownloads atualizado para 16"
else
  info "pacman: ParallelDownloads já configurado"
fi

# TRIM para SSDs
if systemctl is-enabled fstrim.timer &>/dev/null; then
  ok "fstrim.timer já habilitado"
elif lsblk -d -o ROTA 2>/dev/null | grep -q "^0$"; then
  sudo systemctl enable --now fstrim.timer 2>/dev/null && \
    ok "fstrim.timer habilitado (TRIM semanal)" || warn "Falha ao habilitar fstrim.timer"
else
  info "Nenhum SSD detectado — TRIM não habilitado"
fi

# ──────────────────────────────────────────────
# 13b. Swap — memória virtual
# ──────────────────────────────────────────────
step "🔄 Criando swap de 4GB..."

if swapon --show | grep -q "/swapfile"; then
  info "Swap já existe, ignorando"
else
  sudo dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile

  # Persistir no fstab
  if ! grep -q "^/swapfile" /etc/fstab; then
    echo "/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
  fi

  ok "Swap de 4GB criado e ativado"
  info "Sistema não trava mais com falta de memória"
fi
quote

# ──────────────────────────────────────────────
# 14. xdg-user-dirs
# ──────────────────────────────────────────────
step "📁 Configurando diretórios do usuário..."
info "🔔 Criando Diretórios como Downloads, Documentos, Imagens..."
xdg-user-dirs-update 2>&1 || true
ok "Diretórios criados"

# ──────────────────────────────────────────────
# 15. Final — escolha do usuário
# ──────────────────────────────────────────────
clear 2>/dev/null || true
echo -e "${GREEN}"
echo '  ██╗      █████╗ ██████╗ ██╗    ██╗ ██████╗'
echo '  ██║     ██╔══██╗██╔══██╗██║    ██║██╔════╝'
echo '  ██║     ███████║██████╔╝██║ █╗ ██║██║     '
echo '  ██║     ██╔══██║██╔══██╗██║███╗██║██║     '
echo '  ███████╗██║  ██║██████╔╝╚███╔███╔╝╚██████╗'
echo '  ╚══════╝╚═╝  ╚═╝╚═════╝  ╚══╝╚══╝  ╚═════╝'
echo -e "${NC}"
echo ""
echo -e "  ${GREEN}✔${NC} Sistema configurado com sucesso! By eusouobn"
echo ""
echo -e "  ${BOLD}O que deseja fazer agora?${NC}"
echo ""
echo -e "  ${CYAN}[1]${NC} Iniciar LightDM agora (tela de login)"
echo -e "  ${CYAN}[2]${NC} Reiniciar o sistema"
echo -e "  ${CYAN}[3]${NC} Sair (voltar ao terminal)"
echo ""
echo -n "  Escolha [1/2/3]: "
read -r choice

# Limpar repo temporário
rm -rf /tmp/labwc-dotfiles

case "$choice" in
  1)
    echo ""
    info "Iniciando LightDM..."
    sudo systemctl start lightdm
    ;;
  2)
    echo ""
    info "Reiniciando em 5 segundos... Pressione Ctrl+C para cancelar"
    sleep 5
    sudo reboot
    ;;
  *)
    echo ""
    info "Voltando ao terminal. Para iniciar o LightDM manualmente:"
    echo ""
    echo "    sudo systemctl start lightdm"
    echo ""
    ;;
esac
