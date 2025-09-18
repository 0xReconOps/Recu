#!/bin/bash

# Advanced CTF Challenge Setup Script
# This creates a multi-layered expert-level challenge

USER_HOME="/home/eliteuser"
CHALLENGE_DIR="/opt/challenge"
FINAL_FLAG="ESGISCTF{m4st3r_0f_cyb3r_w4rf4r3_4nd_cr7pt0_m4g1c}"

echo "Setting up EXPERT level CTF challenge..."

# Create challenge directories
mkdir -p $CHALLENGE_DIR/{crypto,steganography,reverse_engineering,web_vuln,secure_vault,network}
mkdir -p $USER_HOME/{documents,projects,temp}

# ============== LAYER 1: STEGANOGRAPHY ==============
# Create image with hidden message using steganography
convert -size 800x600 xc:lightblue $CHALLENGE_DIR/steganography/beach_vacation.jpg 2>/dev/null || {
    # Fallback: create a simple text file as image placeholder
    echo "This would be a JPEG image in a real environment" > $CHALLENGE_DIR/steganography/beach_vacation.jpg
}

# Create steganography message
echo "Next clue: The crypto module holds ancient secrets. Look for the RSA keys that unlock the quantum vault." > /tmp/steg_message.txt

# Hide message in image (steghide simulation)
echo "U3RlZ2hpZGUgbWVzc2FnZTogTmV4dCBjbHVlOiBUaGUgY3J5cHRvIG1vZHVsZSBob2xkcyBhbmNpZW50IHNlY3JldHMuIExvb2sgZm9yIHRoZSBSU0Ega2V5cyB0aGF0IHVubG9jayB0aGUgcXVhbnR1bSB2YXVsdC4=" > $CHALLENGE_DIR/steganography/.hidden_data.b64

# ============== LAYER 2: CRYPTOGRAPHY ==============
# Generate RSA key pair
openssl genrsa -out /tmp/private.pem 2048
openssl rsa -in /tmp/private.pem -pubout -out /tmp/public.pem

# Create encrypted message with next clue
echo "The web service on port 3000 has a SQL injection vulnerability. The admin panel password is hidden in the database schema. Look for table 'secret_keys' with column 'encrypted_data'." > /tmp/crypto_clue.txt
openssl rsautl -encrypt -pubin -inkey /tmp/public.pem -in /tmp/crypto_clue.txt -out $CHALLENGE_DIR/crypto/encrypted_message.bin

# Split RSA private key into pieces (puzzle)
split -b 512 /tmp/private.pem $CHALLENGE_DIR/crypto/key_fragment_
mv $CHALLENGE_DIR/crypto/key_fragment_aa $CHALLENGE_DIR/crypto/key_part1.pem
mv $CHALLENGE_DIR/crypto/key_fragment_ab $CHALLENGE_DIR/crypto/key_part2.pem
mv $CHALLENGE_DIR/crypto/key_fragment_ac $CHALLENGE_DIR/crypto/key_part3.pem
mv $CHALLENGE_DIR/crypto/key_fragment_ad $CHALLENGE_DIR/crypto/key_part4.pem

# Create hint for key reconstruction
echo "To rebuild what was broken apart, concatenate the fragments in alphabetical order" > $CHALLENGE_DIR/crypto/assembly_hint.txt

# ============== LAYER 3: WEB VULNERABILITY ==============
# Create SQLite database for web service
cat > /tmp/create_db.sql << 'EOF'
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT,
    password TEXT,
    role TEXT
);

CREATE TABLE secret_keys (
    id INTEGER PRIMARY KEY,
    key_name TEXT,
    encrypted_data TEXT
);

INSERT INTO users VALUES (1, 'admin', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 'administrator');
INSERT INTO users VALUES (2, 'guest', 'guest123', 'user');

INSERT INTO secret_keys VALUES (1, 'vault_access', 'YWRtaW5fcGFzc3dvcmQ6IHN1cGVyX3NlY3VyZV9wYXNzd29yZF8yMDI1IQ==');
INSERT INTO secret_keys VALUES (2, 'next_stage', 'VGhlIHByaXZlc2MgYmluYXJ5IGluIC9vcHQvY2hhbGxlbmdlL3NlY3VyZV92YXVsdC8gaGFzIGEgYnVmZmVyIG92ZXJmbG93LiBFeHBsb2l0IGl0IHRvIGdldCByb290IGFjY2Vzcy4=');
EOF

sqlite3 $CHALLENGE_DIR/web_vuln/challenge.db < /tmp/create_db.sql

# ============== LAYER 4: REVERSE ENGINEERING ==============
# Create C program with buffer overflow vulnerability
cat > /tmp/privesc.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void secret_function() {
    printf("Congratulations! You found the buffer overflow!\n");
    printf("Here's your privilege escalation payload:\n");
    printf("Final flag location: /root/.ultimate_secret/quantum_flag.enc\n");
    printf("Decryption key: use_the_master_key_from_web_database\n");
    setuid(0);
    setgid(0);
    system("/bin/bash");
}

void vulnerable_function(char *input) {
    char buffer[64];
    strcpy(buffer, input);  // Vulnerable to buffer overflow
    printf("Input processed: %s\n", buffer);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <input>\n", argv[0]);
        return 1;
    }
    
    printf("Secure Vault Access System v2.1\n");
    printf("Processing input...\n");
    
    vulnerable_function(argv[1]);
    
    printf("Access denied. Nice try though!\n");
    return 0;
}
EOF

# Compile the vulnerable binary
gcc -o $CHALLENGE_DIR/secure_vault/privesc_binary /tmp/privesc.c -fno-stack-protector -z execstack
chmod +s $CHALLENGE_DIR/secure_vault/privesc_binary

# ============== LAYER 5: FINAL ENCRYPTED FLAG ==============
# Create final flag encrypted with AES
mkdir -p /root/.ultimate_secret

# Create master key (from web database hint)
MASTER_KEY="super_secure_password_2025!"
echo -n "$FINAL_FLAG" | openssl enc -aes-256-cbc -k "$MASTER_KEY" -base64 > /root/.ultimate_secret/quantum_flag.enc

# ============== DECOY FILES AND RED HERRINGS ==============
# Create many false flags and red herrings
FAKE_FLAGS=(
    "FAKE{y0u_4r3_g3tt1ng_cl0s3r}"
    "DECOY{n0t_th3_f1n4l_fl4g}"
    "WRONG{k33p_d1gg1ng_d33p3r}"
    "FALSE{4lm0st_th3r3_ch4mp}"
    "BAIT{7h1s_15_ju5t_4_t34s3r}"
)

for i in {1..50}; do
    FAKE_FLAG=${FAKE_FLAGS[$((RANDOM % ${#FAKE_FLAGS[@]}))]}
    echo "$FAKE_FLAG" > "$CHALLENGE_DIR/crypto/fake_flag_$i.txt"
    echo "$FAKE_FLAG" > "$USER_HOME/documents/document_$i.txt"
done

# ============== HINTS AND BREADCRUMBS ==============
# Initial hint for the user
cat > $USER_HOME/WELCOME.txt << 'EOF'
Welcome to the ELITE challenge, cyber warrior!

You've proven yourself in the basics. Now face the ultimate test.
This challenge has 5 layers of security:

1. 🖼️  Steganography - Images hide more than meets the eye
2. 🔐 Cryptography - Ancient RSA secrets await reconstruction  
3. 🌐 Web Exploitation - SQL injections open forbidden doors
4. ⚙️  Reverse Engineering - Buffer overflows grant divine power
5. 👑 Final Encryption - AES guards the ultimate prize

Your password from the previous challenge is now your username.
The path to glory is treacherous. Only true masters will prevail.

First step: Examine the image in /opt/challenge/steganography/
The 'strings' and 'xxd' commands might reveal hidden secrets...

Good luck, elite hacker.
EOF

# Create additional hints
echo "Hint: Web service might be running on port 3000. Check if it's active." > $USER_HOME/network_hint.txt
echo "Tip: SQL injection payload example: ' OR 1=1 --" > $USER_HOME/web_hint.txt
echo "Remember: Buffer overflows need the right amount of padding + return address" > $USER_HOME/reverse_hint.txt

# Create a script to check steganography
cat > $CHALLENGE_DIR/steganography/extract_hidden.sh << 'EOF'
#!/bin/bash
echo "Extracting hidden data from image..."
if [ -f ".hidden_data.b64" ]; then
    echo "Found base64 encoded data:"
    cat .hidden_data.b64 | base64 -d
else
    echo "No hidden data found. Try other methods..."
fi
EOF
chmod +x $CHALLENGE_DIR/steganography/extract_hidden.sh

# Set proper permissions
chown -R eliteuser:eliteuser $USER_HOME
chown -R eliteuser:eliteuser $CHALLENGE_DIR
chmod 700 $CHALLENGE_DIR/secure_vault
chmod +s $CHALLENGE_DIR/secure_vault/privesc_binary

# Clean up temporary files
rm -f /tmp/private.pem /tmp/public.pem /tmp/crypto_clue.txt /tmp/steg_message.txt /tmp/create_db.sql /tmp/privesc.c

echo "EXPERT CTF Challenge setup completed!"
echo "====================="
echo "Challenge Statistics:"
echo "- 5 security layers"
echo "- 50+ decoy files"
echo "- Multiple exploitation techniques required"
echo "- Estimated difficulty: 800 points"
echo "- Estimated solve time: 2-4 hours for experts"
echo "====================="
