#!/usr/bin/env bash
# Fonctions génériques de journalisation et d'affichage du DIU

print_title() {
    local title="${1:-}"

    echo ""
    echo "=========================================================="
    echo " ${title}"
    echo "=========================================================="
    echo ""
}

print_info() {
    echo "ℹ️  $*"
}

print_success() {
    echo "✅ $*"
}

print_error() {
    echo "❌ $*" >&2
}
