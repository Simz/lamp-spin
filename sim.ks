# 
# Maintained by the Fedora Desktop SIG:
# http://fedoraproject.org/wiki/SIGs/Desktop
# mailto:desktop@lists.fedoraproject.org

%include fedora-live-base.ks

part / --size 8096

repo --name=fedora-chromium --baseurl=http://repos.fedorapeople.org/repos/spot/chromium/fedora-16/i386/
repo --name=rpmfusion-free --baseurl=http://download1.rpmfusion.org/free/fedora/development/$basearch/os/
repo --name=rpmfusion-nonfree --baseurl=http://download1.rpmfusion.org/nonfree/fedora/development/$basearch/os/
repo --name=virtualbox --baseurl=http://download.virtualbox.org/virtualbox/rpm/fedora/16/$basearch/
repo --name=flash --baseurl=http://linuxdownload.adobe.com/linux/$basearch/
repo --name=chrome --baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch/

%packages
@graphical-internet
@sound-and-video
@gnome-desktop
@office

# FIXME; apparently the glibc maintainers dislike this, but it got put into the
# desktop image at some point.  We won't touch this one for now.
nss-mdns

# This one needs to be kicked out of @base
-smartmontools

# The gnome-shell team does not want extensions in the default spin;
# ibus support in gnome-shell will be integrated in GNOME 3.4
-ibus-gnome3

##########
# tools
##########
vim-enhanced
bash-completion
gnome-tweak-tool
gnote
nautilus-image-converter
nautilus-actions
nautilus-open-terminal
nautilus-sendto
xchat
chromium
google-chrome-stable
gimp
flash-plugin

gstreamer-plugins-ugly
gstreamer-ffmpeg
gstreamer-plugins-bad
gstreamer-plugins-bad-extras
gstreamer-plugins-bad-nonfree
vlc
mozilla-vlc
ffmpeg
ffmpeg2theora
mencoder
mplayer

VirtualBox-4.1
gparted
nano
powertop
sshfs
p7zip-plugins
unrar
screen
rdesktop
remmina
tigervnc
make
binutils
gcc
glibc-devel
glibc-headers
libgomp
patch
kernel-headers
kernel-devel

##########
# web
#########
httpd
php
php-mysql
php-common
php-gd
ImageMagick
php-mbstring
php-mcrypt
phpmyadmin
php-pecl-xdebug
php-phpunit-PHPUnit
meld
subversion
git
mysql-workbench
rabbitvcs-nautilus
rabbitvcs-gedit
rabbitvcs-core
rabbitvcs-cli
#########
# Repo
#########
rpmfusion-free-release
rpmfusion-nonfree-release
adobe-release-x86_64.noarch


%end

%post
cat >> /etc/rc.d/init.d/livesys << EOF
# disable screensaver locking
cat >> /usr/share/glib-2.0/schemas/org.gnome.desktop.screensaver.gschema.override << FOE
[org.gnome.desktop.screensaver]
lock-enabled=false
FOE

# and hide the lock screen option
cat >> /usr/share/glib-2.0/schemas/org.gnome.desktop.lockdown.gschema.override << FOE
[org.gnome.desktop.lockdown]
disable-lock-screen=true
FOE

# disable updates plugin
cat >> /usr/share/glib-2.0/schemas/org.gnome.settings-daemon.plugins.updates.gschema.override << FOE
[org.gnome.settings-daemon.plugins.updates]
active=false
FOE

# make the installer show up
if [ -f /usr/share/applications/liveinst.desktop ]; then
  # Show harddisk install in shell dash
  sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop ""
  # need to move it to anaconda.desktop to make shell happy
  mv /usr/share/applications/liveinst.desktop /usr/share/applications/anaconda.desktop

  cat >> /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override << FOE
[org.gnome.shell]
favorite-apps=['mozilla-firefox.desktop', 'evolution.desktop', 'empathy.desktop', 'rhythmbox.desktop', 'shotwell.desktop', 'openoffice.org-writer.desktop', 'nautilus.desktop', 'anaconda.desktop']
FOE

fi

# rebuild schema cache with any overrides we installed
glib-compile-schemas /usr/share/glib-2.0/schemas

# set up auto-login
cat >> /etc/gdm/custom.conf << FOE
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=liveuser
FOE

# Turn off PackageKit-command-not-found while uninstalled
if [ -f /etc/PackageKit/CommandNotFound.conf ]; then
  sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf
fi

EOF
######
#repos
######
cat > /etc/yum.repos.d/virtualbox.repo <<DELIM
[virtualbox]
name=Fedora $releasever - $basearch - VirtualBox
baseurl=http://download.virtualbox.org/virtualbox/rpm/fedora/16/x86_64/  
enabled=1
gpgcheck=1
gpgkey=http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc
DELIM

cat > /etc/yum.repos.d/google-chrome.repo <<DELIM
[google-chrome]
name=google-chrome - 64-bit
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
DELIM


systemctl enable httpd.service
systemctl start httpd.service
systemctl enable mysqld.service
systemctl start mysqld.service
systemctl enable sendmail.service
systemctl start sendmail.service


%end
