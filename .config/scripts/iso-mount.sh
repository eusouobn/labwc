#!/usr/bin/env bash
# Montar / desmontar imagens ISO via udisksctl (Dolphin ServiceMenu)
# Uso: iso-mount.sh <arquivo> [mount|unmount]

set -euo pipefail

IMG="$1"
ACTION="${2:-mount}"

IMG="${IMG#file://}"
IMG=$(python -c "import urllib.parse,sys; print(urllib.parse.unquote(sys.argv[1]))" "$IMG" 2>/dev/null || echo "$IMG")
IMG=$(readlink -f "$IMG")

if [ ! -f "$IMG" ]; then
  echo "Arquivo não encontrado: $IMG" >&2
  exit 1
fi

find_loop() {
  local backing
  for dev in /dev/loop[0-9]*; do
    [ -b "$dev" ] || continue
    backing=$(cat "/sys/class/block/${dev#/dev/}/loop/backing_file" 2>/dev/null || true)
    if [ "$backing" = "$IMG" ]; then
      echo "$dev"
      return 0
    fi
  done
  return 1
}

case "$ACTION" in
  mount)
    out=$(udisksctl loop-setup -f "$IMG" --no-user-interaction 2>&1)
    loop=$(echo "$out" | grep -oP '/dev/loop\d+' | head -1 || true)
    if [ -z "${loop:-}" ]; then
      echo "Falha ao criar loop device: $out" >&2
      exit 1
    fi
    if udisksctl info -b "$loop" 2>/dev/null | grep -qE "^( *IdType:)" && udisksctl mount -b "$loop" --no-user-interaction 2>&1; then
      echo "ISO montada com sucesso."
    else
      echo "ISO sem sistema de arquivos — só o loop foi criado ($loop)."
    fi
    ;;
  unmount)
    loop=$(find_loop || true)
    if [ -z "${loop:-}" ]; then
      echo "Nenhuma imagem montada a partir de $IMG" >&2
      exit 1
    fi
    udisksctl unmount -b "$loop" --no-user-interaction 2>/dev/null || true
    udisksctl loop-delete -b "$loop" --no-user-interaction 2>&1
    echo "Imagem desmontada ($loop)."
    ;;
  *)
    echo "Ação inválida: $ACTION" >&2
    exit 1
    ;;
esac
