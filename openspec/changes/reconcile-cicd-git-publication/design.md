# Conception

Le commit local de version constitue la source des builds et du tag. Chaque fournisseur est traité dans un contexte Git isolé. Une branche divergente est fusionnée en conservant les changements compatibles et en privilégiant tous les fichiers versionnés locaux en conflit ; le tag continue de désigner le commit versionné, pas le commit de fusion. Une référence distante ne doit être remplacée que si sa valeur correspond encore à celle vérifiée. Les modifications locales non committées ne participent pas au rejeu.

Les assets existants restent protégés : déplacer un tag ne prouve pas qu'un paquet ou une image déjà publiés correspondent au nouveau commit. Les conflits non résolubles automatiquement et les refus serveur restent des échecs explicites.
