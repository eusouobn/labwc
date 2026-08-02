#!/bin/bash

# Pastas onde os temas estão instalados
THEME_DIRS=(~/.themes /usr/share/themes)

# Lista todos os temas que têm openbox-3
THEMES=()
for dir in "${THEME_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        for t in "$dir"/*; do
            if [ -d "$t/openbox-3" ]; then
                THEMES+=("$(basename "$t")")
            fi
        done
    fi
done

# Escolha do tema
echo "Temas disponíveis:"
select theme in "${THEMES[@]}"; do
    if [ -n "$theme" ]; then
        RC="$HOME/.config/labwc/rc.xml"
        # Substitui o nome do tema no rc.xml
        sed -i "s|<name>.*</name>|<name>$theme</name>|" "$RC"
        echo "Tema alterado para $theme!"
        # Recarrega Labwc
        killall -HUP labwc
        break
    fi
done
