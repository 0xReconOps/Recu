#!/bin/bash

# Expert CTF Challenge Setup Script (800 Points)
# Multiple layers: Steganography, Cryptography, Reverse Engineering, Network Analysis, Final Decryption

USER_HOME="/home/eliteuser"
CHALLENGE_DIR="/opt/challenge"
FINAL_FLAG="ESGISCTF{3l1t3_h4ck3r_m4st3r_0f_4ll_d0m41ns_2025}"

echo "=== Setting up EXPERT CTF Challenge (800 points) ==="

# Create challenge directories
mkdir -p $CHALLENGE_DIR/{steganography,cryptography,reverse_engineering,network_analysis,secure_vault,database}
mkdir -p $USER_HOME/{documents,projects,temp,analysis}

# ============== LAYER 1: STEGANOGRAPHY ==============
echo "[1/5] Setting up Steganography layer..."

# Create fake image with hidden data
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAI9jU77zgAAAABJRU5ErkJggg==" | base64 -d > $CHALLENGE_DIR/steganography/vacation.png

# Create hidden message in hex format
echo "48696464656E206D6573736167653A205468652063727970746F677261706879207661756C742068617320612052534120707269766174652D7075626C6963206B657920706169722E204C6F6F6B20666F7220746865206B65797320696E202F6F70742F6368616C6C656E67652F63727970746F677261706879" > $CHALLENGE_DIR/steganography/.hex_data

# Script to decode hex
cat > $CHALLENGE_DIR/steganography/decode_hex.sh << 'EOF'
#!/bin/bash
echo "=== Hex Data Decoder ==="
if [ -f ".hex_data" ]; then
    echo "Found hex data. Decoding..."
    cat .hex_data | xxd -r -p
    echo ""
else
    echo "No hex data found."
fi
EOF
chmod +x $CHALLENGE_DIR/steganography/decode_hex.sh

# ============== LAYER 2: CRYPTOGRAPHY ==============
echo "[2/5] Setting up Cryptography layer..."

# Generate RSA key pair
openssl genrsa -out /tmp/master_private.pem 2048
openssl rsa -in /tmp/master_private.pem -pubout -out /tmp/master_public.pem

# Encrypt next clue with RSA
echo "Network analysis required: A hidden service is listening on localhost. Scan for unusual processes and examine the binary in /opt/challenge/reverse_engineering/" > /tmp/crypto_clue.txt
openssl rsautl -encrypt -pubin -inkey /tmp/master_public.pem -in /tmp/crypto_clue.txt -out $CHALLENGE_DIR/cryptography/encrypted_message.bin

# Hide private key pieces in different files
split -b 400 /tmp/master_private.pem $CHALLENGE_DIR/cryptography/fragment_
mv $CHALLENGE_DIR/cryptography/fragment_aa $CHALLENGE_DIR/cryptography/key_alpha.pem
mv $CHALLENGE_DIR/cryptography/fragment_ab $CHALLENGE_DIR/cryptography/key_beta.pem
mv $CHALLENGE_DIR/cryptography/fragment_ac $CHALLENGE_DIR/cryptography/key_gamma.pem
mv $CHALLENGE_DIR/cryptography/fragment_ad $CHALLENGE_DIR/cryptography/key_delta.pem
mv $CHALLENGE_DIR/cryptography/fragment_ae $CHALLENGE_DIR/cryptography/key_epsilon.pem

# Create reconstruction script
cat > $CHALLENGE_DIR/cryptography/reconstruct_key.py << 'EOF'
#!/usr/bin/env python3
import os
import subprocess

print("=== RSA Key Reconstruction Tool ===")
print("Looking for key fragments...")

fragments = []
for file in sorted(os.listdir('.')):
    if file.startswith('key_') and file.endswith('.pem'):
        fragments.append(file)
        print(f"Found fragment: {file}")

if len(fragments) >= 5:
    print("\nReconstructing private key...")
    with open('reconstructed_private.pem', 'w') as output:
        for fragment in fragments:
            with open(fragment, 'r') as f:
                output.write(f.read())
    
    print("Key reconstructed! File: reconstructed_private.pem")
    print("You can now decrypt the message with:")
    print("openssl rsautl -decrypt -inkey reconstructed_private.pem -in encrypted_message.bin")
else:
    print(f"Only found {len(fragments)} fragments. Need all pieces to reconstruct.")
EOF
chmod +x $CHALLENGE_DIR/cryptography/reconstruct_key.py

# ============== LAYER 3: REVERSE ENGINEERING ==============
echo "[3/5] Setting up Reverse Engineering layer..."

# Create vulnerable C program with hidden functionality
cat > /tmp/security_scanner.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void secret_backdoor() {
    printf("🎉 BACKDOOR ACTIVATED! 🎉\n");
    printf("Network Analysis Hint:\n");
    printf("- A Python service is running on localhost:8888\n");
    printf("- Use 'netstat -tlnp' or 'ss -tlnp' to confirm\n");
    printf("- Connect with: nc localhost 8888\n");
    printf("- The service requires a specific password\n");
    printf("- Password hint: Look in the database files\n\n");
    setuid(0);
    setgid(0);
    system("/bin/bash");
}

void normal_function(char *input) {
    char buffer[32];
    printf("Security Scanner v2.1\n");
    printf("Scanning input: ");
    strcpy(buffer, input);  // Buffer overflow vulnerability
    printf("%s\n", buffer);
    printf("Scan complete. No threats detected.\n");
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <input_to_scan>\n", argv[0]);
        printf("Example: %s 'some_file_or_text'\n", argv[0]);
        return 1;
    }
    
    // Easter egg for reverse engineering
    if (strcmp(argv[1], "show_secrets") == 0) {
        secret_backdoor();
        return 0;
    }
    
    normal_function(argv[1]);
    return 0;
}
EOF

# Compile the binary
gcc -o $CHALLENGE_DIR/reverse_engineering/security_scanner /tmp/security_scanner.c -fno-stack-protector -z execstack -no-pie
chmod +s $CHALLENGE_DIR/reverse_engineering/security_scanner

# Add some analysis hints
echo "This binary performs security scanning. Try different inputs to discover hidden functionality." > $CHALLENGE_DIR/reverse_engineering/README.txt
echo "Hint: Try using 'strings', 'objdump -d', or 'gdb' to analyze the binary." >> $CHALLENGE_DIR/reverse_engineering/README.txt

# ============== LAYER 4: NETWORK SERVICE ==============
echo "[4/5] Setting up Network Analysis layer..."

# Create a Python service that runs on localhost:8888
cat > $CHALLENGE_DIR/network_analysis/secret_service.py << 'EOF'
#!/usr/bin/env python3
import socket
import threading
import sqlite3
import base64

def handle_client(client_socket, addr):
    print(f"Connection from {addr}")
    
    try:
        client_socket.send(b"=== QUANTUM SECURE VAULT ACCESS ===\n")
        client_socket.send(b"Enter access code: ")
        
        password = client_socket.recv(1024).decode().strip()
        
        if password == "admin_secure_2025":
            client_socket.send(b"Access GRANTED!\n")
            client_socket.send(b"Final Challenge Information:\n")
            client_socket.send(b"The ultimate flag is encrypted with AES-256-CBC\n")
            client_socket.send(b"Key: master_key_quantum_2025\n")
            client_socket.send(b"Encrypted flag location: /root/.vault/final_flag.enc\n")
            client_socket.send(b"You need root access to read it!\n")
            client_socket.send(b"Hint: Use the security_scanner binary for privilege escalation\n")
        else:
            client_socket.send(b"Access DENIED!\n")
            client_socket.send(b"Incorrect access code.\n")
            
    except Exception as e:
        print(f"Error handling client: {e}")
    finally:
        client_socket.close()

def start_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('127.0.0.1', 8888))
    server.listen(5)
    print("Secret service listening on localhost:8888")
    
    while True:
        client_socket, addr = server.accept()
        client_thread = threading.Thread(target=handle_client, args=(client_socket, addr))
        client_thread.daemon = True
        client_thread.start()

if __name__ == "__main__":
    start_server()
EOF
chmod +x $CHALLENGE_DIR/network_analysis/secret_service.py

# Start the service in background
nohup python3 $CHALLENGE_DIR/network_analysis/secret_service.py > /dev/null 2>&1 &

# ============== LAYER 5: DATABASE WITH PASSWORD ==============
echo "[5/5] Setting up Database layer..."

# Create SQLite database with the password
cat > /tmp/create_vault_db.sql << 'EOF'
CREATE TABLE access_codes (
    id INTEGER PRIMARY KEY,
    service_name TEXT,
    access_code TEXT,
    description TEXT
);

CREATE TABLE vault_info (
    id INTEGER PRIMARY KEY,
    key_name TEXT,
    encrypted_value TEXT
);

INSERT INTO access_codes VALUES (1, 'quantum_vault', 'admin_secure_2025', 'Main vault access password');
INSERT INTO access_codes VALUES (2, 'backup_system', 'backup_2024', 'Backup system password');

INSERT INTO vault_info VALUES (1, 'master_encryption_key', 'bWFzdGVyX2tleV9xdWFudHVtXzIwMjU=');
INSERT INTO vault_info VALUES (2, 'admin_notes', 'VGhlIGZpbmFsIGZsYWcgaXMgaGlkZGVuIGluIC9yb290Ly52YXVsdC8=');
EOF

sqlite3 $CHALLENGE_DIR/database/vault_database.db < /tmp/create_vault_db.sql

# ============== FINAL FLAG CREATION ==============
mkdir -p /root/.vault
echo -n "$FINAL_FLAG" | openssl enc -aes-256-cbc -k "master_key_quantum_2025" -base64 > /root/.vault/final_flag.enc

# ============== WELCOME MESSAGE AND HINTS ==============
cat > $USER_HOME/ELITE_CHALLENGE.txt << 'EOF'
🎯 WELCOME TO THE ELITE CTF CHALLENGE 🎯
======================================

You have proven yourself worthy in the first challenge.
Now face the ultimate test of your hacking skills!

This expert-level challenge (800 points) has 5 interconnected layers:

1. 🔍 STEGANOGRAPHY
   - Hidden messages in image files
   - Hex encoding and special formats
   - Location: /opt/challenge/steganography/

2. 🔐 CRYPTOGRAPHY  
   - RSA key reconstruction puzzle
   - Multi-fragment private keys
   - Location: /opt/challenge/cryptography/

3. ⚙️  REVERSE ENGINEERING
   - Binary analysis and exploitation
   - Hidden backdoors and buffer overflows
   - Location: /opt/challenge/reverse_engineering/

4. 🌐 NETWORK ANALYSIS
   - Hidden services on localhost
   - Port scanning and service enumeration
   - Location: /opt/challenge/network_analysis/

5. 🏛️  DATABASE FORENSICS
   - SQLite database with secrets
   - Base64 encoded information
   - Location: /opt/challenge/database/

🎯 FINAL OBJECTIVE:
Obtain root access and decrypt the ultimate flag in /root/.vault/

🛠️  TOOLS AVAILABLE:
- Python3, OpenSSL, GDB, SQLite3
- Network tools: netstat, ss, nc
- Analysis tools: strings, objdump, hexedit, xxd

💡 START HERE:
Begin with the steganography challenge to get your first clue!

Good luck, elite hacker. Only the most skilled will prevail.
EOF

# Create some decoy files
for i in {1..30}; do
    echo "FAKE{n0t_th3_r34l_fl4g_$i}" > "$USER_HOME/documents/decoy_$i.txt"
done

# Set permissions
chown -R eliteuser:eliteuser $USER_HOME
chown -R eliteuser:eliteuser $CHALLENGE_DIR
chmod -R 755 $CHALLENGE_DIR
chmod 700 $CHALLENGE_DIR/secure_vault
chmod +s $CHALLENGE_DIR/reverse_engineering/security_scanner

# Clean up temp files
rm -f /tmp/master_*.pem /tmp/crypto_clue.txt /tmp/security_scanner.c /tmp/create_vault_db.sql

echo "=== EXPERT CTF Challenge setup completed! ==="
echo "Difficulty: 800 points"
echo "Estimated solve time: 3-6 hours for experts"
echo "Final flag: $FINAL_FLAG"
