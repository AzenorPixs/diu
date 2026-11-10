#!/usr/bin/env bash

diu_softwares_convergence_help() {
    local action="${1:-}" engine="${2:-}" engine_name
    case "$action:$engine" in
        :)
            diu_help_line 'diu softwares infos' 'Affiche les informations des logiciels.'
            for engine_name in apt flatpak github; do
                diu_help_line "diu softwares install $engine_name <SOFTWARE>" "Demande l’installation et enregistre l’état désiré 1."
                diu_help_line "diu softwares remove $engine_name <SOFTWARE>" "Demande la désinstallation et enregistre l’état désiré 0."
                diu_help_line "diu softwares update $engine_name [SOFTWARE]" 'Converge un logiciel ou tous ceux du moteur.'
            done
            diu_help_line 'diu softwares update' 'Converge APT, Flatpak puis GitHub.'
            diu_help_line 'diu softwares flatpak update' 'Alias compatible de convergence Flatpak globale.'
            ;;
        install:|remove:)
            diu_help_line "diu softwares $action <apt|flatpak|github> <SOFTWARE>" "Enregistre le nouvel état désiré et applique l’opération."
            ;;
        install:apt|install:flatpak|install:github|remove:apt|remove:flatpak|remove:github)
            diu_help_line "diu softwares $action $engine <SOFTWARE>" "Enregistre le nouvel état désiré et applique l’opération."
            ;;
        update:)
            diu_help_line 'diu softwares update' 'Converge APT, Flatpak puis GitHub.'
            diu_help_line 'diu softwares update apt [SOFTWARE]' 'Converge les logiciels APT.'
            diu_help_line 'diu softwares update flatpak [SOFTWARE]' 'Converge les applications Flatpak système.'
            diu_help_line 'diu softwares update github [SOFTWARE]' 'Converge les logiciels GitHub.'
            ;;
        update:apt|update:flatpak|update:github)
            diu_help_line "diu softwares update $engine [SOFTWARE]" "Compare l’état désiré à l’état réel et corrige un écart."
            ;;
        flatpak:|flatpak:update)
            diu_help_line 'diu softwares update flatpak [SOFTWARE]' 'Converge les applications Flatpak système.'
            diu_help_line 'diu softwares flatpak update' 'Alias compatible de convergence Flatpak globale.'
            ;;
        *) return 2 ;;
    esac
    printf '%s\n' 'La convergence ne met pas à jour les versions ; utiliser diu system engine update.'
    printf '%s\n' 'diu update exécute la convergence logiciels en dernière étape.'
}

diu_update_convergence_help() {
    diu_help_line 'diu update' 'Met à jour les modules et modèles via diu projects update, puis converge les logiciels en dernier.'
    diu_help_line 'diu softwares update' 'Converge séparément les logiciels configurés.'
    diu_help_line 'diu system engine update' 'Met à jour les versions des logiciels par moteur.'
    diu_help_line 'diu update diu' 'Alias de diu diu update.'
}
