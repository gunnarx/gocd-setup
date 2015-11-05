#!/bin/sh
# (C) Gunnar Andersson
# LICENSE: GPLv2

echo This script is mostly for instruction, it might fail, 
echo in which case you are encouraged to read the script and
echo use it as instruction information instead.

GO_SERVER=http://genivigo.com
GO_PORT=8153

CCURL=$GO_SERVER:$GO_PORT/go/cctray.xml

# Modern fedora uses dnf, earlier use yum, ubuntu/debian uses apt-get
[ -x $(which yum) ] && installer=yum
[ -x $(which dnf) ] && installer=dnf

# Package install might work on debian, haven't tested
[ -x $(which apt-get) ] && { installer=apt-get ; os=ubuntu ; }

if [ $os = ubuntu ] ; then
   echo "Installing for ubuntu (debian)"
   # Package exists on ubuntu according to web page - I haven't tested debian
   sudo $installer buildnotify
else
   # On earlier fedora, I had to install using python installation method
   # Maybe it is on later fedoras, I don't know
   echo "*** Assuming Fedora OS - if using arch, suse or other, please edit script!"
   echo Installing using Python PIP easy_install
   sudo $installer python-pip pyqt4
   easy_install buildnotify
fi

