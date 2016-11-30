# These are typical packages needed for our builds.
# Depending on your needs you can skip installing them...

[ $(id -u) -eq 0 ] || { echo "Please make sure you run as root for installation" ; exit 1 ; }

PACKAGES_RPM="
     SDL-devel
     asciidoc
     autoconf
     automake
     boost-devel
     boost-log
     boost-system
     boost-thread
     bzip2
     ccache
     chrpath
     cmake
     cpio
     cpp
     curl
     dbus-c++-devel
     dbus-devel
     diffstat
     diffutils
     docbook-xsl
     doxygen
     expat-devel
     file
     findutils
     fuse-devel
     gawk
     gcc
     gcc-c++
     git
     glibc-devel
     graphviz
     gzip
     intltool
     libtool
     make
     maven
     patch
     perl
     perl-Data-Dumper
     perl-Text-ParseWords
     perl-Thread-Queue
     perl-bignum
     pkgconfig
     pulseaudio-libs-devel
     python
     python3
     python3-pexpect
     python3-pip
     socat
     source-highlight
     systemd-devel
     tar
     texinfo
     unzip
     wget
     which
     xterm
     xz
"

# Debian/Ubuntu - these are constantly updated by a cronjob in
# the docker-based agent setup at least.
# Let's reuse the same single source for that package list!
PACKAGES_DEB=" $(cat common_build_dependencies) "

installer=
[ -x "$(which apt-get 2>/dev/null)" ] && installer=apt-get
[ -x "$(which yum 2>/dev/null)" ] && installer=yum
[ -x "$(which dnf 2>/dev/null)" ] && installer=dnf
[ -e /etc/debian-release ] && installer=apt-get

case $installer in
   apt-get)
      export DEBIAN_FRONTEND=noninteractive
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
if fgrep -q Debian $osrelease ; then
  sudo apt-get install libsystemd-daemon-dev || {
    echo "Failed?  Not sure on systemd package name, but no problem - trying another:"
  sudo apt-get install libsystemd-dev
}
fi

