#!/bin/bash

# uso:
# ./copy.sh archivo list.txt

file="$1"
list="$2"

if [[ -z "$file" || -z "$list" ]]; then
    echo "Uso: $0 archivo list.txt"
    exit 1
fi

if [[ ! -f "$file" ]]; then
    echo "Error: archivo no existe"
    exit 1
fi

if [[ ! -f "$list" ]]; then
    echo "Error: list.txt no existe"
    exit 1
fi

ext="${file##*.}"

while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    cp "$file" "${name}.${ext}"
    echo "Creado: ${name}.${ext}"
done < "$list"