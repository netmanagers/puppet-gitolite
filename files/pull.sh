#!/bin/sh

# environment
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

# settings
export BASEDIR=$1
export ADMIN_USERNAME=$2

export GIT_SSH="${BASEDIR}/gitssh.sh"
export ADMIN_SSHKEY="${BASEDIR}/${ADMIN_USERNAME}.key"

# switch to the admin repository
cd ${BASEDIR}/gitolite-admin

# discard uncommited changes
git reset --hard

# pull the repository
git pull origin master
