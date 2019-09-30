#!/bin/sh

# Yet another wrapper around go-agent install.  This one is all-in-one,
# and can be downloaded and piped to a shell directly:
# curl https://raw.githubusercontent.com/gunnarx/gocd-setup/master/go_agent_install.sh | bash

[ -x "$(which yum)" ] && installer=yum && init=true
[ -x "$(which dnf)" ] && installer=dnf && init=true
[ -x "$(which apt-get)" ] && installer=apt-get && init="sudo apt-get update"

$init                                               && \
sudo $installer -y install git                      && \
git clone http://github.com/genivigo/gocd-setup -b lava_agent && \
cd gocd-setup                                       && \
./go-agent-setup.sh
