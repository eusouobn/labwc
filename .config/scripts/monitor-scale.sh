#!/usr/bin/env bash
# monitor-scale.sh — Aplica resolução máxima + escala dinâmica por monitor
# Escala: 1080p = 1x, 1440p = 1.5x, 4K = 2x
# Chamado pelo autostart do Labwc; também dá pra rodar manualmente.
set -uo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✔${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }

# ── Escala conforme a altura da resolução ──────────────
get_scale() {
  local h="$1"
  if   [ "$h" -ge 2000 ]; then echo "2.0"   # 4K (2160)
  elif [ "$h" -ge 1300 ]; then echo "1.5"   # 1440p
  else echo "1.0"; fi                        # 1080p e menores
}

# ── Detectar via wlr-randr (dentro da sessão Wayland) ──
detect_via_wlr() {
  wlr-randr 2>/dev/null | awk '
    /^[^ ]+ "/ { if (out != "") print out, res; out = $1; res = "" }
    /\(preferred/ { match($0, /[0-9]+x[0-9]+/); if (res == "") res = substr($0, RSTART, RLENGTH) }
    END { if (out != "") print out, res }
  '
}

# ── Fallback: kernel DRM (sem sessão Wayland) ──────────
detect_via_drm() {
  for card in /sys/class/drm/card*-*/; do
    [ -f "${card}status" ] || continue
    [ "$(cat "${card}status" 2>/dev/null)" = "connected" ] || continue
    local out res
    out=$(basename "$card" | sed 's/card[0-9]*-//')
    res=$(head -1 "${card}modes" 2>/dev/null)
    [ -n "$res" ] && echo "$out $res"
  done
}

# ── Main ──────────────────────────────────────────────
echo ""
echo -e "${BOLD}  Monitor Scale${NC} (resolução máxima + escala dinâmica)"
echo ""

detected=$(detect_via_wlr)
[ -z "$detected" ] && detected=$(detect_via_drm)

if [ -z "$detected" ]; then
  warn "Nenhum monitor detectado"
  exit 1
fi

while IFS= read -r line; do
  [ -z "$line" ] && continue
  out=$(echo "$line" | awk '{print $1}')
  res=$(echo "$line" | awk '{print $2}')
  [ -z "$out" ] || [ -z "$res" ] && continue

  height=${res#*x}
  scale=$(get_scale "$height")

  if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wlr-randr &>/dev/null; then
    if wlr-randr --output "$out" --preferred --scale "$scale" 2>/dev/null; then
      ok "$out: $res @ ${scale}x"
    else
      warn "$out: falha ao aplicar $res @ ${scale}x"
    fi
  else
    info "$out: $res (escala sugerida ${scale}x — sem sessão Wayland, aplica no login)"
  fi
done <<< "$detected"

echo ""
