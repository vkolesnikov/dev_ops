# installation in text mode
text
#graphical
# install from
#cdrom

#http://mirrors.sgu.ru/fedora/linux/releases/31/Workstation/x86_64
#url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-30&arch=x86_64"
#repo --name="EPEL" --baseurl=http://dl.fedoraproject.org/pub/epel/7/x86_64
url --metalink="https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch"
repo --name=fedora-updates --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f30&arch=x86_64" --cost=0
repo --name=rpmfusion-free --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-30&arch=x86_64" --includepkgs=rpmfusion-free-release
repo --name=rpmfusion-free-updates --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-30&arch=x86_64" --cost=0
repo --name=rpmfusion-nonfree --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-30&arch=x86_64" --includepkgs=rpmfusion-nonfree-release
repo --name=rpmfusion-nonfree-updates --mirrorlist="https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-30&arch=x86_64" --cost=0

# language, keyboard, time settings
lang en_US.UTF-8
keyboard us
timezone --utc Europe/Saratov

xconfig --startxonboot

#root password in plain text
rootpw  --plaintext admin 

# some "secure enhanced linux" dunno.
selinux --disabled

# Custom user added
user --name=viktor --groups=users,wheel --password=admin
authconfig --enableshadow --passalgo=sha512 --enablefingerprint
firewall --enabled --ssh

eula --agreed
# The following is the partition information you requested
# Note that any partitions you deleted are not expressed
# here so unless you clear all partitions first, this is
# not guaranteed to work
bootloader --location=mbr --driveorder=sda 
zerombr
autopart --type=lvm
clearpart --all --drives=sda
# ignoredisk --only-use=sda
# part /boot --fstype=ext4 --asprimary --size=512
# part swap --asprimary --size=2048
# part / --size=8192 --grow --asprimary --ondrive=sda --fstype=ext4


# setup the network with DHCP
network --onboot=yes --bootproto=dhcp --activate
# packages that will be installed, anything starting with an @ sign is a yum package group.
%packages
#@core
#@standard
#@hardware-support
#@base-x
#@fonts
#@development-libs
#@development-tools
#@fedora-packager
@gnome-desktop
@gnome-software-development
#gpm
#cmake
#gitk
#git
#vim
#python3.8

@Python Classroom
@LibreOffice
#@GNOME Desktop Environment

chromium
java-latest-openjdk
firefox
git
vim
ansible
wget

%end
# Post-installation Script
%post 

#dnf install snapd -y
#sudo ln -s /var/lib/snapd/snap /snap
echo "Downloading ansible playbook"
curl https://raw.githubusercontent.com/vkolesnikov/dev_ops/master/install-absent.yml --output ~/install-absent.yml
#wget https://raw.githubusercontent.com/vkolesnikov/dev_ops/master/install-idea.yml -o ~/wget-out.log -P ~/ 
ansible-playbook ~/install-absent.yml
#sudo groupadd docker
sudo usermod -aG docker viktor

echo "Create initial service to setup docker on first boot"
curl https://raw.githubusercontent.com/vkolesnikov/dev_ops/master/my_docker_init.service --output /etc/systemd/system/my_docker_init.service
curl https://raw.githubusercontent.com/vkolesnikov/dev_ops/master/initial_setup.sh --output /usr/local/bin/initial_setup.sh
chmod a+x /usr/local/bin/initial_setup.sh
chmod a+x /etc/systemd/system/my_docker_init.service
systemctl enable my_docker_init.service

#docker run -d --restart=always -p 8080:8080 -p 50000:50000 -e JAVA_OPTS=-Djenkins.install.runSetupWizard=false -v /home/viktor/jenkins_home:/var/jenkins_home jenkins

#java -jar jenkins-cli.jar -s http://localhost:8080 create-job my_new_job < /home/viktor/jenkins_home1/jobs/some_job_name/config.xml
# jenkins cli is located here: https://jenkins.example.com/jnlpJars/jenkins-cli.jar
#docker run -d --restart=always -p 8081:8080 -p 29418:29418 -e GERRIT_INIT_ARGS='--install-plugin=download-commands' gerritcodereview/gerrit

echo "viktor ALL=(ALL)       ALL" >> /etc/sudoers
%end
