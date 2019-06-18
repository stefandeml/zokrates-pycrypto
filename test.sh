#!/usr/bin/env sh
# Requires seth to be installed, see: https://dapp.tools/
set -ex

OUT=out/

PYCRYPTO="python3 cli.py" 

BUYER1=$(printf "%040d" 1)
BUYER1_KEY=$($PYCRYPTO keygen)
BUYER1_PUB=$(echo $BUYER1_KEY | cut -d' ' -f2)
BUYER1_PRIV=$(echo $BUYER1_KEY | cut -d' ' -f1)
BUYER1_RATING="64" # 100 in decimal
BUYER1_LEAF="$BUYER1$BUYER1_PUB$BUYER1_RATING"
BUYER1_LEAF_PADDED=$(printf "%s%0$(expr 128 - ${#BUYER1_LEAF})d" $BUYER1_LEAF 0)
BUYER1_HASH=$(echo -n $BUYER1_LEAF_PADDED | xxd -r -p | sha256sum | cut -d' ' -f1)

BUYER2=$(printf "%040d" 2) 
BUYER2_KEY=$($PYCRYPTO keygen)
BUYER2_PUB=$(echo $BUYER2_KEY | cut -d' ' -f2)
BUYER2_PRIV=$(echo $BUYER2_KEY | cut -d' ' -f1)
BUYER2_RATING="0a" # 10 in decimal
BUYER3_LEAF="$BUYER2$BUYER2_PUB$BUYER2_RATING"
BUYER2_LEAF_PADDED=$(printf "%s%0$(expr 128 - ${#BUYER2_LEAF})d" $BUYER2_LEAF 0)
BUYER2_HASH=$(echo -n $BUYER2_LEAF_PADDED | xxd -r -p | sha256sum | cut -d' ' -f1)

BUYER3=$(printf "%040d" 3) 
BUYER3_KEY=$($PYCRYPTO keygen)
BUYER3_PUB=$(echo $BUYER3_KEY | cut -d' ' -f2)
BUYER3_PRIV=$(echo $BUYER3_KEY | cut -d' ' -f1)
BUYER3_RATING="0a" # 10 in decimal
BUYER3_LEAF="$BUYER3$BUYER3_PUB$BUYER3_RATING"
BUYER3_LEAF_PADDED=$(printf "%s%0$(expr 128 - ${#BUYER3_LEAF})d" $BUYER3_LEAF 0)
BUYER3_HASH=$(echo -n $BUYER3_LEAF_PADDED | xxd -r -p | sha256sum | cut -d' ' -f1)

BUYER4=$(printf "%040d" 4) 
BUYER4_KEY=$($PYCRYPTO keygen)
BUYER4_PUB=$(echo $BUYER4_KEY | cut -d' ' -f2)
BUYER4_PRIV=$(echo $BUYER4_KEY | cut -d' ' -f1)
BUYER4_RATING="60" # 96 in decimal
BUYER4_LEAF="$BUYER4$BUYER4_PUB$BUYER4_RATING"
BUYER4_LEAF_PADDED=$(printf "%s%0$(expr 128 - ${#BUYER4_LEAF})d" $BUYER4_LEAF 0)
BUYER4_HASH=$(echo -n $BUYER4_LEAF_PADDED | xxd -r -p | sha256sum | cut -d' ' -f1)

BUYER_NODE1=$($PYCRYPTO hash $BUYER1_HASH$BUYER2_HASH)
BUYER_NODE2=$($PYCRYPTO hash $BUYER3_HASH$BUYER4_HASH)
BUYER_ROOT=$($PYCRYPTO hash $BUYER_NODE1$BUYER_NODE2)

NFT_AMOUNT=$(printf "%064x" 800) # 800 in hex


PADDING=0000000000000000000000000000000000000000000000000000000000000000
DOC_INVOICE_AMOUNT=$(printf "%064x" 1000) # 1000 in hex
DOC_INVOICE_AMOUNT_SALT=$(dd if=/dev/urandom bs=32 count=1 | xxd -ps -c 200 | tr -d '\n')
DOC_INVOICE_AMOUNT_PROPERTY=00000000000000000000000000000000000000000000000000000068656c6c6f
DOC_INVOICE_AMOUNT_LEAF="$DOC_INVOICE_AMOUNT_PROPERTY$DOC_INVOICE_AMOUNT$DOC_INVOICE_AMOUNT_SALT$PADDING"
DOC_INVOICE_AMOUNT_HASH=$(echo -n "$DOC_INVOICE_AMOUNT_LEAF" |  xxd -r -p | sha256sum | cut -d' ' -f1)

DOC_BUYER_SALT=$(dd if=/dev/urandom bs=32 count=1 | xxd -ps -c 200 | tr -d '\n')
DOC_BUYER_PROPERTY=00000000000000000000000000000000000000000000000000000068656c6c6f
DOC_BUYER_LEAF="$DOC_BUYER_PROPERTY$BUYER1$DOC_BUYER_SALT$PADDING"
DOC_BUYER_LEAF=$(printf "%s%0$(expr 256 - ${#DOC_BUYER_LEAF})d" $DOC_BUYER_LEAF 0)
DOC_BUYER_HASH=$(echo -n "$DOC_BUYER_LEAF" |  xxd -r -p | sha256sum | cut -d' ' -f1)

DOC_EXTRA_LEAF2=$(dd if=/dev/urandom bs=32 count=1 | xxd -ps -c 200 | tr -d '\n')
DOC_EXTRA_LEAF3=$(dd if=/dev/urandom bs=32 count=1 | xxd -ps -c 200 | tr -d '\n')
DOC_EXTRA_LEAF4=$(dd if=/dev/urandom bs=32 count=1 | xxd -ps -c 200 | tr -d '\n')
DOC_EXTRA_LEAF5=$(dd if=/dev/urandom bs=32 count=1 | xxd -ps -c 200 | tr -d '\n')
DOC_EXTRA_LEAF6=$(dd if=/dev/urandom bs=32 count=1 | xxd -ps -c 200 | tr -d '\n')
DOC_EXTRA_LEAF7=$(dd if=/dev/urandom bs=32 count=1 | xxd -ps -c 200 | tr -d '\n')

DOC_NODE1=$($PYCRYPTO hash $DOC_INVOICE_AMOUNT_HASH$DOC_BUYER_HASH)
DOC_NODE2=$($PYCRYPTO hash $DOC_EXTRA_LEAF2$DOC_EXTRA_LEAF3)
DOC_NODE3=$($PYCRYPTO hash $DOC_EXTRA_LEAF4$DOC_EXTRA_LEAF5)
DOC_NODE4=$($PYCRYPTO hash $DOC_EXTRA_LEAF6$DOC_EXTRA_LEAF7)

DOC_NODE5=$($PYCRYPTO hash $DOC_NODE1$DOC_NODE2)
DOC_NODE6=$($PYCRYPTO hash $DOC_NODE3$DOC_NODE4)

DOC_ROOT=$($PYCRYPTO hash $DOC_NODE5$DOC_NODE6)

BUYER1_SIG=$($PYCRYPTO sig-gen $BUYER1_PRIV $DOC_ROOT$PADDING)
BUYER1_SIG=$(echo $BUYER1_SIG | cut -d' ' -f1)$(echo $BUYER1_SIG | cut -d' ' -f2)

cat > "$OUT/proof_data.json" << EOF
{ 
    "public": {
        "nft_amount": "$NFT_AMOUNT",
        "credit_rating_roothash": "$BUYER_ROOT",
        "rating": "$BUYER1_RATING",
        "document_roothash": "$DOC_ROOT"
    },
    "private": {
    "buyer_pubkey" : "$BUYER1_PUB",
    "buyer_signature": "$BUYER1_SIG",
        "buyer_rating_proof": { 
            "hashes": ["$BUYER2_HASH", "$BUYER_NODE2"],
            "right": [false, false],
            "value": "$BUYER1_LEAF"
        },
        "document_invoice_amount_proof": {
            "hashes": ["$DOC_BUYER_HASH", "$DOC_NODE2", "$DOC_NODE6"],
            "right": [false, false, false],
            "value": "$DOC_INVOICE_AMOUNT",
            "salt": "$DOC_INVOICE_AMOUNT_SALT",
            "property": "$DOC_INVOICE_AMOUNT_PROPERTY"
        },
        "document_invoice_buyer_proof": {
            "hashes": ["$DOC_INVOICE_AMOUNT_HASH", "$DOC_NODE2", "$DOC_NODE6"],
            "right": [true, false, false],
            "value": "$BUYER1",
            "salt": "$DOC_BUYER_SALT",
            "property": "$DOC_BUYER_PROPERTY"
        }
    }
}
EOF