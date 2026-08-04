#!/usr/bin/env bash
# steam-gamescope.sh — Gera launch options do Steam com Gamescope em 4K nativo
#
# Motivo: no labwc/wlroots com escala (ex.: 4K @ 2x), o XWayland reporta aos
# jogos a resolução lógica (1920x1080). O Gamescope expõe um display virtual
# na resolução nativa, ignorando o scale do compositor.
#
# Uso:
#   1) Rode este script e copie a linha gerada.
#   2) No Steam: botão direito no jogo → Propriedades → Opções de Inicialização,
#      cole a linha. Repita para cada jogo.
#
# Opcional: passe o comando do jogo para gerar o wrapper:
#   steam-gamescope.sh "gamescope -w 3840 -h 2160 %command%"
set -uo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; BOLD='\033[1m'; NC='\033[0m'
info() { echo -e "  ${CYAN}→${NC} $1"; }
ok()   { echo -e "  ${GREEN}✔${NC} $1"; }

# ── Detectar resolução nativa (wlr-randr na sessão, senão DRM) ──
detect_res() {
  if command -v wlr-randr &>/dev/null && [ -n "${WAYLAND_DISPLAY:-}" ]; then
    wlr-randr 2>/dev/null | awk '
      /\(preferred/ { match($0, /[0-9]+x[0-9]+/); print substr($0, RSTART, RLENGTH); exit }
    '
  else
    for card in /sys/class/drm/card*-*/; do
      [ "$(cat "${card}status" 2>/dev/null)" = "connected" ] || continue
      head -1 "${card}modes" 2>/dev/null
      break
    done
  fi
}

RES=$(detect_res | head -1)
RES=${RES:-3840x2160}
W=${RES%x*}; H=${RES#*x}

echo ""
echo -e "${BOLD}  Steam + Gamescope (resolução nativa)${NC}"
echo ""
info "Resolução detectada: ${BOLD}${RES}${NC}"
echo ""

OPTIONS="gamescope -w $W -h $H -W $W -H $H -r 60 -- %command%"
ok "Launch options (copie para o jogo no Steam):"
echo ""
echo -e "  ${CYAN}${OPTIONS}${NC}"
echo ""
echo "  Dica: sem -W/-H, o gamescope usa a resolução do display automaticamente."
echo "  Dica: adicione --fullscreen e --fps-unlocked se o jogo pedir."
echo ""
echo "  Cliente Steam pequeno? A UI do cliente NÃO usa gamescope —"
echo "  lance-o com STEAM_FORCE_DESKTOPUI_SCALING=2 (ou steam -forcedesktopscaling 2)."
echo ""
