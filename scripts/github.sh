#!/usr/bin/env bash

# ──────────────────────────────────────────────
# Forçar execução com bash (antes do set -euo pipefail)
# ──────────────────────────────────────────────
if [ -z "$BASH_VERSION" ]; then
  echo -e "\033[0;31m✘\033[0m Este script precisa ser executado com bash, não com sh."
  echo "  Use: bash github.sh"
  exit 1
fi

set -euo pipefail

# ──────────────────────────────────────────────
# Cores e funções
# ──────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; MAG='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

step() {
  echo ""
  echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  ${CYAN}┃${NC} ${MAG}★${NC} ${BOLD}$1${NC}"
  echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
info() { echo -e "  ${CYAN}→${NC} $1"; }
ok()   { echo -e "  ${GREEN}✔${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
err()  { echo -e "  ${RED}✘${NC} $1"; }

banner() {
  echo ""
  echo -e "  ${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "  ${CYAN}▓${NC}            ${BOLD}GitHub + OpenCode${NC}            ${CYAN}▓${NC}"
  echo -e "  ${CYAN}▓${NC}         ${YELLOW}Configuração do esquema${NC}         ${CYAN}▓${NC}"
  echo -e "  ${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "  ${MAG}✦${NC}  ${BOLD}By eusouobn${NC}  ${MAG}✦${NC}"
  echo ""
}

# ──────────────────────────────────────────────
# Verificação: não rodar como root
# ──────────────────────────────────────────────
if [ "$(id -u)" -eq 0 ]; then
  err "Não rode este script como root — ele configura o seu usuário."
  exit 1
fi

USER_GITHUB="eusouobn"
EMAIL_GITHUB="eusouobn@users.noreply.github.com"

banner

# ──────────────────────────────────────────────
# 1. Instalar gh (GitHub CLI)
# ──────────────────────────────────────────────
step "📦 Instalando GitHub CLI"
if command -v gh &>/dev/null; then
  ok "gh já instalado: $(gh --version | head -1)"
else
  info "Instalando gh..."
  sudo pacman -S --needed --noconfirm gh
  ok "gh instalado"
fi

# ──────────────────────────────────────────────
# 2. Identidade git
# ──────────────────────────────────────────────
step "👤 Configurando identidade git"
git config --global user.name  "$USER_GITHUB"
git config --global user.email "$EMAIL_GITHUB"
git config --global init.defaultBranch main
ok "git config: $USER_GITHUB <$EMAIL_GITHUB>"

# ──────────────────────────────────────────────
# 3. Login no GitHub (fluxo do dispositivo / HTTPS)
# ──────────────────────────────────────────────
step "🔑 Autenticando no GitHub"
if gh auth status &>/dev/null; then
  ok "gh já autenticado:"
  gh auth status
else
  info "Vai aparecer um código de um dígito só — confirme em github.com/login/device"
  info "Escopos: repo, read:org, workflow, gist"
  gh auth login \
    --hostname github.com \
    --git-protocol https \
    --scopes repo,read:org,workflow,gist \
    --web
  ok "Login concluído"
fi

# ──────────────────────────────────────────────
# 4. Git passa a usar o token do gh (HTTPS)
# ──────────────────────────────────────────────
step "🔗 Ligando git ao gh (credential helper)"
gh auth setup-git
ok "git agora usa o token do gh para push/pull"

# ──────────────────────────────────────────────
# 5. Verificação
# ──────────────────────────────────────────────
step "✅ Verificação final"
gh auth status || {
  err "Algo deu errado na autenticação — rode: gh auth login --web"
  exit 1
}
git config --get user.name
git config --get user.email

echo ""
ok "Pronto! O OpenCode já consegue clonar e dar push nos seus repositórios."
info "Teste: gh repo list eusouobn"
echo ""
