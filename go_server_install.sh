#!/bin/sh

# All-in-one wrapper can be downloaded and piped to a shell directly:
# curl https://raw.githubusercontent.com/gunnarx/gocd-setup/master/go_server_install.sh | bash

[ -x "$(which yum)" ] && installer=yum && init=true
[ -x "$(which dnf)" ] && installer=dnf && init=true
[ -x "$(which apt-get)" ] && installer=apt-get && init="sudo apt-get update"

$init                                               && \
sudo $installer -y install git                      && \
git clone http://github.com/gunnarx/gocd-setup      && \
cd gocd-setup                                       && \
./go-server-setup.sh
