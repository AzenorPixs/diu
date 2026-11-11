#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_zsh_defaults() {
    printf '%s\n' 'if ! alias -- G >/dev/null 2>&1; then'
    printf '%s\n' 'alias -g G='"'"'| grep --color'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- H >/dev/null 2>&1; then'
    printf '%s\n' 'alias -g H='"'"'| head'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- L >/dev/null 2>&1; then'
    printf '%s\n' 'alias -g L='"'"'| less'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- M >/dev/null 2>&1; then'
    printf '%s\n' 'alias -g M='"'"'| more'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- W >/dev/null 2>&1; then'
    printf '%s\n' 'alias -g W='"'"'| wc -l'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- acd >/dev/null 2>&1; then'
    printf '%s\n' 'alias acd='"'"'apt-cache depends'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- acp >/dev/null 2>&1; then'
    printf '%s\n' 'alias acp='"'"'apt-cache policy'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- acr >/dev/null 2>&1; then'
    printf '%s\n' 'alias acr='"'"'apt-cache rdepends -i --no-pre-depends'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- agd >/dev/null 2>&1; then'
    printf '%s\n' 'alias agd='"'"'apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- agi >/dev/null 2>&1; then'
    printf '%s\n' 'alias agi='"'"'apt --show-progress install'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- agif >/dev/null 2>&1; then'
    printf '%s\n' 'alias agif='"'"'apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress install'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- agp >/dev/null 2>&1; then'
    printf '%s\n' 'alias agp='"'"'apt --show-progress purge'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- agpf >/dev/null 2>&1; then'
    printf '%s\n' 'alias agpf='"'"'apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress purge'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- agu >/dev/null 2>&1; then'
    printf '%s\n' 'alias agu='"'"'apt update'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- agud >/dev/null 2>&1; then'
    printf '%s\n' 'alias agud='"'"'apt update && apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- alu >/dev/null 2>&1; then'
    printf '%s\n' 'alias alu='"'"'apt list --upgradable'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ama >/dev/null 2>&1; then'
    printf '%s\n' 'alias ama='"'"'apt-mark auto'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- amm >/dev/null 2>&1; then'
    printf '%s\n' 'alias amm='"'"'apt-mark manual'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- aps >/dev/null 2>&1; then'
    printf '%s\n' 'alias aps='"'"'aptitude search'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- c >/dev/null 2>&1; then'
    printf '%s\n' 'alias c='"'"'cat '"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdv >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdv='"'"'cd /var'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ceh >/dev/null 2>&1; then'
    printf '%s\n' 'alias ceh='"'"'cat /etc/hosts'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cehc >/dev/null 2>&1; then'
    printf '%s\n' 'alias cehc='"'"'cat /etc/host.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cel >/dev/null 2>&1; then'
    printf '%s\n' 'alias cel='"'"'cat /etc/localtime'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ci >/dev/null 2>&1; then'
    printf '%s\n' 'alias ci='"'"'cat /home/devops/datas/prompts/INDEX.md'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cm >/dev/null 2>&1; then'
    printf '%s\n' 'alias cm='"'"'cat /home/monero/monero.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cpmh >/dev/null 2>&1; then'
    printf '%s\n' 'alias cpmh='"'"'cat /proc/meminfo | grep Huge'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cer >/dev/null 2>&1; then'
    printf '%s\n' 'alias cer='"'"'cat /etc/rsyslog.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cer1 >/dev/null 2>&1; then'
    printf '%s\n' 'alias cer1='"'"'cat /etc/rsyslog.d/1-kernel.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cerd >/dev/null 2>&1; then'
    printf '%s\n' 'alias cerd='"'"'cat /etc/rsyslog.d/default.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cerp >/dev/null 2>&1; then'
    printf '%s\n' 'alias cerp='"'"'cat /etc/rsyslog.d/postfix.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cetv >/dev/null 2>&1; then'
    printf '%s\n' 'alias cetv='"'"'cat /etc/tmpfiles.d/var2log.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ceu >/dev/null 2>&1; then'
    printf '%s\n' 'alias ceu='"'"'cat /etc/ulogd.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- chda >/dev/null 2>&1; then'
    printf '%s\n' 'alias chda='"'"'cat /home/docker/.ssh/authorized_keys'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cp2 >/dev/null 2>&1; then'
    printf '%s\n' 'alias cp2='"'"'cat /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cra >/dev/null 2>&1; then'
    printf '%s\n' 'alias cra='"'"'cat /root/.ssh/authorized_keys'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cvll >/dev/null 2>&1; then'
    printf '%s\n' 'alias cvll='"'"'cat /var/log/letsencrypt.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cx >/dev/null 2>&1; then'
    printf '%s\n' 'alias cx='"'"'cat /home/monero/xmrig.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- .. >/dev/null 2>&1; then'
    printf '%s\n' 'alias ..='"'"'cd ..'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ... >/dev/null 2>&1; then'
    printf '%s\n' 'alias ...='"'"'cd ../..'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cde >/dev/null 2>&1; then'
    printf '%s\n' 'alias cde='"'"'cd /etc'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdea >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdea='"'"'cd /etc/apache2'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeapt >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeapt='"'"'cd /etc/apt'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeaptconf >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeaptconf='"'"'cd /etc/apt/apt.conf.d'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeaptpref >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeaptpref='"'"'cd /etc/apt/preferences.d'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeaptsl >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeaptsl='"'"'cd /etc/apt/sources.list.d'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeapttrust >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeapttrust='"'"'cd /etc/apt/trusted.gpg.d'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeaca >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeaca='"'"'cd /etc/apache2/conf-available'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeace >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeace='"'"'cd /etc/apache2/conf-enabled'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeama >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeama='"'"'cd /etc/apache2/mods-available'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeame >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeame='"'"'cd /etc/apache2/mods-enabled'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeasa >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeasa='"'"'cd /etc/apache2/sites-available'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdease >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdease='"'"'cd /etc/apache2/sites-enabled'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cded >/dev/null 2>&1; then'
    printf '%s\n' 'alias cded='"'"'cd /etc/default'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeg >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeg='"'"'cd ~/.local/share/gnome-shell/extensions/'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdel >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdel='"'"'cd /etc/ldap'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdels >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdels='"'"'cd /etc/ldap/slapd.d'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdelsc >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdelsc='"'"'cd /etc/ldap/slapd.d/cn=config'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cden >/dev/null 2>&1; then'
    printf '%s\n' 'alias cden='"'"'cd /etc/network'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeni >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeni='"'"'cd /etc/network/interfaces.d'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdenm >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdenm='"'"'cd /etc/NetworkManager/system-connections'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdeovpn >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdeovpn='"'"'cd /etc/openvpn'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cder >/dev/null 2>&1; then'
    printf '%s\n' 'alias cder='"'"'cd /etc/rsyslog.d'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdepf >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdepf='"'"'cd /etc/postfix'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdes >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdes='"'"'cd /etc/systemd'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdesn >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdesn='"'"'cd /etc/systemd/network'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdess >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdess='"'"'cd /etc/systemd/system'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdessh >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdessh='"'"'cd /etc/ssh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdessl >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdessl='"'"'cd /etc/ssl'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdesu >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdesu='"'"'cd /etc/systemd/user'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdh >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdh='"'"'cd /home'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdhde >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdhde='"'"'cd /home/devops'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdhded >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdhded='"'"'cd /home/devops/datas'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdhdo >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdhdo='"'"'cd /home/docker'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdhdod >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdhdod='"'"'cd /home/docker/datas'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdhdos >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdhdos='"'"'cd /home/docker/.ssh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdhdop >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdhdop='"'"'cd /home/docker/proxy'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdhi >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdhi='"'"'cd /home/ia'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdhid >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdhid='"'"'cd /home/ia/download'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdhih >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdhih='"'"'cd /home/ia/hermes'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdhit >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdhit='"'"'cd /home/ia/tools'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdm >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdm='"'"'cd /home/monero'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdr >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdr='"'"'cd /root'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdt >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdt='"'"'cd /tmp'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdub >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdub='"'"'cd /usr/bin'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdvc >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdvc='"'"'cd /var/cache'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdvl >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdvl='"'"'cd /var/log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdvlm >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdvlm='"'"'cd /var/log/machines'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdvlib >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdvlib='"'"'cd /var/lib'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdvlibl >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdvlibl='"'"'cd /var/lib/ldap'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdvm >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdvm='"'"'cd /var/mail'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdvs >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdvs='"'"'cd /var/spool'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cdvt >/dev/null 2>&1; then'
    printf '%s\n' 'alias cdvt='"'"'cd /var/tmp'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- cp >/dev/null 2>&1; then'
    printf '%s\n' 'alias cp='"'"'cp -i'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- mv >/dev/null 2>&1; then'
    printf '%s\n' 'alias mv='"'"'mv -i'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- rm >/dev/null 2>&1; then'
    printf '%s\n' 'alias rm='"'"'rm -i'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- co >/dev/null 2>&1; then'
    printf '%s\n' 'alias co='"'"'command -v '"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- diffu >/dev/null 2>&1; then'
    printf '%s\n' 'alias diffu='"'"'diff -u --suppress-common-lines'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- diffy >/dev/null 2>&1; then'
    printf '%s\n' 'alias diffy='"'"'diff -y --suppress-common-lines'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- rcicddiu >/dev/null 2>&1; then'
    printf '%s\n' 'alias rcicddiu='"'"'diut projects cicddiu'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- rcicddr >/dev/null 2>&1; then'
    printf '%s\n' 'alias rcicddr='"'"'diut projects cicddr'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- diuo >/dev/null 2>&1; then'
    printf '%s\n' 'alias diuo='"'"'diu projects ocrw'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- diu >/dev/null 2>&1; then'
    printf '%s\n' 'alias diu='"'"'/root/diu/root-install-debian.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- diut >/dev/null 2>&1; then'
    printf '%s\n' 'alias diut='"'"'/home/devops/datas/diu/root-install-debian.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- diuu >/dev/null 2>&1; then'
    printf '%s\n' 'alias diuu='"'"'diu update'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dfh >/dev/null 2>&1; then'
    printf '%s\n' 'alias dfh='"'"'df -h'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d0 >/dev/null 2>&1; then'
    printf '%s\n' 'alias d0='"'"'docker stop'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d0d >/dev/null 2>&1; then'
    printf '%s\n' 'alias d0d='"'"'docker stop dockhand'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d0dz >/dev/null 2>&1; then'
    printf '%s\n' 'alias d0dz='"'"'docker stop dozzle'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d0h >/dev/null 2>&1; then'
    printf '%s\n' 'alias d0h='"'"'docker stop hawser'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d0o >/dev/null 2>&1; then'
    printf '%s\n' 'alias d0o='"'"'docker stop ost'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d0t >/dev/null 2>&1; then'
    printf '%s\n' 'alias d0t='"'"'docker stop traefik'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d0w >/dev/null 2>&1; then'
    printf '%s\n' 'alias d0w='"'"'docker stop whoami'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d01d >/dev/null 2>&1; then'
    printf '%s\n' 'alias d01d='"'"'docker restart dockhand'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d01dz >/dev/null 2>&1; then'
    printf '%s\n' 'alias d01dz='"'"'docker restart dozzle'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d01h >/dev/null 2>&1; then'
    printf '%s\n' 'alias d01h='"'"'docker restart hawser'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d01o >/dev/null 2>&1; then'
    printf '%s\n' 'alias d01o='"'"'docker restart ost'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d01t >/dev/null 2>&1; then'
    printf '%s\n' 'alias d01t='"'"'docker restart traefik'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d01w >/dev/null 2>&1; then'
    printf '%s\n' 'alias d01w='"'"'docker restart whoami'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d1 >/dev/null 2>&1; then'
    printf '%s\n' 'alias d1='"'"'docker start'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d1d >/dev/null 2>&1; then'
    printf '%s\n' 'alias d1d='"'"'docker start dockhand'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d1dz >/dev/null 2>&1; then'
    printf '%s\n' 'alias d1dz='"'"'docker start dozzle'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d1h >/dev/null 2>&1; then'
    printf '%s\n' 'alias d1h='"'"'docker start hawser'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d1o >/dev/null 2>&1; then'
    printf '%s\n' 'alias d1o='"'"'docker start ost'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d1t >/dev/null 2>&1; then'
    printf '%s\n' 'alias d1t='"'"'docker start traefik'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- d1w >/dev/null 2>&1; then'
    printf '%s\n' 'alias d1w='"'"'docker start whoami'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dc >/dev/null 2>&1; then'
    printf '%s\n' 'alias dc='"'"'docker-compose --version'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ddp >/dev/null 2>&1; then'
    printf '%s\n' 'alias ddp='"'"'su -c "docker-compose -f /home/docker/proxy/docker-compose.yml down" - docker'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dii >/dev/null 2>&1; then'
    printf '%s\n' 'alias dii='"'"'docker image inspect'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dils >/dev/null 2>&1; then'
    printf '%s\n' 'alias dils='"'"'docker image ls'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dl >/dev/null 2>&1; then'
    printf '%s\n' 'alias dl='"'"'docker logs'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dp >/dev/null 2>&1; then'
    printf '%s\n' 'alias dp='"'"'docker ps'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dlb >/dev/null 2>&1; then'
    printf '%s\n' 'alias dlb='"'"'docker logs bunkerweb'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dlbbd >/dev/null 2>&1; then'
    printf '%s\n' 'alias dlbbd='"'"'docker logs bw-bd'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dlbs >/dev/null 2>&1; then'
    printf '%s\n' 'alias dlbs='"'"'docker logs bw-scheduler'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dlbui >/dev/null 2>&1; then'
    printf '%s\n' 'alias dlbui='"'"'docker logs bw-ui'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dld >/dev/null 2>&1; then'
    printf '%s\n' 'alias dld='"'"'docker logs dozzle'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dlo >/dev/null 2>&1; then'
    printf '%s\n' 'alias dlo='"'"'docker logs ost'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dlp >/dev/null 2>&1; then'
    printf '%s\n' 'alias dlp='"'"'docker logs portainer'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dlt >/dev/null 2>&1; then'
    printf '%s\n' 'alias dlt='"'"'docker logs traefik'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dlw >/dev/null 2>&1; then'
    printf '%s\n' 'alias dlw='"'"'docker logs whoami'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dnls >/dev/null 2>&1; then'
    printf '%s\n' 'alias dnls='"'"'docker network ls'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dpp >/dev/null 2>&1; then'
    printf '%s\n' 'alias dpp='"'"'su -c "docker stop dockhand && docker stop dozzle && docker stop hawser && docker stop librespeed && docker stop myspeed && docker stop traefik-manager && docker stop socket-proxy && docker stop whoami" - docker'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- drid >/dev/null 2>&1; then'
    printf '%s\n' 'alias drid='"'"'docker run --rm --entrypoint id'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dspa >/dev/null 2>&1; then'
    printf '%s\n' 'alias dspa='"'"'docker system prune -f -a --volumes'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dup >/dev/null 2>&1; then'
    printf '%s\n' 'alias dup='"'"'su -c "docker-compose -f /home/docker/proxy/docker-compose.yml up -d" - docker'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- dvls >/dev/null 2>&1; then'
    printf '%s\n' 'alias dvls='"'"'docker volume ls'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- e >/dev/null 2>&1; then'
    printf '%s\n' 'alias e='"'"'exit'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- f >/dev/null 2>&1; then'
    printf '%s\n' 'alias f="find / \( ! -regex '"'"'\/dev\|\/lost.*\|\/sys\|\/proc'"'"' -o -prune \) -type f -name"'
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- f1 >/dev/null 2>&1; then'
    printf '%s\n' 'alias f1="find / \( ! -regex '"'"'\/dev\|\/lost.*\|\/sys\|\/proc'"'"' -o -prune \) -mmin -1 -type f -name"'
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- f7 >/dev/null 2>&1; then'
    printf '%s\n' 'alias f7="find / \( ! -regex '"'"'\/dev\|\/lost.*\|\/sys\|\/proc'"'"' -o -prune \) -mmin -7 -type f -name"'
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- f70 >/dev/null 2>&1; then'
    printf '%s\n' 'alias f70="find / \( ! -regex '"'"'\/dev\|\/lost.*\|\/sys\|\/proc'"'"' -o -prune \) -mmin -70 -type f -name"'
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- feg >/dev/null 2>&1; then'
    printf '%s\n' 'alias feg="find ~/.local/share/gnome-shell/extensions -maxdepth 2 -type f -name metadata.json -print"'
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- mem >/dev/null 2>&1; then'
    printf '%s\n' 'alias mem='"'"'free -h'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ga >/dev/null 2>&1; then'
    printf '%s\n' 'alias ga='"'"'git add .'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gb >/dev/null 2>&1; then'
    printf '%s\n' 'alias gb='"'"'git branch'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gbmain >/dev/null 2>&1; then'
    printf '%s\n' 'alias gbmain='"'"'git branch -M main'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gcll >/dev/null 2>&1; then'
    printf '%s\n' 'alias gcll='"'"'git config --list --local'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gcoa >/dev/null 2>&1; then'
    printf '%s\n' 'alias gcoa='"'"'git commit -a '"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gco1 >/dev/null 2>&1; then'
    printf '%s\n' 'alias gco1='"'"'git commit -m '"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gcue >/dev/null 2>&1; then'
    printf '%s\n' 'alias gcue='"'"'git config user.email'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gcun >/dev/null 2>&1; then'
    printf '%s\n' 'alias gcun='"'"'git config user.name'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gd >/dev/null 2>&1; then'
    printf '%s\n' 'alias gd='"'"'git diff --cached --name-status'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gi >/dev/null 2>&1; then'
    printf '%s\n' 'alias gi='"'"'git init'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gls >/dev/null 2>&1; then'
    printf '%s\n' 'alias gls='"'"'git ls-files'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- glog >/dev/null 2>&1; then'
    printf '%s\n' 'alias glog='"'"'git log --oneline --graph --decorate --all'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gp >/dev/null 2>&1; then'
    printf '%s\n' 'alias gp='"'"'git push -u origin main'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gr >/dev/null 2>&1; then'
    printf '%s\n' 'alias gr='"'"'git remote -v'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gra >/dev/null 2>&1; then'
    printf '%s\n' 'alias gra='"'"'git remote add origin'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- grs >/dev/null 2>&1; then'
    printf '%s\n' 'alias grs='"'"'git remote show origin'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gs >/dev/null 2>&1; then'
    printf '%s\n' 'alias gs='"'"'git status'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- gsi >/dev/null 2>&1; then'
    printf '%s\n' 'alias gsi='"'"'git status --ignored'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- hermes >/dev/null 2>&1; then'
    printf '%s\n' 'alias hermes='"'"'docker exec -it hermes /opt/hermes/.venv/bin/hermes --tui'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ipr >/dev/null 2>&1; then'
    printf '%s\n' 'alias ipr='"'"'ip route'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ipt0 >/dev/null 2>&1; then'
    printf '%s\n' 'alias ipt0='"'"'/root/fwoff.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ipt1 >/dev/null 2>&1; then'
    printf '%s\n' 'alias ipt1='"'"'/root/fwon.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- iptd >/dev/null 2>&1; then'
    printf '%s\n' 'alias iptd='"'"'iptables -L DOCKER -nvx'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ipti >/dev/null 2>&1; then'
    printf '%s\n' 'alias ipti='"'"'iptables -L INPUT -nvx'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- iptf >/dev/null 2>&1; then'
    printf '%s\n' 'alias iptf='"'"'iptables -L FORWARD -nvx'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ipto >/dev/null 2>&1; then'
    printf '%s\n' 'alias ipto='"'"'iptables -L OUTPUT -nvx'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- isd >/dev/null 2>&1; then'
    printf '%s\n' 'alias isd='"'"'ipset destroy'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- isf >/dev/null 2>&1; then'
    printf '%s\n' 'alias isf='"'"'ipset flush'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- isl >/dev/null 2>&1; then'
    printf '%s\n' 'alias isl='"'"'ipset -name list'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- j >/dev/null 2>&1; then'
    printf '%s\n' 'alias j='"'"'journalctl -f'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- jf >/dev/null 2>&1; then'
    printf '%s\n' 'alias jf='"'"'journalctl -feu'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- jx >/dev/null 2>&1; then'
    printf '%s\n' 'alias jx='"'"'journalctl -xeu'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- lo >/dev/null 2>&1; then'
    printf '%s\n' 'alias lo='"'"'locate'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- la >/dev/null 2>&1; then'
    printf '%s\n' 'alias la='"'"'ls -lA --color'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ll >/dev/null 2>&1; then'
    printf '%s\n' 'alias ll='"'"'ls -lah --color'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- lll >/dev/null 2>&1; then'
    printf '%s\n' 'alias lll='"'"'ls -las --color'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ls >/dev/null 2>&1; then'
    printf '%s\n' 'alias ls='"'"'ls --color'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- logs >/dev/null 2>&1; then'
    printf '%s\n' 'alias logs='"'"'more /var/log/syslog'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- n >/dev/null 2>&1; then'
    printf '%s\n' 'alias n='"'"'nano'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ndc >/dev/null 2>&1; then'
    printf '%s\n' 'alias ndc='"'"'nano /home/docker/proxy/docker-compose.yml'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ndipb >/dev/null 2>&1; then'
    printf '%s\n' 'alias ndipb='"'"'nano /home/docker/inits/postgres/bases.sql'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nedd >/dev/null 2>&1; then'
    printf '%s\n' 'alias nedd='"'"'nano /etc/docker/daemon.json'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nedns >/dev/null 2>&1; then'
    printf '%s\n' 'alias nedns='"'"'nano /etc/resolv.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- neni >/dev/null 2>&1; then'
    printf '%s\n' 'alias neni='"'"'nano /etc/network/interfaces'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nef >/dev/null 2>&1; then'
    printf '%s\n' 'alias nef='"'"'nano /etc/fstab'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- neg >/dev/null 2>&1; then'
    printf '%s\n' 'alias neg='"'"'nano /etc/group'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- neh >/dev/null 2>&1; then'
    printf '%s\n' 'alias neh='"'"'nano /etc/hosts'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nehc >/dev/null 2>&1; then'
    printf '%s\n' 'alias nehc='"'"'nano /etc/host.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nep >/dev/null 2>&1; then'
    printf '%s\n' 'alias nep='"'"'nano /etc/passwd'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ner >/dev/null 2>&1; then'
    printf '%s\n' 'alias ner='"'"'nano /etc/rsyslog.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ner1 >/dev/null 2>&1; then'
    printf '%s\n' 'alias ner1='"'"'nano /etc/rsyslog.d/1-kernel.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nerc >/dev/null 2>&1; then'
    printf '%s\n' 'alias nerc='"'"'nano /etc/rc.local'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nerd >/dev/null 2>&1; then'
    printf '%s\n' 'alias nerd='"'"'nano /etc/rsyslog.d/default.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nerp >/dev/null 2>&1; then'
    printf '%s\n' 'alias nerp='"'"'nano /etc/rsyslog.d/postfix.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nesj >/dev/null 2>&1; then'
    printf '%s\n' 'alias nesj='"'"'nano /etc/systemd/journald.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nesshd >/dev/null 2>&1; then'
    printf '%s\n' 'alias nesshd='"'"'nano /etc/ssh/sshd_config'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- netv >/dev/null 2>&1; then'
    printf '%s\n' 'alias netv='"'"'nano /etc/tmpfiles.d/var2log.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- neu >/dev/null 2>&1; then'
    printf '%s\n' 'alias neu='"'"'nano /etc/ulogd.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ng >/dev/null 2>&1; then'
    printf '%s\n' 'alias ng='"'"'nano /etc/group'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nm >/dev/null 2>&1; then'
    printf '%s\n' 'alias nm='"'"'nano /etc/monero/monerod.conf'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- np >/dev/null 2>&1; then'
    printf '%s\n' 'alias np='"'"'nano /etc/passwd'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ndiu >/dev/null 2>&1; then'
    printf '%s\n' 'alias ndiu='"'"'nano /root/diu/root-install-debian.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nriv >/dev/null 2>&1; then'
    printf '%s\n' 'alias nriv='"'"'nano /root/diu/variables.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nriidjd >/dev/null 2>&1; then'
    printf '%s\n' 'alias nriidjd='"'"'nano /root/root-install-init-django-dev.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nriidjp >/dev/null 2>&1; then'
    printf '%s\n' 'alias nriidjp='"'"'nano /root/root-install-init-django-prod.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nriim >/dev/null 2>&1; then'
    printf '%s\n' 'alias nriim='"'"'nano /root/root-install-init-monero.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nriip >/dev/null 2>&1; then'
    printf '%s\n' 'alias nriip='"'"'nano /root/root-install-init-p2pool.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nriix >/dev/null 2>&1; then'
    printf '%s\n' 'alias nriix='"'"'nano /root/root-install-init-xmrig.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nriw >/dev/null 2>&1; then'
    printf '%s\n' 'alias nriw='"'"'nano root-install-wazuh-step-by-step-single-node.sh'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nt >/dev/null 2>&1; then'
    printf '%s\n' 'alias nt='"'"'nano /etc/tor/torrc'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ntd >/dev/null 2>&1; then'
    printf '%s\n' 'alias ntd='"'"'nano /home/docker/proxy/traefik-data/configurations/dynamic.yml'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ntdpixs >/dev/null 2>&1; then'
    printf '%s\n' 'alias ntdpixs='"'"'nano /home/docker/proxy/traefik-data/configurations/1-stack-pixs.yml'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nts >/dev/null 2>&1; then'
    printf '%s\n' 'alias nts='"'"'nano /home/docker/proxy/traefik-data/static.yml'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nulfdp >/dev/null 2>&1; then'
    printf '%s\n' 'alias nulfdp='"'"'nano /usr/lib/firefox-esr/distribution/policies.json'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- nz >/dev/null 2>&1; then'
    printf '%s\n' 'alias nz='"'"'nano /root/.zshrc'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- net >/dev/null 2>&1; then'
    printf '%s\n' 'alias net='"'"'netstat -plantu'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ocv >/dev/null 2>&1; then'
    printf '%s\n' 'alias ocv='"'"'/opsx:verify'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- oca >/dev/null 2>&1; then'
    printf '%s\n' 'alias oca='"'"'/opsx:apply'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ocar >/dev/null 2>&1; then'
    printf '%s\n' 'alias ocar='"'"'/opsx:archive'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- occ >/dev/null 2>&1; then'
    printf '%s\n' 'alias occ='"'"'/opsx:continue'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- oce >/dev/null 2>&1; then'
    printf '%s\n' 'alias oce='"'"'/opsx:explore'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ocp >/dev/null 2>&1; then'
    printf '%s\n' 'alias ocp='"'"'/opsx:propose'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ocs >/dev/null 2>&1; then'
    printf '%s\n' 'alias ocs='"'"'/opsx:sync'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- os >/dev/null 2>&1; then'
    printf '%s\n' 'alias os='"'"'openspec --version'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- osi >/dev/null 2>&1; then'
    printf '%s\n' 'alias osi='"'"'openspec init --tools opencode --profile custom'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- oscl >/dev/null 2>&1; then'
    printf '%s\n' 'alias oscl='"'"'openspec config list'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- oscp >/dev/null 2>&1; then'
    printf '%s\n' 'alias oscp='"'"'openspec config path'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- oscpr >/dev/null 2>&1; then'
    printf '%s\n' 'alias oscpr='"'"'openspec config schema'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- oscgd >/dev/null 2>&1; then'
    printf '%s\n' 'alias oscgd='"'"'oopenspec config get delivery'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- oscgp >/dev/null 2>&1; then'
    printf '%s\n' 'alias oscgp='"'"'oopenspec config get profile'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- oscgt >/dev/null 2>&1; then'
    printf '%s\n' 'alias oscgt='"'"'oopenspec config get telemetry.enabled'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- osl >/dev/null 2>&1; then'
    printf '%s\n' 'alias osl='"'"'openspec list'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- osnc >/dev/null 2>&1; then'
    printf '%s\n' 'alias osnc='"'"'openspec new change'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- oss >/dev/null 2>&1; then'
    printf '%s\n' 'alias oss='"'"'openspec status'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- osshe >/dev/null 2>&1; then'
    printf '%s\n' 'alias osshe='"'"'openspec schemas'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ossho >/dev/null 2>&1; then'
    printf '%s\n' 'alias ossho='"'"'openspec show'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- osu >/dev/null 2>&1; then'
    printf '%s\n' 'alias osu='"'"'openspec update'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- osv >/dev/null 2>&1; then'
    printf '%s\n' 'alias osv='"'"'openspec validate'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ovs >/dev/null 2>&1; then'
    printf '%s\n' 'alias ovs='"'"'ovs-vsctl'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ovss >/dev/null 2>&1; then'
    printf '%s\n' 'alias ovss='"'"'ovs-vsctl show'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2pb >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2pb='"'"'echo "bans" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2pe >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2pe='"'"'echo "exit" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2ph >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2ph='"'"'echo "hosts" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2phelp >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2phelp='"'"'echo "help" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2plog0 >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2plog0='"'"'echo "loglevel 0" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2plog1 >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2plog1='"'"'echo "loglevel 1" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2plog2 >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2plog2='"'"'echo "loglevel 2" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2plog3 >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2plog3='"'"'echo "loglevel 3" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2pp >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2pp='"'"'echo "peers" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2ps >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2ps='"'"'echo "status" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2pv >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2pv='"'"'echo "version" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p2pw >/dev/null 2>&1; then'
    printf '%s\n' 'alias p2pw='"'"'echo "workers" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- p >/dev/null 2>&1; then'
    printf '%s\n' 'alias p='"'"'ping -4'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- psc >/dev/null 2>&1; then'
    printf '%s\n' 'alias psc='"'"'ps xawf -eo pid,user,cgroup,args'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- psf >/dev/null 2>&1; then'
    printf '%s\n' 'alias psf='"'"'ps faux'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- pv >/dev/null 2>&1; then'
    printf '%s\n' 'alias pv='"'"' python3 -m pip --version'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- sl >/dev/null 2>&1; then'
    printf '%s\n' 'alias sl='"'"'sesh list'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- sa >/dev/null 2>&1; then'
    printf '%s\n' 'alias sa='"'"'zsh -n ~/.zshrc && source ~/.zshrc && hash -r'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ss >/dev/null 2>&1; then'
    printf '%s\n' 'alias ss='"'"'ss -tulpn'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- s >/dev/null 2>&1; then'
    printf '%s\n' 'alias s='"'"'su -'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- sudev >/dev/null 2>&1; then'
    printf '%s\n' 'alias sudev='"'"'su - devops'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- sudoc >/dev/null 2>&1; then'
    printf '%s\n' 'alias sudoc='"'"'su - docker'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- suia >/dev/null 2>&1; then'
    printf '%s\n' 'alias suia='"'"'su - ia'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- sd >/dev/null 2>&1; then'
    printf '%s\n' 'alias sd='"'"'systemctl disable'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- sdr >/dev/null 2>&1; then'
    printf '%s\n' 'alias sdr='"'"'systemctl daemon-reload'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- se >/dev/null 2>&1; then'
    printf '%s\n' 'alias se='"'"'systemctl enable'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- sss >/dev/null 2>&1; then'
    printf '%s\n' 'alias sss='"'"'systemctl status'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ssrc >/dev/null 2>&1; then'
    printf '%s\n' 'alias ssrc='"'"'systemctl status rc-local.service'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- s0 >/dev/null 2>&1; then'
    printf '%s\n' 'alias s0='"'"'systemctl stop'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- s0rc >/dev/null 2>&1; then'
    printf '%s\n' 'alias s0rc='"'"'systemctl stop rc-local.service'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- s1 >/dev/null 2>&1; then'
    printf '%s\n' 'alias s1='"'"'systemctl start'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- s1rc >/dev/null 2>&1; then'
    printf '%s\n' 'alias s1rc='"'"'systemctl start rc-local.service'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- s01 >/dev/null 2>&1; then'
    printf '%s\n' 'alias s01='"'"'systemctl restart'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- s11 >/dev/null 2>&1; then'
    printf '%s\n' 'alias s11='"'"'systemctl reload'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- sser >/dev/null 2>&1; then'
    printf '%s\n' 'alias sser='"'"'systemctl -t service'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- sdana >/dev/null 2>&1; then'
    printf '%s\n' 'alias sdana='"'"'systemd-analyze'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- sdanab >/dev/null 2>&1; then'
    printf '%s\n' 'alias sdanab='"'"'systemd-analyze blame'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- syscg >/dev/null 2>&1; then'
    printf '%s\n' 'alias syscg='"'"'systemd-cgls'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ta >/dev/null 2>&1; then'
    printf '%s\n' 'alias ta='"'"'tail -f -n 100'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- tam >/dev/null 2>&1; then'
    printf '%s\n' 'alias tam='"'"'tail -f -n 100 /home/monero/monero.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- tap >/dev/null 2>&1; then'
    printf '%s\n' 'alias tap='"'"'tail -f -n 100 /home/monero/p2pool.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- tax >/dev/null 2>&1; then'
    printf '%s\n' 'alias tax='"'"'tail -f -n 100 /home/monero/xmrig.log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- tm >/dev/null 2>&1; then'
    printf '%s\n' 'alias tm='"'"'tmux'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- tma >/dev/null 2>&1; then'
    printf '%s\n' 'alias tma='"'"'tmux attach'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- tmk >/dev/null 2>&1; then'
    printf '%s\n' 'alias tmk='"'"'tmux kill-session -t'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- tml >/dev/null 2>&1; then'
    printf '%s\n' 'alias tml='"'"'tmux ls'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- tvl >/dev/null 2>&1; then'
    printf '%s\n' 'alias tvl='"'"'tree /var/log'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- ze >/dev/null 2>&1; then'
    printf '%s\n' 'alias ze='"'"'zoxide edit'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- zl >/dev/null 2>&1; then'
    printf '%s\n' 'alias zl='"'"'zoxide query -l'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- zq >/dev/null 2>&1; then'
    printf '%s\n' 'alias zq='"'"'zoxide query'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- zshc >/dev/null 2>&1; then'
    printf '%s\n' 'alias zshc='"'"'zsh -n ~/.zshrc'"'"''
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! alias -- oc >/dev/null 2>&1; then'
    cat <<'EOF'
alias oc='if [ ! -f project.env ] || [ ! -r project.env ]; then echo "oc : project.env absent ou illisible, démarrage de la TUI seule."; opencode --standalone; else OPENCODE_PASSWORD="$(python3 -c '\''import shlex; print(shlex.split(next(l.split("=",1)[1] for l in open("project.env") if l.startswith("OPENCODE_PASSWORD=")), comments=True)[0])'\'')" bash -c '\'': "${OPENCODE_PASSWORD:?Mot de passe absent}"; opencode serve --hostname 0.0.0.0 --port 4096 >/dev/null & p=$!; trap "kill $p 2>/dev/null" EXIT; until curl -fsS -u "opencode:$OPENCODE_PASSWORD" http://127.0.0.1:4096/api/info >/dev/null 2>&1; do kill -0 "$p" 2>/dev/null || exit 1; sleep 0.2; done; opencode --server http://127.0.0.1:4096'\''; fi'
EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f sc >/dev/null 2>&1; then'
    cat <<'EOF'

sc() {
  [[ -t 1 ]] || return

  local session

  session=$(sesh list | fzf \
    --prompt="Session > " \
    --preview="sesh connect {} --dry-run 2>/dev/null") || return

  # 1. tmux prioritaire
  if command -v tmux >/dev/null 2>&1; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$session"
    else
      tmux attach -t "$session" 2>/dev/null || tmux new -s "$session"
    fi
    return
  fi

  # 2. zellij fallback
  if command -v zellij >/dev/null 2>&1; then
    if [ -n "$ZELLIJ" ]; then
      zellij action switch-session "$session" 2>/dev/null || zellij attach -c "$session"
    else
      zellij attach "$session" 2>/dev/null || zellij attach -c "$session"
    fi
    return
  fi

  # 3. fallback sesh pur
  sesh connect "$session"
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f ai >/dev/null 2>&1; then'
    cat <<'EOF'

ai() {
  echo "aid		-->		deepseek-v4-flash"
  echo "aidc		-->		deepseek-v4-pro"
  echo "aig		-->		gemini-3-flash-preview"
  echo "aiod		-->		deepseek/deepseek-v4-flash"
  echo "aiodc		-->		deepseek/deepseek-v4-pro"
  echo "aiog		-->		z-ai/glm-5.1"
  echo "aiok		-->		moonshotai/kimi-k2.6"
  echo "aiol		-->		inclusionai/ling-2.6-1t:free"
  echo "aiom5		-->		minimax/minimax-m2.5:free"
  echo "aiom7		-->		minimax/minimax-m2.7"
  echo "aioq		-->		qwen/qwen3.6-plus"
  echo "aip		-->		Perplexity"
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aid >/dev/null 2>&1; then'
    cat <<'EOF'

aid() {
  local MODEL="deepseek-v4-flash"   # deepseek-v4-flash / deepseek-v4-pro
  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponds uniquement en français de façon concise mais complète."

  # Génération JSON
  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    --arg model "$MODEL" \
    '{
      model: $model,
      messages: [
        {
          role: "system",
          content: $rules
        },
        {
          role: "user",
          content: $text
        }
      ],
      temperature: 0.5,
      top_p: 0.9,
      max_tokens: 1024,
      stream: false
    }')

  # Appel API DeepSeek
  curl -sk \
    https://api.deepseek.com/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_DEEPSEEK_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aidc >/dev/null 2>&1; then'
    cat <<'EOF'

aidc() {
  local MODEL="deepseek-v4-pro"   # deepseek-v4-flash / deepseek-v4-pro
  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponds uniquement en français de façon concise mais complète."

  # Génération JSON
  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    --arg model "$MODEL" \
    '{
      model: $model,
      messages: [
        {
          role: "system",
          content: $rules
        },
        {
          role: "user",
          content: $text
        }
      ],
      temperature: 0.5,
      top_p: 0.9,
      max_tokens: 1024,
      stream: false
    }')

  # Appel API DeepSeek
  curl -sk \
    https://api.deepseek.com/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_DEEPSEEK_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aig >/dev/null 2>&1; then'
    cat <<'EOF'

aig() {
  local MODEL="gemini-3-flash-preview" # gemini-2.5-flash / gemini-2.5-pro / gemini-3.1-pro-preview / gemma-4-31b-it
  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."
  # Génération JSON
  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    '{
      system_instruction: {
        parts: [
          {
            text: $rules
          }
        ]
      },
      contents: [
        {
          parts: [
            {
              text: $text
            }
          ]
        }
      ],
      generationConfig: {
		  maxOutputTokens: 1024,
		  temperature: 0.5,
		  topP: 0.9
      }
    }')
  # Appel API Google
  curl -sk \
    "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_GEMINI_KEY}" \
    -H "Content-Type: application/json" \
    -d "$payload" | jq -r '.candidates[0].content.parts[0].text'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aiod >/dev/null 2>&1; then'
    cat <<'EOF'

aiod() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "deepseek/deepseek-v4-flash",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aiodc >/dev/null 2>&1; then'
    cat <<'EOF'

aiodc() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "deepseek/deepseek-v4-pro",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aiog >/dev/null 2>&1; then'
    cat <<'EOF'

aiog() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "z-ai/glm-5.1",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aiok >/dev/null 2>&1; then'
    cat <<'EOF'

aiok() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "moonshotai/kimi-k2.6",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aiol >/dev/null 2>&1; then'
    cat <<'EOF'

aiol() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "inclusionai/ling-2.6-1t:free",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aiom5 >/dev/null 2>&1; then'
    cat <<'EOF'

aiom5() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "minimax/minimax-m2.5:free",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aiom7 >/dev/null 2>&1; then'
    cat <<'EOF'

aiom7() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "minimax/minimax-m2.7",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aioq >/dev/null 2>&1; then'
    cat <<'EOF'

aioq() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "qwen/qwen3.6-plus",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
    printf '%s\n' 'fi'
    printf '%s\n' 'if ! typeset -f aip >/dev/null 2>&1; then'
    cat <<'EOF'

aip() {
  local MODEL="auto"
  local PROVIDER="Perplexity"

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponds uniquement en français de façon concise mais complète."

  payload=$(jq -n \
    --arg model "$MODEL" \
    --arg provider "$PROVIDER" \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    '{
      model: $model,
      provider: $provider,
      messages: [
        {
          role: "system",
          content: $rules
        },
        {
          role: "user",
          content: $text
        }
      ],
      temperature: 0.5,
      top_p: 0.9,
      max_tokens: 1024,
      stream: false
    }')

  curl -sk \
    https://g4f.pixs.fr/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Accept-Encoding: identity" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message' | sed '/^> \[[0-9]\+\]/,$d'
}

EOF
    printf '%s\n' 'fi'
}

software_apt_recipe_zsh() {
    local field="${1:-}"
    shift
    set -- zsh "$@"
    local software=zsh release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' zsh
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_ZSH
            ;;
        install_options)
            printf '\n'
            ;;
        remove_action)
            printf '%s\n' remove
            ;;
        install_packages)
            printf '%s\n' zsh zsh-autosuggestions zsh-syntax-highlighting fish fzf tmux zoxide
            ;;
        repository)
            printf '\n'
            ;;
        repository_variable)
            printf '\n'
            ;;
        repository_state_valid)
            return 1
            ;;
        repository_expected)
            printf '\n'
            ;;
        remove_repository)
            printf '0\n'
            ;;
        detector)
            printf '%s\n' software_apt_zsh_detect
            ;;
        artifact_url)
            printf '\n'
            ;;
        environment_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        sensitive_install)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '0\n'
            ;;
        pre_install_hook)
            printf '%s\n' software_apt_preflight_zsh
            ;;
        configuration_hook)
            printf '%s\n' software_apt_configure_zsh
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_zsh_configuration
            ;;
        update_configuration_policy)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf 'explicit\n'
            ;;
        remove_packages)
            software_apt_convergence_package "${1:-}"
            ;;
        pre_remove_hook)
            printf '%s\n' software_apt_prepare_zsh_removal
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" debian ;;
        *) return 2 ;;
    esac
}

software_apt_zsh_detect() { software_apt_package_state zsh; }

software_apt_zsh_root_shell() {
    local record shell
    record="$(getent passwd root)" || return 2
    [[ "$record" == root:*:*:*:*:*:* ]] || return 2
    shell="${record##*:}"
    [[ "$shell" == /* ]] || return 2
    printf '%s\n' "$shell"
}

software_apt_zsh_go_inputs() {
    local user="${ENV_DEVOPS_USER:-}" go_binary
    [[ "${GO:-0}" == 0 || "${GO:-0}" == 1 ]] || return 2
    [[ "${GO:-0}" == 1 ]] || return 0
    [[ "$user" =~ ^[a-z_][a-z0-9_-]*$ ]] || return 2
    [[ -x "/home/$user/go/bin/sesh" ]] && return 0
    go_binary="/home/$user/go/current/bin/go"
    [[ -x "$go_binary" ]] || return 2
}

software_apt_preflight_zsh() {
    local shell
    shell="$(software_apt_zsh_root_shell)" || return 1
    case "$shell" in
        /bin/bash|/usr/bin/bash|*/zsh) ;;
        *) printf '%s\n' 'Shell root personnalisé : configuration Zsh non appliquée.' >&2; return 1 ;;
    esac
    software_apt_zsh_go_inputs
}

software_apt_configure_zsh() {
    local prefix="${1:-/}" shell binary helper user defaults
    software_apt_preflight_zsh || return 1
    shell="$(software_apt_zsh_root_shell)" || return 1
    if [[ "${GO:-0}" == 1 ]]; then
        user="$ENV_DEVOPS_USER"
        if [[ ! -x "/home/$user/go/bin/sesh" ]]; then
            runuser -u "$user" -- env HOME="/home/$user" GOPATH="/home/$user/go" \
                "/home/$user/go/current/bin/go" install github.com/joshmedeski/sesh@latest || return 1
        fi
    fi
    helper="$(software_apt_support_directory)/zsh_configuration.py" || return 1
    defaults="$(software_apt_zsh_defaults)" || return 1
    printf '%s\n' "$defaults" | python3 "$helper" configure-defaults "$prefix" || return 1
    case "$shell" in
        /bin/bash|/usr/bin/bash)
            binary="$(command -v zsh)" || return 1
            [[ "$binary" == /* && -x "$binary" ]] || return 1
            chsh -s "$binary" root || return 1
            ;;
    esac
}

software_apt_check_zsh_configuration() {
    local prefix="${1:-/}" shell helper status user defaults
    shell="$(software_apt_zsh_root_shell)" || return 2
    case "$shell" in
        */zsh) ;;
        /bin/bash|/usr/bin/bash) return 1 ;;
        *) return 2 ;;
    esac
    software_apt_zsh_go_inputs || return 2
    if [[ "${GO:-0}" == 1 ]]; then
        user="$ENV_DEVOPS_USER"
        [[ -x "/home/$user/go/bin/sesh" ]] || return 1
    fi
    helper="$(software_apt_support_directory)/zsh_configuration.py" || return 2
    defaults="$(software_apt_zsh_defaults)" || return 2
    if printf '%s\n' "$defaults" | python3 "$helper" check-defaults "$prefix"; then return 0; else
        status=$?; [[ "$status" == 1 ]] && return 1; return 2
    fi
}

software_apt_prepare_zsh_removal() {
    local records record account shell root_shell='' bash_binary root_seen=0
    records="$(getent passwd)" || return 1
    while IFS= read -r record; do
        account="${record%%:*}"
        shell="${record##*:}"
        if [[ "$account" == root ]]; then (( root_seen += 1 )); fi
        if [[ "$shell" == */zsh ]]; then
            if [[ "$account" == root ]]; then root_shell="$shell"; else
                printf '%s\n' 'Un autre compte utilise Zsh ; retrait automatique refusé.' >&2
                return 1
            fi
        fi
    done <<< "$records"
    [[ "$root_seen" == 1 ]] || return 1
    if [[ -n "$root_shell" ]]; then
        bash_binary="$(command -v bash)" || return 1
        [[ "$bash_binary" == /* && -x "$bash_binary" ]] || return 1
        chsh -s "$bash_binary" root || return 1
        root_shell="$(software_apt_zsh_root_shell)" || return 1
        [[ "$root_shell" == "$bash_binary" ]] || return 1
    fi
}

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "zsh" || return 1
fi
