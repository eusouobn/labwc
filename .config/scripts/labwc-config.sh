#!/bin/bash
# labwc-config.sh - Ferramenta de configuração rápida do Labwc
# Chamado pelo keybind W-C do rc.xml (Ways de abrir as configs)

echo "╔══════════════════════════════════╗"
echo "║      Configuração do Labwc       ║"
echo "╚══════════════════════════════════╝"
echo ""
echo "  1) Trocar tema Openbox/Labwc"
echo "  2) Abrir nwg-look (tema GTK/ícones)"
echo "  3) Editar rc.xml (atalhos)"
echo "  4) Editar autostart"
echo "  5) Sair"
echo ""
read -rp "  Escolha [1-5]: " choice

case "$choice" in
  1) bash "$HOME/.config/scripts/switch-labwc-theme.sh" ;;
  2) nwg-look ;;
  3) konsole --nofork --hold -e nano "$HOME/.config/labwc/rc.xml" ;;
  4) konsole --nofork --hold -e nano "$HOME/.config/labwc/autostart" ;;
  *) exit 0 ;;
esac
