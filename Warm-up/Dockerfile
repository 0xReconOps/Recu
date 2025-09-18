# Base
FROM ubuntu:22.04

# Désactiver les prompts interactifs pour apt
ENV DEBIAN_FRONTEND=noninteractive

# Mettre à jour et installer les paquets nécessaires
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server python3 python3-pip curl wget nodejs npm gcc make xxd openssl \
    steghide binwalk file gdb strace ltrace netcat-openbsd socat vim nano git build-essential \
    && rm -rf /var/lib/apt/lists/*

# Installer les packages Python et Node.js globaux
RUN pip3 install pycryptodome cryptography
RUN npm install -g express sqlite3

# Configurer SSH
RUN mkdir /var/run/sshd \
    && echo 'root:rootpassword' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Créer l'utilisateur eliteuser
RUN useradd -m -s /bin/bash eliteuser \
    && echo 'eliteuser:ESGISCTF{1nter@ct1ve_sh3ll_ch@ll3ng3}' | chpasswd

# Préparer les dossiers du challenge
RUN mkdir -p /opt/challenge /var/challenge/logs /home/eliteuser/workspace /opt/challenge/secure_vault \
    && chmod 700 /opt/challenge/secure_vault \
    && chown -R eliteuser:eliteuser /home/eliteuser

# Copier le script de setup du challenge
COPY setup_advanced_challenge.sh /tmp/setup_advanced_challenge.sh
RUN chmod +x /tmp/setup_advanced_challenge.sh && /tmp/setup_advanced_challenge.sh

# Copier le service web et le fichier systemd
COPY web_service.js /opt/challenge/web_service.js
COPY challenge.service /etc/systemd/system/challenge.service

COPY start_services.sh /start_services.sh
RUN chmod +x /start_services.sh

# Permissions sur le binaire privesc s'il existe
RUN [ -f /opt/challenge/secure_vault/privesc_binary ] && chmod +s /opt/challenge/secure_vault/privesc_binary || true

# Autorisation sudo limitée pour eliteuser
RUN echo "eliteuser ALL=(ALL) NOPASSWD: /bin/netstat, /usr/bin/ss" >> /etc/sudoers

# Exposer les ports SSH et web
EXPOSE 22 3000

# Démarrer les services via ton script
CMD ["/start_services.sh"]
