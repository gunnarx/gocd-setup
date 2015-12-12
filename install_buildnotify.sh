#!/bin/sh
# (C) 2015 Gunnar Andersson
# LICENSE: GPLv2

echo "--------------------------------------------------------"
echo This script is mostly for instruction, it might fail, 
echo in which case you are encouraged to read the script and
echo use it just as information instead.
echo "--------------------------------------------------------"

. ./go_server || { echo  "Can't find go_server definition" ; exit 1 ; }

CCURL="http://buildmonitor:<ask_someone_for_the_password>@$GO_SERVER:$GO_SERVER_PORT/go/cctray.xml"

# Modern fedora uses dnf, earlier use yum, ubuntu/debian uses apt-get
installer=UNKNOWN
os=fedora

[ -x /usr/bin/yum ] && installer=yum
[ -x /usr/bin/dnf ] && installer=dnf

# Package install might work on debian, haven't tested
[ -x /usr/bin/apt-get ] && { installer=apt-get ; os=ubuntu ; }

if [ $os = ubuntu ] ; then
   echo "Installing for ubuntu (debian)"
   # Package exists on ubuntu according to web page - I haven't tested debian
   sudo $installer install BuildNotify
else
   # On an old fedora, I had to install using python installation method
   # Maybe an rpm package is available now, I don't know.
   echo "*** Assuming Fedora OS - if using arch, suse or other, please edit script!"
   echo Installing using Python PIP easy_install
   sudo $installer -q install python-pip pyqt4
   sudo pip install --upgrade pip               # might as well...
   sudo pip install pytz
   sudo pip install python-dateutil
   sudo easy_install BuildNotify
fi

echo "--------------------------------------------------------"
echo "Done (check for errors above)"
echo
echo "Setup: If all is OK, you can run buildnotifyapplet.py"
echo "Then find it in the tray, right click -> Preferences"
echo
echo "Then add monitoring for this url: "
echo "$CCURL"
echo
echo "WARNING!  Buildmonitor does not support SSL, therefore"
echo "you should NOT use your personal account & password - ask for"
echo "the password to the limited buildmonitor account instead!"
echo "--------------------------------------------------------"


