#!/bin/sh

# run ssh with the admin public key
/usr/bin/ssh -i "${ADMIN_SSHKEY}" "$@"
