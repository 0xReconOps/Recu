FROM ubuntu:22.04


RUN apt-get update && apt-get install -y \
    openssh-server \
    gzip \
    file \
    coreutils \
    bash \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN echo 'root:rootpassword' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config


RUN useradd -m -s /bin/rbash w4rn1ng
RUN echo 'w4rn1ng:buff3r0v3rf10w15Fun' | chpasswd

RUN mkdir -p /home/w4rn1ng/bin
RUN ln -s /bin/ls /home/w4rn1ng/bin/ls
RUN ln -s /bin/cat /home/w4rn1ng/bin/cat
RUN ln -s /bin/echo /home/w4rn1ng/bin/echo
RUN ln -s /usr/bin/file /home/w4rn1ng/bin/file
RUN ln -s /bin/gzip /home/w4rn1ng/bin/gzip
RUN ln -s /usr/bin/base64 /home/w4rn1ng/bin/base64

RUN echo 'export PATH=/home/w4rn1ng/bin' >> /home/w4rn1ng/.bashrc
RUN echo 'export PATH=/home/w4rn1ng/bin' >> /home/w4rn1ng/.bash_profile
RUN chown w4rn1ng:w4rn1ng /home/w4rn1ng/.bashrc /home/w4rn1ng/.bash_profile

RUN chattr +i /home/w4rn1ng/.bashrc /home/w4rn1ng/.bash_profile 2>/dev/null || true

COPY setup_challenge.sh /tmp/setup_challenge.sh
RUN chmod +x /tmp/setup_challenge.sh
RUN /tmp/setup_challenge.sh
RUN rm /tmp/setup_challenge.sh

RUN chown -R w4rn1ng:w4rn1ng /home/w4rn1ng
RUN chmod -R 755 /home/w4rn1ng

RUN ssh-keygen -A

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
