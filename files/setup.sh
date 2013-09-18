#!/bin/sh

# environment
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

# settings
export BASEDIR=$1
export ADMIN_USERNAME=$2

export GIT_SSH="${BASEDIR}/gitssh.sh"
export ADMIN_SSHKEY="${BASEDIR}/${ADMIN_USERNAME}.key"

# setup gitolite
cd /var/lib/gitolite3
cp ${BASEDIR}/${ADMIN_USERNAME}.pub ${ADMIN_USERNAME}.pub
sudo -u gitolite3 gitolite setup -pk ${ADMIN_USERNAME}.pub
rm ${ADMIN_USERNAME}.pub

# check out the admin repository
cd ${BASEDIR}
rm -rf gitolite-admin
git clone gitolite3@localhost:gitolite-admin
