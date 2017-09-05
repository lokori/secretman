#!/bin/bash

set -eu

VAULT=~/.secretman
# create directory for the secrets if not exists
mkdir -p $VAULT

# Your key id for the Yubikey encryption key
RECIPIENT=D2E72CF23AD1899D

if [ $# -gt 0 ]; then
    KEY=$1
    echo "Securing data with vault key $1."
    if [ -e $VAULT/$KEY ]; then
      # If we are reading data from standard input, read will misbehave unless explicitly reading from tty
      read -p "Key exists, overwrite?  [y/N] " response < /dev/tty
      case "$response" in
	  [yY][eE][sS]|[yY])
	      echo "overwriting"
              ;;
	  *)
	      echo "exiting"
	      exit 1
              ;;
      esac
    else
      echo "new key"
    fi
fi

if [ $# -eq 2 ]; then
    echo "Data from command line"
    VALUE=$2

    echo "$VALUE" | gpg --encrypt --armor --recipient $RECIPIENT > "$VAULT/$KEY"
elif [ $# -eq 1 ]; then
    echo "Data from standard input."
    gpg --encrypt --armor --recipient $RECIPIENT < /dev/stdin  > "$VAULT/$KEY"
else
    echo "Invalid arguments."
    echo "Usage: poke.sh key [value]"
    exit 1
fi

# Override umask
chmod go-rwx "$VAULT/$KEY"
