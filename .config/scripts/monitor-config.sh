#!/bin/bash
# monitor-config.sh — Configura monitores: lista telas, resoluções e refresh rates,
# aplica na hora e pode fixar a escolha (aplicada no login pelo monitor-scale.sh)
set -uo pipefail

FIXED_CONF="$HOME/.config/labwc/monitor-fixed.conf"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}✔${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }

require_wlr() {
  command -v wlr-randr &>/dev/null || { echo -e "${RED}✘${NC} wlr-randr não instalado"; exit 1; }
  [ -n "${WAYLAND_DISPLAY:-}" ] || { echo -e "${RED}✘${NC} rode dentro da sessão Wayland (labwc)"; exit 1; }
}

get_scale() {
  local h="$1"
  if   [ "$h" -ge 2000 ]; then echo "2.0"
  elif [ "$h" -ge 1300 ]; then echo "1.5"
  else echo "1.0"; fi
}

# Saída plana: OUT|<nome> e MOD|<WxH>|<Hz>|<flags>
parse_wlr() {
  wlr-randr | awk '
    /^[^ ]+ "/ {
      if (out != "") print "END|" out
      out = $1
      print "OUT|" out
      inm = 0
      next
    }
    out != "" && /^  Modes:/ { inm = 1; next }
    inm && /^    [0-9]+x[0-9]+ px,/ {
      if (seen[$1"|"$3]++) next
      flags = ""
      if (index($0, "(preferred")) flags = "preferred"
      if (index($0, "current")) flags = (flags ? flags "," : "") "current"
      print "MOD|" $1 "|" $3 "|" flags
      next
    }
    inm && /^  [A-Za-z]+:/ { inm = 0 }
    END { if (out != "") print "END|" out }
  '
}

load_monitors() {
  OUTS=()
  declare -g -A MODS PREF CUR
  local out=""
  while IFS='|' read -r kind a b c; do
    case "$kind" in
      OUT) out="$a"; OUTS+=("$out");;
      MOD)
        if [ -z "${MODS[$out]:-}" ]; then
          MODS["$out"]="$a|$b|$c"
        else
          MODS["$out"]="${MODS[$out]}"$'\n'"$a|$b|$c"
        fi
        [[ "$c" == *preferred* ]] && PREF["$out"]="$a|$b"
        [[ "$c" == *current* ]] && CUR["$out"]="$a|$b"
        ;;
    esac
  done < <(parse_wlr)
  [ ${#OUTS[@]} -gt 0 ]
}

fmt() { # "WxH|Hz" -> "WxH @ Hz Hz"
  local w=${1%%|*} hz=${1##*|}
  echo "${w} @ ${hz} Hz"
}

list_outputs() {
  echo ""
  echo -e "${BOLD}  Monitores detectados:${NC}"
  local i=1 cur
  for out in "${OUTS[@]}"; do
    cur="—"
    [ -n "${CUR[$out]:-}" ] && cur=$(fmt "${CUR[$out]}")
    echo "    $i) $out — atual: $cur"
    i=$((i+1))
  done
}

show_modes() {
  local out="$1" idx=0 line m hz fl marker
  echo ""
  echo -e "${BOLD}  Modos de ${out}:${NC}"
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    IFS='|' read -r m hz fl <<< "$line"
    idx=$((idx+1))
    marker=""
    [[ "$fl" == *preferred* ]] && marker="$marker preferida"
    [[ "$fl" == *current* ]] && marker="$marker (atual)"
    echo "    $idx) ${m} @ ${hz} Hz${marker}"
  done <<< "${MODS[$out]:-}"
}

count_modes() { # nº de linhas de MODS[$out]
  local out="$1" n=0 line
  while IFS= read -r line; do [ -n "$line" ] && n=$((n+1)); done <<< "${MODS[$out]:-}"
  echo "$n"
}

set_fixed() {
  local out="$1" m="$2" hz="$3" scale="$4"
  mkdir -p "$(dirname "$FIXED_CONF")"
  touch "$FIXED_CONF"
  sed -i "/^${out} /d" "$FIXED_CONF"
  echo "$out $m $hz $scale" >> "$FIXED_CONF"
}

configure_output() {
  local choice pick line m hz fl h auto scale out
  list_outputs
  echo ""
  read -rp "  Escolha o monitor [1-${#OUTS[@]}]: " choice
  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#OUTS[@]}" ]; then
    warn "Opção inválida"
    return
  fi
  out="${OUTS[$((choice-1))]}"

  show_modes "$out"
  echo ""
  read -rp "  Escolha o modo [1-$(count_modes "$out")]: " pick
  line=$(printf '%s\n' "${MODS[$out]:-}" | sed -n "${pick}p")
  if [ -z "$line" ]; then
    warn "Modo inválido"
    return
  fi
  IFS='|' read -r m hz fl <<< "$line"

  h=${m#*x}
  auto=$(get_scale "$h")
  read -rp "  Escala (automática=${auto}x) [1/1.5/2 ou auto]: " scale
  [ -z "$scale" ] && scale="auto"
  [[ "$scale" == "auto" ]] && scale="$auto"
  if ! [[ "$scale" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    warn "Escala inválida"
    return
  fi

  echo ""
  if wlr-randr --output "$out" --mode "${m}@${hz}" --scale "$scale" 2>&1; then
    ok "Aplicado: $out ${m} @ ${hz} Hz, escala ${scale}x"
  else
    echo -e "${RED}✘${NC} Falha ao aplicar o modo"
    return
  fi

  echo ""
  read -rp "  Fixar esta configuração no login? [S/n]: " fix
  case "${fix:-S}" in
    s|S|y|Y|"")
      set_fixed "$out" "$m" "$hz" "$scale"
      ok "Fixo salvo em $FIXED_CONF — monitor-scale.sh aplica no login"
      ;;
    *) info "OK, aplicado só agora (no login volta ao automático)" ;;
  esac
}

show_fixed() {
  echo ""
  echo -e "${BOLD}  Configurações fixas ($FIXED_CONF):${NC}"
  if [ -f "$FIXED_CONF" ] && [ -s "$FIXED_CONF" ]; then
    cat "$FIXED_CONF"
  else
    info "Nenhuma — escala automática (1080p=1x, 1440p=1.5x, 4K=2x)"
  fi
}

clear_fixed() {
  if [ -f "$FIXED_CONF" ] && [ -s "$FIXED_CONF" ]; then
    rm -f "$FIXED_CONF"
    ok "Configurações fixas removidas — monitor-scale.sh volta ao automático"
  else
    warn "Nada para limpar"
  fi
}

main() {
  require_wlr
  load_monitors || { warn "Nenhuma tela detectada via wlr-randr"; exit 1; }

  while true; do
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║      Configuração de Monitores       ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    echo "  1) Configurar monitor (resolução/refreshrate)"
    echo "  2) Mostrar configurações fixas"
    echo "  3) Limpar configurações fixas"
    echo "  4) Sair"
    echo ""
    read -rp "  Escolha [1-4]: " choice
    case "$choice" in
      1) configure_output ;;
      2) show_fixed ;;
      3) clear_fixed ;;
      *) exit 0 ;;
    esac
  done
}

main "$@"
