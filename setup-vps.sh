#!/usr/bin/env bash
# setup-vps.sh — Configuration sécurisée VPS Ubuntu/Debian
# Usage : sudo ./setup-vps.sh
#         sudo SSH_PORT=2222 ADMIN_USER=seb TIMEZONE=Europe/Paris DOMAIN=monsite.fr ./setup-vps.sh

set -euo pipefail
trap 'echo -e "\n${RED}[✗] Erreur ligne $LINENO — script interrompu.${RESET}" >&2' ERR

# ── Couleurs ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
log()      { echo -e "${GREEN}[✓]${RESET} $*"; }
log_info() { echo -e "${BLUE}[→]${RESET} $*"; }
log_skip() { echo -e "${YELLOW}[↷]${RESET} $* — déjà présent, on passe."; }
log_warn() { echo -e "${YELLOW}[!]${RESET} $*"; }
die()      { echo -e "${RED}[✗]${RESET} $*" >&2; exit 1; }

is_installed()  { command -v "$1" &>/dev/null; }
pkg_installed() { dpkg -l "$1" 2>/dev/null | grep -q "^ii"; }

# ── Vérifications préalables ──────────────────────────────────────────────────
[[ $EUID -eq 0 ]] || die "Ce script doit être exécuté en root : sudo ./setup-vps.sh"

# shellcheck source=/dev/null
. /etc/os-release
[[ "$ID" == "ubuntu" || "$ID" == "debian" ]] || die "OS non supporté : $ID. Ubuntu ou Debian requis."
ARCH=$(dpkg --print-architecture)
log_info "OS : $PRETTY_NAME ($ARCH)"

# ── Variables (env ou interactive) ────────────────────────────────────────────
SSH_PORT="${SSH_PORT:-}"
ADMIN_USER="${ADMIN_USER:-}"
TIMEZONE="${TIMEZONE:-Europe/Paris}"
DOMAIN="${DOMAIN:-}"
UPTIME_KUMA_PORT="${UPTIME_KUMA_PORT:-3001}"
NETDATA_PORT="${NETDATA_PORT:-19999}"

if [[ -z "$ADMIN_USER" ]]; then
    read -rp "$(echo -e "${CYAN}Nom de l'utilisateur admin à créer :${RESET} ")" ADMIN_USER
fi
[[ -n "$ADMIN_USER" ]] || die "Le nom d'utilisateur ne peut pas être vide."

if [[ -z "$SSH_PORT" ]]; then
    read -rp "$(echo -e "${CYAN}Port SSH [22] :${RESET} ")" SSH_PORT
    SSH_PORT="${SSH_PORT:-22}"
fi

if [[ -z "$DOMAIN" ]]; then
    read -rp "$(echo -e "${CYAN}Domaine principal (laisser vide si aucun) :${RESET} ")" DOMAIN || true
fi

echo ""
echo -e "${BOLD}Récapitulatif :${RESET}"
echo "  Utilisateur admin : $ADMIN_USER"
echo "  Port SSH          : $SSH_PORT"
echo "  Timezone          : $TIMEZONE"
echo "  Domaine           : ${DOMAIN:-aucun}"
echo ""
read -rp "$(echo -e "${CYAN}Continuer ? [o/N] :${RESET} ")" CONFIRM
[[ "$CONFIRM" =~ ^[oOyY]$ ]] || { echo "Annulé."; exit 0; }

# ── 1. Mise à jour système ─────────────────────────────────────────────────────
echo -e "\n${BOLD}── 1. Mise à jour système ──────────────────────────${RESET}"
log_info "Mise à jour des paquets (peut prendre quelques minutes)..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y -qq \
    curl git wget htop net-tools unzip gnupg2 lsb-release \
    ca-certificates software-properties-common ufw chrony \
    openssl 2>/dev/null
log "Système à jour."

CURRENT_TZ=$(timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null || echo "")
if [[ "$CURRENT_TZ" != "$TIMEZONE" ]]; then
    timedatectl set-timezone "$TIMEZONE"
    log "Timezone → $TIMEZONE"
else
    log_skip "Timezone ($TIMEZONE)"
fi

# ── 2. Utilisateur admin ───────────────────────────────────────────────────────
echo -e "\n${BOLD}── 2. Utilisateur admin ────────────────────────────${RESET}"
if id "$ADMIN_USER" &>/dev/null; then
    log_skip "Utilisateur $ADMIN_USER"
else
    ADMIN_PASS=$(openssl rand -base64 18 | tr -d '=+/' | head -c 16)
    useradd -m -s /bin/bash -G sudo "$ADMIN_USER"
    echo "$ADMIN_USER:$ADMIN_PASS" | chpasswd
    chage -d 0 "$ADMIN_USER"
    chmod 700 "/home/$ADMIN_USER"

    # Sauvegarder les credentials de manière sécurisée
    echo "user=$ADMIN_USER pass=$ADMIN_PASS" > /root/admin_credentials.txt
    chmod 600 /root/admin_credentials.txt

    log "Utilisateur $ADMIN_USER créé."
    log_warn "Mot de passe temporaire : ${BOLD}$ADMIN_PASS${RESET}"
    log_warn "Credentials sauvegardés dans /root/admin_credentials.txt — à supprimer après usage !"
fi

# ── 3. Sécurisation SSH ────────────────────────────────────────────────────────
echo -e "\n${BOLD}── 3. Sécurisation SSH ─────────────────────────────${RESET}"
SSH_HARDENING="/etc/ssh/sshd_config.d/99-hardening.conf"

if [[ -f "$SSH_HARDENING" ]]; then
    log_skip "Config SSH hardening ($SSH_HARDENING)"
else
    mkdir -p /etc/ssh/sshd_config.d
    cat > "$SSH_HARDENING" <<EOF
# Généré par setup-vps.sh
Port $SSH_PORT
PermitRootLogin no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
AllowAgentForwarding no
AllowTcpForwarding no
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PrintLastLog yes
Banner /etc/ssh/banner
EOF

    cat > /etc/ssh/banner <<'EOF'
╔══════════════════════════════════════════════════╗
║  Accès non autorisé interdit. Toute connexion    ║
║  est enregistrée et peut faire l'objet de        ║
║  poursuites judiciaires.                         ║
╚══════════════════════════════════════════════════╝
EOF

    systemctl restart ssh
    log "SSH sécurisé — port $SSH_PORT, no root login, max 3 essais."
fi

# ── 4. UFW Firewall ────────────────────────────────────────────────────────────
echo -e "\n${BOLD}── 4. UFW Firewall ─────────────────────────────────${RESET}"
if ufw status 2>/dev/null | grep -q "Status: active"; then
    log_skip "UFW déjà actif"
    # Vérifier que les ports requis sont bien ouverts
    ufw allow "$SSH_PORT"/tcp comment "SSH" &>/dev/null || true
    ufw allow 80/tcp   comment "HTTP"    &>/dev/null || true
    ufw allow 443/tcp  comment "HTTPS"   &>/dev/null || true
    ufw allow 9090/tcp comment "Cockpit" &>/dev/null || true
else
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow "$SSH_PORT"/tcp comment "SSH"
    ufw allow 80/tcp   comment "HTTP"
    ufw allow 443/tcp  comment "HTTPS"
    ufw allow 9090/tcp comment "Cockpit"
    ufw --force enable
    log "UFW activé — ports ouverts : $SSH_PORT, 80, 443, 9090."
fi

# ── 5. Fail2ban ────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}── 5. Fail2ban ─────────────────────────────────────${RESET}"
if pkg_installed fail2ban; then
    log_skip "Fail2ban (paquet)"
else
    apt-get install -y -qq fail2ban
    log "Fail2ban installé."
fi

F2B_LOCAL="/etc/fail2ban/jail.local"
if [[ -f "$F2B_LOCAL" ]]; then
    log_skip "Config Fail2ban ($F2B_LOCAL)"
else
    cat > "$F2B_LOCAL" <<EOF
[DEFAULT]
bantime  = 86400
findtime = 600
maxretry = 3
backend  = systemd

[sshd]
enabled  = true
port     = $SSH_PORT
maxretry = 3
bantime  = 86400

[nginx-http-auth]
enabled  = true
maxretry = 5
bantime  = 3600

[nginx-limit-req]
enabled  = true
maxretry = 10
bantime  = 3600

[nginx-botsearch]
enabled  = true
maxretry = 2
bantime  = 3600
EOF
    systemctl enable --now fail2ban
    log "Fail2ban configuré — SSH : ban 24h après 3 essais."
fi

# ── 6. Nginx ───────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}── 6. Nginx ────────────────────────────────────────${RESET}"
if pkg_installed nginx; then
    log_skip "Nginx (paquet)"
else
    apt-get install -y -qq nginx
    log "Nginx installé."
fi

NGINX_SECURITY="/etc/nginx/conf.d/security.conf"
if [[ -f "$NGINX_SECURITY" ]]; then
    log_skip "Config sécurité Nginx"
else
    cat > "$NGINX_SECURITY" <<'EOF'
# Généré par setup-vps.sh
server_tokens off;

add_header X-Frame-Options          "SAMEORIGIN"                    always;
add_header X-Content-Type-Options   "nosniff"                       always;
add_header X-XSS-Protection         "1; mode=block"                 always;
add_header Referrer-Policy          "strict-origin-when-cross-origin" always;
add_header Permissions-Policy       "geolocation=(), microphone=(), camera=()" always;

# Rate limiting
limit_req_zone  $binary_remote_addr zone=general:10m rate=30r/m;
limit_req_zone  $binary_remote_addr zone=api:10m     rate=10r/m;
limit_conn_zone $binary_remote_addr zone=conn_limit:10m;

# Blocage User-Agents malveillants
map $http_user_agent $blocked_ua {
    default        0;
    ~*nmap         1;
    ~*nikto        1;
    ~*sqlmap       1;
    ~*masscan      1;
    ~*zgrab        1;
    ~*nuclei       1;
    ""             1;
}

# Gzip
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types
    text/plain text/css text/xml
    application/json application/javascript application/xml+rss
    image/svg+xml;
EOF

    # Format de log avec IP réelle
    cat > /etc/nginx/conf.d/log-format.conf <<'EOF'
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';
EOF

    # Logrotate
    cat > /etc/logrotate.d/nginx-custom <<'EOF'
/var/log/nginx/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        [ -f /var/run/nginx.pid ] && kill -USR1 $(cat /var/run/nginx.pid)
    endscript
}
EOF

    nginx -t
    systemctl enable --now nginx
    log "Nginx configuré — security headers, rate limiting, gzip, logrotate 30j."
fi

# ── 7. Cockpit ─────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}── 7. Cockpit ──────────────────────────────────────${RESET}"
if pkg_installed cockpit; then
    log_skip "Cockpit (paquet)"
else
    apt-get install -y -qq cockpit || true
    # Modules optionnels (pas toujours disponibles)
    apt-get install -y -qq cockpit-networkmanager cockpit-packagekit 2>/dev/null || true
    systemctl enable --now cockpit.socket
    log "Cockpit installé — port 9090."
fi

# ── 8. GoAccess ────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}── 8. GoAccess ─────────────────────────────────────${RESET}"
if is_installed goaccess; then
    log_skip "GoAccess"
else
    apt-get install -y -qq goaccess
    log "GoAccess installé."
fi

mkdir -p /var/www/html/stats
chown www-data:www-data /var/www/html/stats

GOACCESS_CRON="/etc/cron.d/goaccess"
if [[ -f "$GOACCESS_CRON" ]]; then
    log_skip "Cron GoAccess"
else
    cat > "$GOACCESS_CRON" <<'EOF'
*/15 * * * * www-data [ -f /var/log/nginx/access.log ] && \
  goaccess /var/log/nginx/access.log \
    -o /var/www/html/stats/index.html \
    --log-format=COMBINED \
    --no-global-config 2>/dev/null
EOF
    chmod 644 "$GOACCESS_CRON"
    log "GoAccess configuré — rapport /stats/ toutes les 15 min."
fi

# ── 9. Netdata ─────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}── 9. Netdata ──────────────────────────────────────${RESET}"
if is_installed netdata; then
    log_skip "Netdata"
else
    log_info "Installation Netdata (script officiel)..."
    curl -fsSL https://get.netdata.cloud/kickstart.sh -o /tmp/netdata-kickstart.sh
    bash /tmp/netdata-kickstart.sh --non-interactive --dont-start-it 2>/dev/null || true
    rm -f /tmp/netdata-kickstart.sh

    # Bind sur localhost uniquement
    NETDATA_CONF="/etc/netdata/netdata.conf"
    if [[ -f "$NETDATA_CONF" ]]; then
        if grep -q "^\s*bind to" "$NETDATA_CONF"; then
            sed -i 's/^\s*bind to.*/    bind to = 127.0.0.1/' "$NETDATA_CONF"
        else
            sed -i '/^\[web\]/a\    bind to = 127.0.0.1' "$NETDATA_CONF"
        fi
    else
        mkdir -p /etc/netdata
        printf '[web]\n    bind to = 127.0.0.1\n' > "$NETDATA_CONF"
    fi

    systemctl enable --now netdata 2>/dev/null || true
    log "Netdata installé — bind 127.0.0.1:$NETDATA_PORT."
fi

# ── 10. Docker + Uptime Kuma ───────────────────────────────────────────────────
echo -e "\n${BOLD}── 10. Docker + Uptime Kuma ────────────────────────${RESET}"
if is_installed docker; then
    log_skip "Docker"
else
    log_info "Installation Docker (script officiel)..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh 2>/dev/null
    rm -f /tmp/get-docker.sh
    id "$ADMIN_USER" &>/dev/null && usermod -aG docker "$ADMIN_USER"
    systemctl enable --now docker
    log "Docker installé."
fi

if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^uptime-kuma$"; then
    log_skip "Conteneur Uptime Kuma"
else
    docker run -d \
        --name uptime-kuma \
        --restart unless-stopped \
        -v uptime-kuma:/app/data \
        -p "127.0.0.1:${UPTIME_KUMA_PORT}:3001" \
        louislam/uptime-kuma:1
    log "Uptime Kuma lancé — bind 127.0.0.1:$UPTIME_KUMA_PORT."
fi

# ── 11. Sysctl hardening ───────────────────────────────────────────────────────
echo -e "\n${BOLD}── 11. Durcissement sysctl ─────────────────────────${RESET}"
SYSCTL_FILE="/etc/sysctl.d/99-vps-hardening.conf"
if [[ -f "$SYSCTL_FILE" ]]; then
    log_skip "Sysctl hardening ($SYSCTL_FILE)"
else
    cat > "$SYSCTL_FILE" <<'EOF'
# Anti-SYN flood
net.ipv4.tcp_syncookies        = 1
net.ipv4.tcp_max_syn_backlog   = 2048

# Désactivation du routage IP
net.ipv4.ip_forward            = 0
net.ipv4.conf.all.forwarding   = 0

# Protection ICMP
net.ipv4.icmp_echo_ignore_broadcasts       = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Anti-spoofing / Anti-MITM
net.ipv4.conf.all.accept_source_route      = 0
net.ipv4.conf.default.accept_source_route  = 0
net.ipv4.conf.all.rp_filter                = 1
net.ipv4.conf.default.rp_filter            = 1
net.ipv4.conf.all.log_martians             = 1

# Pas de redirections ICMP
net.ipv4.conf.all.accept_redirects         = 0
net.ipv4.conf.default.accept_redirects     = 0
net.ipv4.conf.all.send_redirects           = 0

# Randomisation mémoire (ASLR)
kernel.randomize_va_space = 2

# Protection ptrace
kernel.yama.ptrace_scope  = 1
EOF
    sysctl --system &>/dev/null
    log "Sysctl hardening appliqué."
fi

# ── 12. Politique mots de passe ────────────────────────────────────────────────
echo -e "\n${BOLD}── 12. Politique mots de passe ─────────────────────${RESET}"
if pkg_installed libpam-pwquality; then
    log_skip "libpam-pwquality"
else
    apt-get install -y -qq libpam-pwquality
    PWQUALITY="/etc/security/pwquality.conf"
    sed -i 's/^# \?minlen\s*=.*/minlen = 12/'   "$PWQUALITY"
    sed -i 's/^# \?ucredit\s*=.*/ucredit = -1/' "$PWQUALITY"
    sed -i 's/^# \?dcredit\s*=.*/dcredit = -1/' "$PWQUALITY"
    sed -i 's/^# \?ocredit\s*=.*/ocredit = -1/' "$PWQUALITY"
    log "Politique mots de passe : 12 chars min, maj + chiffre + symbole."
fi

# ── 13. Mises à jour automatiques ─────────────────────────────────────────────
echo -e "\n${BOLD}── 13. Mises à jour automatiques ───────────────────${RESET}"
if pkg_installed unattended-upgrades; then
    log_skip "unattended-upgrades"
else
    apt-get install -y -qq unattended-upgrades
    echo 'Unattended-Upgrade::Automatic-Reboot "false";' \
        >> /etc/apt/apt.conf.d/50unattended-upgrades
    systemctl enable --now unattended-upgrades
    log "unattended-upgrades activé (patches sécurité, sans redémarrage auto)."
fi

# ── Résumé ─────────────────────────────────────────────────────────────────────
SERVER_IP=$(hostname -I | awk '{print $1}')
echo ""
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}  ✓  Setup VPS terminé !${RESET}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${CYAN}Cockpit${RESET}       → https://${SERVER_IP}:9090"
echo -e "  ${CYAN}GoAccess${RESET}      → http://${SERVER_IP}/stats/"
echo -e "  ${CYAN}Uptime Kuma${RESET}   → http://127.0.0.1:${UPTIME_KUMA_PORT}  (local / reverse proxy)"
echo -e "  ${CYAN}Netdata${RESET}       → http://127.0.0.1:${NETDATA_PORT}  (local / reverse proxy)"
echo ""
echo -e "  ${YELLOW}Prochaines étapes :${RESET}"
echo -e "  1. Ajouter votre clé SSH :"
echo -e "     ssh-copy-id -p $SSH_PORT $ADMIN_USER@$SERVER_IP"
echo -e "  2. Désactiver l'auth par mot de passe (après étape 1) :"
echo -e "     Éditer $SSH_HARDENING → PasswordAuthentication no"
if [[ -n "$DOMAIN" ]]; then
echo -e "  3. Installer SSL :"
echo -e "     certbot --nginx -d $DOMAIN -d www.$DOMAIN"
fi
echo ""
if [[ -f /root/admin_credentials.txt ]]; then
    echo -e "  ${RED}${BOLD}⚠  Supprimer /root/admin_credentials.txt après avoir noté le mot de passe !${RESET}"
fi
echo ""
