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

# check if there are any untracked files
UNSTAGED=`git ls-files --exclude-standard --others`
for file in $UNSTAGED;
do
  # add the file
  git add $file
done

# check if the repository is dirty
git diff-index --quiet HEAD
if [ $? -ne 0 ]; then
  # commit all changes
  git commit -a -m "Puppet gitolite module."

  # push the branch
  git push origin master
fi
