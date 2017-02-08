# These are typical packages needed for our builds. # Depending on your needs you can skip installing them...



PACKAGES_RPM="
     SDL-devel
     autoconf-
     automake
     asciidoc
     boost
     chrpath
     cmake
     cpio
     curl
     dbus-c++-devel
     dbus-devel
     diffstat
     docbook-xsl
     expat-devel
     fuse-devel
     gawk
     gcc
     gcc-c++
     git
     intltool
     libtool
     make
     maven
     pkgconfig
     pulseaudio-libs-devel
     python
     python3
     socat
     systemd-devel
     texinfo
     unzip
     wget
     xterm
"

PACKAGES_DEB="
     automake
     autotools-dev
     asciidoc
     build-essential
     chrpath
     cmake
     cpio
     curl
     diffstat
     docbook-xsl
     g++
     gawk
     gcc
     gcc-multilib
     git
     intltool
     libboost-dev
     libdbus-1-dev
     libdbus-c++-dev
     libexpat1-dev
     libfuse-dev
     libpulse-dev
     libsdl1.2-dev
     libsystemd-dev
     libtool
     make
     maven
     pkg-config
     python
     python3
     socat
     texinfo
     unzip
     wget
     xterm
"

installer=
[ -x "$(which apt-get 2>/dev/null)" ] && installer=apt-get
[ -x "$(which yum 2>/dev/null)" ] && installer=yum
[ -x "$(which dnf 2>/dev/null)" ] && installer=dnf
[ -e /etc/debian-release ] && installer=apt-get

case $installer in
   apt-get)
      sudo $installer update
      sudo $installer install -y $PACKAGES_DEB
      ;;
   dnf|yum)
      sudo $installer install -y $PACKAGES_RPM
      ;;
   *)
      echo "Unsupported package type - fix script"
      exit 1
      ;;
esac

# Bugfix deb packages that have changed names
osrelease=/etc/os-release
fgrep -q Ubuntu $osrelease && fgrep -q 14.04 $osrelease && sudo apt-get install libsystemd-daemon-dev
fgrep -q Ubuntu $osrelease && fgrep -q 16.04 $osrelease && sudo apt-get install libsystemd-dev
# FIXME - not sure which version needs what here...
fgrep -q Debian $osrelease && sudo apt-get install libsystemd-daemon-dev || {
   echo "Failed?  Not sure on systemd package name, but no problem - trying another:"
   sudo apt-get install libsystemd-dev
}

