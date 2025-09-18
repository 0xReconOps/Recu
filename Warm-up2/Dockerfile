FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris

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

RUN pip3 install pycryptodome cryptography

RUN mkdir /var/run/sshd
RUN echo 'root:rootpassword' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN useradd -m -s /bin/bash w4rn1ng
RUN echo 'w4rn1ng:ESGISCTF{1nter@ct1ve_sh3ll_ch@ll3ng3}' | chpasswd

RUN mkdir -p /opt/challenge
RUN mkdir -p /var/challenge/logs
RUN mkdir -p /home/w4rn1ng/workspace

COPY setup_expert_challenge.sh /tmp/setup_expert_challenge.sh
RUN chmod +x /tmp/setup_expert_challenge.sh
RUN /tmp/setup_expert_challenge.sh
RUN rm /tmp/setup_expert_challenge.sh

RUN chown -R w4rn1ng:w4rn1ng /home/w4rn1ng
RUN chmod 700 /opt/challenge/secure_vault 2>/dev/null || true
RUN chmod +s /opt/challenge/secure_vault/privesc_binary 2>/dev/null || true

RUN ssh-keygen -A

RUN echo "w4rn1ng ALL=(ALL) NOPASSWD: /bin/netstat, /usr/bin/ss, /usr/bin/python3" >> /etc/sudoers


EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
