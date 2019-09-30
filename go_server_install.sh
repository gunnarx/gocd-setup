#!/bin/sh

# All-in-one wrapper can be downloaded and piped to a shell directly:
# curl https://raw.githubusercontent.com/gunnarx/gocd-setup/master/go_server_install.sh | bash

[ -x "$(which yum)" ] && installer=yum && init=true
[ -x "$(which dnf)" ] && installer=dnf && init=true
[ -x "$(which apt-get)" ] && installer=apt-get && init="sudo apt-get update"

$init                                               && \
sudo $installer -y install git                      && \
git clone http://github.com/genivigo/gocd-setup -b lava_agent && \
cd gocd-setup                                       && \
echo "Running from:"                                && \
git log --date=iso --format=fuller --stat --abbrev-commit --decorate HEAD^..HEAD   && \
./go-server-setup.sh
