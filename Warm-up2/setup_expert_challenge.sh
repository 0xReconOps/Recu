#!/bin/bash

# Script d’installation du Challenge CTF Expert (800 Points)

USER_HOME="/home/w4rn1ng"
CHALLENGE_DIR="/opt/challenge"
FINAL_FLAG="ESGISCTF{3l1t3_h4ck3r_m4st3r_0f_4ll_d0m41ns_2025}"

echo "=== Mise en place du Challenge CTF Expert (800 points) ==="

# Création des répertoires du challenge
mkdir -p $CHALLENGE_DIR/{steganography,cryptography,reverse_engineering,network_analysis,secure_vault,database}
mkdir -p $USER_HOME/{documents,projects,temp,analysis}

# ============== COUCHE 1 : STÉGANOGRAPHIE ==============
echo "[1/5] Mise en place de la couche Stéganographie..."

# Création d’une fausse image avec des données cachées
echo "RVNHSVNDVEZ7cHduX3N0YXJ0X2Vhc3lfMjAyNX0=" | base64 -d > $CHALLENGE_DIR/steganography/vacation.png

# Création d’un message caché en hexadécimal
echo "46454c494349544154494f4e" > $CHALLENGE_DIR/steganography/.hex_data

# Script de décodage hexadécimal
cat > $CHALLENGE_DIR/steganography/decode_hex.sh << 'EOF'
#!/bin/bash
echo "=== Décodeur de données hexadécimales ==="
if [ -f ".hex_data" ]; then
    echo "Données hexadécimales trouvées. Décodage..."
    cat .hex_data | xxd -r -p
    echo ""
else
    echo "Aucune donnée hexadécimale trouvée."
fi
EOF
chmod +x $CHALLENGE_DIR/steganography/decode_hex.sh

# ============== COUCHE 2 : CRYPTOGRAPHIE ==============
echo "[2/5] Mise en place de la couche Cryptographie..."

# Génération de la paire de clés RSA
openssl genrsa -out /tmp/master_private.pem 2048
openssl rsa -in /tmp/master_private.pem -pubout -out /tmp/master_public.pem

# Chiffrement de l’indice suivant avec RSA
echo "ESGISCTF{buff3r_0v3rfl0w_succ3ss}" > /tmp/crypto_clue.txt
openssl rsautl -encrypt -pubin -inkey /tmp/master_public.pem -in /tmp/crypto_clue.txt -out $CHALLENGE_DIR/cryptography/encrypted_message.bin

# Cacher des fragments de la clé privée
split -b 400 /tmp/master_private.pem $CHALLENGE_DIR/cryptography/fragment_
mv $CHALLENGE_DIR/cryptography/fragment_aa $CHALLENGE_DIR/cryptography/key_alpha.pem
mv $CHALLENGE_DIR/cryptography/fragment_ab $CHALLENGE_DIR/cryptography/key_beta.pem
mv $CHALLENGE_DIR/cryptography/fragment_ac $CHALLENGE_DIR/cryptography/key_gamma.pem
mv $CHALLENGE_DIR/cryptography/fragment_ad $CHALLENGE_DIR/cryptography/key_delta.pem
mv $CHALLENGE_DIR/cryptography/fragment_ae $CHALLENGE_DIR/cryptography/key_epsilon.pem

# Script de reconstruction de la clé
cat > $CHALLENGE_DIR/cryptography/reconstruct_key.py << 'EOF'
#!/usr/bin/env python3
import os
import subprocess

print("=== Outil de reconstruction de clé RSA ===")
print("Recherche des fragments de clé...")

fragments = []
for file in sorted(os.listdir('.')):
    if file.startswith('key_') and file.endswith('.pem'):
        fragments.append(file)
        print(f"Fragment trouvé : {file}")

if len(fragments) >= 5:
    print("\nReconstruction de la clé privée...")
    with open('reconstructed_private.pem', 'w') as output:
        for fragment in fragments:
            with open(fragment, 'r') as f:
                output.write(f.read())
    
    print("Clé reconstruite ! Fichier : reconstructed_private.pem")
    print("Vous pouvez maintenant déchiffrer le message avec :")
    print("openssl rsautl -decrypt -inkey reconstructed_private.pem -in encrypted_message.bin")
else:
    print(f"Seulement {len(fragments)} fragments trouvés. Tous les morceaux sont nécessaires.")
EOF
chmod +x $CHALLENGE_DIR/cryptography/reconstruct_key.py

# ============== COUCHE 3 : REVERSE ENGINEERING ==============
echo "[3/5] Mise en place de la couche Reverse Engineering..."

# Création d’un programme C vulnérable avec fonctionnalité cachée
cat > /tmp/security_scanner.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void secret_backdoor() {
    printf("BACKDOOR ACTIVÉ !\n");
    printf("Indice d’analyse réseau :\n");
    printf("- Un service Python fonctionne sur localhost:8888\n");
    printf("- Utilisez 'netstat -tlnp' ou 'ss -tlnp' pour confirmer\n");
    printf("- Connectez-vous avec : nc localhost 8888\n");
    printf("- Le service requiert un mot de passe spécifique\n");
    printf("- Indice du mot de passe : consultez les fichiers de base de données\n\n");
    setuid(0);
    setgid(0);
    system("/bin/bash");
}

void normal_function(char *input) {
    char buffer[32];
    printf("Security Scanner v2.1\n");
    printf("Analyse de l’entrée : ");
    strcpy(buffer, input);  // Vulnérabilité de dépassement de tampon
    printf("%s\n", buffer);
    printf("Analyse terminée. Aucune menace détectée.\n");
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Utilisation : %s <entrée_à_analyser>\n", argv[0]);
        printf("Exemple : %s 'fichier_ou_texte'\n", argv[0]);
        return 1;
    }
    
    // Œuf de Pâques pour reverse engineering
    if (strcmp(argv[1], "show_secrets") == 0) {
        secret_backdoor();
        return 0;
    }
    
    normal_function(argv[1]);
    return 0;
}
EOF

# Compilation du binaire
gcc -o $CHALLENGE_DIR/reverse_engineering/security_scanner /tmp/security_scanner.c -fno-stack-protector -z execstack -no-pie
chmod +s $CHALLENGE_DIR/reverse_engineering/security_scanner

# Ajout d’indices d’analyse
echo "45534749534354467b70776e5f73746172745f656173795f323032357d" > $CHALLENGE_DIR/reverse_engineering/README.txt
echo "46454c494349544154494f4e" >> $CHA
