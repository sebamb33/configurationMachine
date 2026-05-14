# 🖥️ Setup VPS Sécurisé — Documentation complète
> Stack : **Ubuntu / Debian** · Nginx · Cockpit · UFW · Fail2ban · GoAccess · Netdata · Uptime Kuma

---

## Table des matières
1. [Vue d'ensemble](#vue-densemble)
2. [Prérequis](#prérequis)
3. [Utilisation du script](#utilisation-du-script)
4. [Ce que fait le script](#ce-que-fait-le-script)
5. [Interfaces web disponibles](#interfaces-web-disponibles)
6. [Après l'installation — étapes manuelles](#après-linstallation--étapes-manuelles)
7. [Ajouter un site web (vhost Nginx)](#ajouter-un-site-web-vhost-nginx)
8. [Gérer le firewall via Cockpit](#gérer-le-firewall-via-cockpit)
9. [Commandes utiles](#commandes-utiles)
10. [Architecture de sécurité](#architecture-de-sécurité)
11. [Variables d'environnement du script](#variables-denvironnement-du-script)
12. [Dépannage](#dépannage)

---

## Vue d'ensemble

```
Internet
    │
    ▼
[UFW Firewall]  ←── Fail2ban bloque les IPs malveillantes
    │
    ▼
[Nginx :80/:443]
    ├── Sites web (vhosts)
    ├── /stats/          → GoAccess (stats de visites)
    └── reverse proxy    → Netdata / Uptime Kuma (en local)
    │
    ▼
[Cockpit :9090]  → Administration système + Firewall web UI
```

---

## Prérequis

| Élément | Minimum |
|---|---|
| OS | Ubuntu 20.04+ ou Debian 10+ |
| RAM | 1 Go (2 Go recommandés) |
| Disque | 10 Go libres |
| Accès | root ou sudo |
| Réseau | Connexion internet sur le VPS |

---

## Utilisation du script

### Installation basique (interactive)
```bash
wget https://raw.githubusercontent.com/sebamb33/configurationMachine/main/setup-vps.sh
chmod +x setup-vps.sh
sudo ./setup-vps.sh
```

Le script pose 3 questions :
- Nom de l'utilisateur admin à créer
- Domaine principal (optionnel)
- Port SSH souhaité (défaut : 22)

### Installation silencieuse (via variables)
```bash
sudo SSH_PORT=2222 \
     ADMIN_USER=monuser \
     TIMEZONE=Europe/Paris \
     DOMAIN=monsite.fr \
     ./setup-vps.sh
```

> Le script est **idempotent** : il vérifie si chaque outil est déjà installé avant d'agir. Safe à relancer.

---

## Ce que fait le script

### 1. Mise à jour système
- `apt update && apt upgrade` complet
- Installation des paquets utilitaires (`curl`, `git`, `htop`, `net-tools`...)

### 2. Création utilisateur admin
- Crée un utilisateur non-root avec `sudo`
- Génère un mot de passe aléatoire sécurisé (16 caractères)
- Force le changement de mot de passe à la première connexion
- Sauvegarde les credentials dans `/root/admin_credentials.txt` (chmod 600)

### 3. Sécurisation SSH
- Désactivation du login root via SSH
- Limitation des tentatives (`MaxAuthTries 3`)
- Timeout de session (`ClientAliveInterval 300`)
- Désactivation X11 forwarding, agent forwarding
- Bannière d'avertissement à la connexion
- Fichier de config séparé `/etc/ssh/sshd_config.d/99-hardening.conf`

### 4. Firewall UFW

Ports ouverts par défaut :

| Port | Protocole | Service |
|---|---|---|
| SSH_PORT | TCP | SSH |
| 80 | TCP | HTTP (Nginx) |
| 443 | TCP | HTTPS (Nginx) |
| 9090 | TCP | Cockpit |

Netdata et Uptime Kuma sont en **localhost uniquement** (accessibles via reverse proxy Nginx).

### 5. Fail2ban

Protections actives :

| Jail | Cible | Seuil | Ban |
|---|---|---|---|
| sshd | Tentatives SSH | 3 essais | 24h |
| nginx-http-auth | Auth Nginx | 5 essais | 1h |
| nginx-limit-req | Rate limit | 10 dépassements | 1h |
| nginx-botsearch | Bots/scans | 2 essais | 1h |

### 6. Nginx
- `server_tokens off` — cache la version Nginx
- Headers sécurité : `X-Frame-Options`, `X-Content-Type-Options`, `X-XSS-Protection`, `Referrer-Policy`
- Blocage des User-Agents malveillants (nmap, nikto, sqlmap, nuclei...)
- Rate limiting : 30 req/min général, 10 req/min API
- Blocage accès aux fichiers sensibles (`.env`, `.log`, `.bak`, `.sql`)
- Gzip activé pour les performances
- Logrotate configuré (30 jours de rétention)

### 7. Cockpit
- Interface web d'administration sur le port **9090**
- Modules : réseau, firewall, terminal, services, mises à jour

### 8. GoAccess
- Analyse des logs Nginx en temps réel
- Rapport HTML régénéré **toutes les 15 minutes** via cron
- Rapport disponible dans `/var/www/html/stats/`

### 9. Netdata
- Monitoring temps réel CPU, RAM, réseau, disque
- Bind sur `127.0.0.1` uniquement (sécurisé)
- Accessible via reverse proxy Nginx

### 10. Docker + Uptime Kuma
- Docker CE installé depuis les dépôts officiels
- Uptime Kuma lancé en conteneur avec restart automatique
- Bind sur `127.0.0.1:3001` (sécurisé, accessible via reverse proxy)

### 11. Durcissement système (sysctl)
- Protection SYN flood (`tcp_syncookies`)
- Désactivation du routage IP
- Protection ICMP
- Anti-MITM (`rp_filter`)
- ASLR (randomisation mémoire)
- Protection ptrace

### 12. Politique de mots de passe
- `libpam-pwquality` : min 12 caractères, majuscule + chiffre + symbole

### 13. Mises à jour automatiques
- `unattended-upgrades` configuré pour les patches de sécurité uniquement
- Pas de redémarrage automatique (à faire manuellement)

---

## Interfaces web disponibles

| Service | URL | Accès |
|---|---|---|
| **Cockpit** (admin) | `https://IP:9090` | Externe |
| **GoAccess** (stats visites) | `http://IP/stats/` | Externe |
| **Uptime Kuma** (uptime) | `http://127.0.0.1:3001` | Local / reverse proxy |
| **Netdata** (monitoring) | `http://127.0.0.1:19999` | Local / reverse proxy |

> **Recommandation** : Exposer Uptime Kuma et Netdata via un sous-domaine Nginx avec HTTPS et authentification basique.

---

## Après l'installation — étapes manuelles

### Étape 1 — Ajouter votre clé SSH (recommandé fortement)

Sur votre machine locale :
```bash
ssh-copy-id -p SSH_PORT ADMIN_USER@IP_SERVEUR
```

Ou manuellement sur le serveur :
```bash
mkdir -p /home/ADMIN_USER/.ssh
echo "votre-cle-publique-ssh" >> /home/ADMIN_USER/.ssh/authorized_keys
chmod 700 /home/ADMIN_USER/.ssh
chmod 600 /home/ADMIN_USER/.ssh/authorized_keys
chown -R ADMIN_USER:ADMIN_USER /home/ADMIN_USER/.ssh
```

### Étape 2 — Désactiver l'auth par mot de passe SSH (après avoir ajouté votre clé)
```bash
# Dans /etc/ssh/sshd_config.d/99-hardening.conf
PasswordAuthentication no
systemctl restart ssh
```

### Étape 3 — Installer SSL avec Certbot
```bash
apt install certbot python3-certbot-nginx -y
certbot --nginx -d monsite.fr -d www.monsite.fr
```

### Étape 4 — Configurer Uptime Kuma
1. Ouvrir un tunnel SSH local :
   ```bash
   ssh -L 3001:127.0.0.1:3001 -p SSH_PORT ADMIN_USER@IP_SERVEUR
   ```
2. Aller sur `http://localhost:3001`
3. Créer le compte admin Uptime Kuma
4. Ajouter vos sites à surveiller

### Étape 5 — Exposer Uptime Kuma via Nginx (optionnel)

Créer `/etc/nginx/sites-available/uptime.monsite.fr` :
```nginx
server {
    listen 443 ssl;
    server_name uptime.monsite.fr;
    ssl_certificate     /etc/letsencrypt/live/uptime.monsite.fr/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/uptime.monsite.fr/privkey.pem;

    auth_basic "Accès restreint";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```
```bash
ln -s /etc/nginx/sites-available/uptime.monsite.fr /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

---

## Ajouter un site web (vhost Nginx)

Créer `/etc/nginx/sites-available/monsite.fr` :
```nginx
server {
    listen 80;
    server_name monsite.fr www.monsite.fr;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name monsite.fr www.monsite.fr;

    ssl_certificate     /etc/letsencrypt/live/monsite.fr/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/monsite.fr/privkey.pem;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    root  /var/www/monsite.fr;
    index index.html index.php;

    access_log /var/log/nginx/monsite.fr.access.log main;
    error_log  /var/log/nginx/monsite.fr.error.log;

    location / {
        limit_req zone=general burst=30 nodelay;
        try_files $uri $uri/ =404;
    }

    location ~ /\.         { deny all; }
    location ~* \.(env|log|bak|sql)$ { deny all; }
}
```

```bash
ln -s /etc/nginx/sites-available/monsite.fr /etc/nginx/sites-enabled/
mkdir -p /var/www/monsite.fr
nginx -t && systemctl reload nginx
certbot --nginx -d monsite.fr -d www.monsite.fr
```

---

## Gérer le firewall via Cockpit

1. Aller sur `https://IP:9090`
2. Se connecter avec `ADMIN_USER`
3. Menu **Networking** → **Firewall**
4. Ajouter / supprimer des règles via l'interface graphique

---

## Commandes utiles

### UFW (Firewall)
```bash
ufw status verbose           # État du firewall
ufw allow 8080/tcp           # Ouvrir un port
ufw deny 8080/tcp            # Bloquer un port
ufw delete allow 8080/tcp    # Supprimer une règle
ufw reload                   # Recharger les règles
```

### Fail2ban
```bash
fail2ban-client status               # Jails actives
fail2ban-client status sshd          # Détails jail SSH
fail2ban-client unban IP_ADDRESS     # Débloquer une IP
fail2ban-client get sshd bantime     # Voir le temps de ban
```

### Nginx
```bash
nginx -t                             # Tester la configuration
systemctl reload nginx               # Recharger sans coupure
tail -f /var/log/nginx/access.log    # Logs en temps réel
tail -f /var/log/nginx/error.log     # Erreurs en temps réel
```

### GoAccess
```bash
# Rapport HTML complet
goaccess /var/log/nginx/access.log \
    -o /var/www/html/stats/index.html \
    --log-format=COMBINED

# Mode interactif dans le terminal
goaccess /var/log/nginx/access.log --log-format=COMBINED
```

### Docker / Uptime Kuma
```bash
docker ps                            # Conteneurs actifs
docker logs uptime-kuma              # Logs Uptime Kuma
docker restart uptime-kuma           # Redémarrer
```

### Netdata
```bash
systemctl status netdata
curl http://127.0.0.1:19999/api/v1/info
```

---

## Architecture de sécurité

```
Couche 1 — Réseau
  UFW          → N'autorise que les ports strictement nécessaires
  sysctl       → Anti-flood, anti-MITM, désactivation routage

Couche 2 — Détection / Blocage
  Fail2ban     → Détecte et bloque les IP après N tentatives
  Nginx limits → Rate limiting par IP

Couche 3 — Application
  Nginx        → Headers sécurité, blocage bots, filtrage User-Agents
  SSH          → No root login, max 3 essais, clés SSH recommandées

Couche 4 — Système
  Mots de passe → Politique renforcée (12 chars, complexité)
  sysctl        → ASLR, ptrace, anti-SYN flood

Couche 5 — Maintenance
  unattended-upgrades → Patches sécurité automatiques
  logrotate           → Rotation des logs (30 jours)
  chrony              → NTP synchronisé
```

---

## Variables d'environnement du script

| Variable | Défaut | Description |
|---|---|---|
| `SSH_PORT` | `22` | Port SSH |
| `TIMEZONE` | `Europe/Paris` | Timezone système |
| `ADMIN_USER` | (demandé) | Nom du compte admin |
| `DOMAIN` | (demandé) | Domaine principal |
| `UPTIME_KUMA_PORT` | `3001` | Port Uptime Kuma |
| `NETDATA_PORT` | `19999` | Port Netdata |

---

## Dépannage

### SSH inaccessible après le script
```bash
# Depuis la console VPS de votre hébergeur :
ufw status
ufw allow 22/tcp
systemctl restart ssh
```

### Fail2ban a banni votre IP
```bash
fail2ban-client unban VOTRE_IP
```

### Nginx ne démarre pas
```bash
nginx -t
journalctl -u nginx -n 50
```

### Uptime Kuma ne répond pas
```bash
docker ps
docker restart uptime-kuma
docker logs uptime-kuma --tail 50
```

### Cockpit inaccessible
```bash
systemctl status cockpit.socket
ufw allow 9090/tcp
systemctl restart cockpit
```
