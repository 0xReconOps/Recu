FROM ubuntu:22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris

# Install required packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    python3 \
    python3-pip \
    gcc \
    make \
    xxd \
    openssl \
    file \
    gdb \
    strace \
    ltrace \
    curl \
    wget \
    vim \
    nano \
    git \
    build-essential \
    sqlite3 \
    tzdata \
    binutils \
    hexedit \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for cryptography
RUN pip3 install pycryptodome cryptography

# Configure SSH
RUN mkdir /var/run/sshd
RUN echo 'root:rootpassword' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create elite user (successor from first challenge)
RUN useradd -m -s /bin/bash eliteuser
RUN echo 'eliteuser:ESGISCTF{1nter@ct1ve_sh3ll_ch@ll3ng3}' | chpasswd

# Create directories for the challenge
RUN mkdir -p /opt/challenge
RUN mkdir -p /var/challenge/logs
RUN mkdir -p /home/eliteuser/workspace

# Copy setup script and run it
COPY setup_expert_challenge.sh /tmp/setup_expert_challenge.sh
RUN chmod +x /tmp/setup_expert_challenge.sh
RUN /tmp/setup_expert_challenge.sh
RUN rm /tmp/setup_expert_challenge.sh

# Setup permissions
RUN chown -R eliteuser:eliteuser /home/eliteuser
RUN chmod 700 /opt/challenge/secure_vault 2>/dev/null || true
RUN chmod +s /opt/challenge/secure_vault/privesc_binary 2>/dev/null || true

# Create SSH host keys
RUN ssh-keygen -A

# Setup firewall-like restrictions
RUN echo "eliteuser ALL=(ALL) NOPASSWD: /bin/netstat, /usr/bin/ss, /usr/bin/python3" >> /etc/sudoers

# Expose SSH port only
EXPOSE 22

# Start SSH daemon
CMD ["/usr/sbin/sshd", "-D"]
