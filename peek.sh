#!/bin/bash

set -eu
VAULT=~/.secretman

if [ $# -eq 1 ]; then
    echo "Decrypting secret data with vault key $1"
else
    echo "Invalid arguments."
    echo "Usage: peek.sh key"
    exit 1
fi

KEY=$1


cat "$VAULT/$KEY" | gpg --decrypt

