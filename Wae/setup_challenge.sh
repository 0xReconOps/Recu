#!/bin/bash

USER_HOME="/home/w4rn1ng"
FLAG="ESGISCTF{1nter@ct1ve_sh3ll_ch@ll3ng3}"

DIRECTORIES=(
    "documents" "photos" "music" "videos" "downloads" "temp" "backup" "archive"
    "projects" "scripts" "logs" "config" "data" "images" "text_files" "old_stuff"
    "personal" "work" "study" "resources" "tools" "games" "software" "media" "misc"
)

FAKE_FLAGS=(
    "FAKE{n0t_th3_r34l_fl4g}"
    "DECOY{try_h4rd3r}"
    "WRONG{k33p_l00k1ng}"
    "NOPE{n1c3_try_th0ugh}"
    "FALSE{cl0s3_but_n0_c1g4r}"
    "DUMMY{y0u_4r3_g3tt1ng_w4rm3r}"
    "BAIT{4lm0st_th3r3}"
    "TRAP{d0nt_g1v3_up}"
    "MOCK{1_b3l13v3_1n_y0u}"
    "HOAX{th1nk_0uts1d3_th3_b0x}"
)

HINTS=(
    "Cherche quelque chose qui n’est pas ce qu’il semble..."
    "Parfois les fichiers sont cachés derrière de fausses extensions"
    "Le vrai trésor est souvent compressé et caché"
    "TG9vayBmb3IgaGlkZGVuIGRpcmVjdG9yaWVzIHdpdGggZG90cw=="
    "Q29tcHJlc3NlZCBmaWxlcyBjYW4gaGF2ZSBhbnkgZXh0ZW5zaW9u"
    "Ce que tu vois n’est pas toujours ce que tu obtiens"
    "VGhlICdmaWxlJyBjb21tYW5kIGNhbiByZXZlYWwgdHJ1dGhz"
    "Les extensions peuvent être trompeuses"
    "Les choses cachées commencent par un point"
    "Les vrais flags ne sont jamais en vue directe"
)

for i in "${!DIRECTORIES[@]}"; do
    DIR="${USER_HOME}/${DIRECTORIES[$i]}"
    mkdir -p "$DIR"

    # Ajouter 3-5 fichiers par répertoire
    NUM_FILES=$((RANDOM % 3 + 3))

    for j in $(seq 1 $NUM_FILES); do
        FILENAME="file_${j}.txt"

        # 30% chance pour un faux flag, 40% pour un indice, 30% pour un fichier aléatoire
        RAND=$((RANDOM % 100))

        if [ $RAND -lt 30 ]; then
            FAKE_FLAG=${FAKE_FLAGS[$((RANDOM % ${#FAKE_FLAGS[@]}))]}
            echo "$FAKE_FLAG" > "$DIR/$FILENAME"
        elif [ $RAND -lt 70 ]; then
            HINT=${HINTS[$((RANDOM % ${#HINTS[@]}))]}
            echo "Indice : $HINT" > "$DIR/$FILENAME"
        else
            echo "Ceci est juste un fichier normal avec du contenu aléatoire. Rien à voir ici." > "$DIR/$FILENAME"
            echo "Données aléatoires : $(head -c 20 /dev/urandom | base64)" >> "$DIR/$FILENAME"
        fi
    done

    echo "Données de configuration..." > "$DIR/config.conf"
    echo "Entrée de log : utilisateur a accédé au système" > "$DIR/system.log"
    echo "#!/bin/bash\necho 'Ce script ne fait rien'" > "$DIR/dummy.sh"
done

HIDDEN_DIR="${USER_HOME}/.secret_vault"
mkdir -p "$HIDDEN_DIR"

echo "DECOY{h1dd3n_but_st1ll_f4k3}" > "$HIDDEN_DIR/secret.txt"
echo "Configuration des services cachés" > "$HIDDEN_DIR/config.ini"

echo "$FLAG" | gzip > "$HIDDEN_DIR/vacation_photo.jpg"

echo "Indice : RXZlcnl0aGluZyBoaWRkZW4gc3RhcnRzIHdpdGggYSBkb3Q=" > "${USER_HOME}/documents/readme.txt"

echo "Indice : VGhlICdmaWxlJyBjb21tYW5kIGNhbiByZXZlYWwgdGhlIHRydWUgbmF0dXJlIG9mIGFueSBmaWxl" > "${USER_HOME}/tools/analysis.txt"

echo "Quand les fichiers sont compressés avec gzip, ils peuvent être décompressés avec le même outil" > "${USER_HOME}/backup/compression_info.txt"

echo "FAKE{1m4g3_fl4g_n0t_r34l}" > "${USER_HOME}/photos/flag.png"
echo "DECOY{t3xt_fl4g_4ls0_f4k3}" > "${USER_HOME}/documents/important.doc"
echo "NOPE{4rch1v3_fl4g_wr0ng}" > "${USER_HOME}/archive/backup.zip"

chmod -R 755 "$USER_HOME"
chown -R w4rn1ng:w4rn1ng "$USER_HOME"

echo "L’utilisateur peut se connecter en SSH avec : w4rn1ng:buff3r0v3rf10w15Fun"
