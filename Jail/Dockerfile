FROM ubuntu:22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris

# Install required packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    openssh-server \
    socat \
    curl \
    wget \
    vim \
    nano \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir /var/run/sshd
RUN echo 'root:rootpassword' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create challenge user
RUN useradd -m -s /bin/bash pwnuser
RUN echo 'pwnuser:jail2024' | chpasswd

# Create challenge directories
RUN mkdir -p /opt/pyjail
RUN mkdir -p /home/pwnuser/workspace

# Copy challenge files
COPY python_jail.py /opt/pyjail/jail.py
COPY start_jail.sh /opt/pyjail/start_jail.sh
COPY flag.txt /opt/pyjail/flag.txt

# Set permissions
RUN chmod 755 /opt/pyjail/jail.py
RUN chmod 755 /opt/pyjail/start_jail.sh
RUN chmod 644 /opt/pyjail/flag.txt
RUN chown root:root /opt/pyjail/flag.txt

# Create welcome message
COPY welcome.txt /home/pwnuser/README.txt
RUN chown pwnuser:pwnuser /home/pwnuser/README.txt

# Set up the jail service
RUN echo '#!/bin/bash\npython3 /opt/pyjail/jail.py' > /usr/local/bin/pyjail
RUN chmod +x /usr/local/bin/pyjail

# Create SSH host keys
RUN ssh-keygen -A

# Expose ports
EXPOSE 22 9999

# Start services
COPY start_services.sh /start_services.sh
RUN chmod +x /start_services.sh

CMD ["/start_services.sh"]
