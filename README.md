# Dotfiles — Labwc + Waybar + Arch Linux

Configurações pessoais do meu ambiente Arch Linux com **Labwc** (compositor Wayland leve e estável). Perfeito para quem quer um Arch bonito, funcional e pronto para o dia a dia sem precisar configurar nada na mão.

## O que vem instalado

| Categoria | Programas |
|-----------|-----------|
| **Compositor** | Labwc (Wayland, baseado em wlroots) |
| **Barra** | Waybar |
| **Launcher** | fuzzel + dmenu |
| **Terminal** | Konsole (KDE) + Alacritty + FiraCode Nerd Font |
| **Tema** | Escuro (Arc-Darkest, Papirus-Dark) |
| **Login** | LightDM + lightdm-gtk-greeter |
| **Navegador** | Firefox |
| **Arquivos** | Dolphin (KDE) |
| **Editor** | Kate (KDE) |
| **Imagens** | Gwenview (KDE) |
| **Áudio** | PipeWire + WirePlumber + Audacious + Pavucontrol |
| **Bluetooth** | BlueZ |
| **Impressão** | CUPS + system-config-printer |
| **Ícones** | Papirus-Dark |
| **Fontes** | Ubuntu, Ubuntu Nerd, FiraCode Nerd |

## Para instalar

### 1. Tenha o Arch Linux instalado

Se ainda não instalou, use o `install.sh` interativo:

```bash
bash scripts/install.sh
```

Durante a instalação, na etapa **Interface Gráfica**, escolha a opção **11) Labwc (Wayland)**.

Após reiniciar, faça login com seu usuário.

### 2. Rode o script de instalação

```bash
git clone https://github.com/eusouobn/labwc
cd labwc
bash scripts/labwc.sh
```

Ou, se o install.sh já copiou o script para a home:

```bash
bash ~/scripts/labwc.sh
```

**O script faz tudo sozinho:**

- Instala todos os pacotes (Labwc, Waybar, Dolphin, Firefox, áudio, Bluetooth, impressão, etc.)
- Configura tema escuro, ícones e fontes
- Configura LightDM
- Ativa Bluetooth, áudio e serviços necessários
- Detecta monitores e ajusta a escala automaticamente
- Otimiza I/O, swap e pacman
- No final pergunta se quer iniciar o LightDM ou reiniciar

## Atalhos do Labwc

| Atalho | Ação |
|--------|------|
| `Mod+T` | Abrir terminal (Konsole) |
| `Mod+R` | Launcher de apps (fuzzel) |
| `Mod+A` | App drawer (fuzzel) |
| `Mod+E` | Abrir Dolphin |
| `Mod+X` | Abrir Firefox |
| `Mod+Q` | Fechar janela |
| `Mod+F` | Tela cheia |
| `Mod+Escape` | Toggle Waybar |
| `Mod+Espaço` | Desligar |
| `Mod+C` | Ferramenta de configuração do Labwc |
| `Mod+F10` | Screenshot |
| `Alt+Tab` | Alternar janelas |

> `Mod` = tecla Super (a do Windows/Comando)

## Estrutura do projeto

```
labwc/
├── scripts/
│   ├── install.sh                    ← Instalador interativo Arch Linux
│   └── labwc.sh                      ← Script de instalação completo
├── .config/
│   ├── labwc/                        ← Config do compositor (rc.xml, autostart, environment)
│   ├── waybar/                       ← Config da barra
│   ├── fuzzel/                       ← Config do launcher
│   ├── gtk-3.0/ gtk-4.0/             ← Tema escuro do GTK
│   ├── nwg-look/                     ← Config do seletor de temas
│   ├── xsettingsd/                   ← Config do xsettingsd
│   ├── fontconfig/                   ← Alias: mono→Ubuntu Mono Bold, sans→Ubuntu
│   └── scripts/                      ← Scripts de configuração do Labwc
├── etc/
│   ├── pacman.d/hooks/kde-cache.hook ← Hook pós-transação do pacman
│   ├── udisks2/mount_options.conf    ← Escrita síncrona para USB
│   ├── udev/rules.d/                 ← Botão Power + I/O scheduler
│   └── systemd/system/               ← Services (power-button)
└── README.md
```

## Dicas

- **Atualizar o sistema**: `sudo pacman -Syu`
- **Instalar programas do AUR**: `yay -S nome-do-pacote`
- **Swap**: Criado automaticamente durante a instalação (4GB)
- **Otimização de I/O**: Aplicada automaticamente (scheduler + dirty pages)
- **Mudar tema de ícones**: `nwg-look`
