#!/bin/bash
set -e
die() { echo "$*" 1>&2; exit 1; }
cd "$(dirname "$0")"
[[ $EUID > 0 ]] && die "Please run this script as root, it needs to copy files to /etc"
grep -q "^pi:" /etc/passwd || die "Could not find user 'pi', this script is meant for a Raspberry Pi"

if grep -q "PATH=~/java-lto/scripts" /home/pi/.bashrc; then
    echo "** Detected a previous installation, do you want to overwrite files?"
    read -p "** Press Enter to continue, Ctrl+C to abort. "
else
    echo "export PATH=~/java-lto/scripts:\$PATH" >> /home/pi/.bashrc
fi

echo "** Moving files to /home/pi/java-lto/"
mv -v java-lto /home/pi/
chown -R pi:pi /home/pi/java-lto

echo "** Merging files to /etc/"
chown root:root etc
cp -vr etc/* /etc

echo "** Cleaning up installation files"
cd ..
rm -r lto-raspberry/

echo "** Preparing lto.service"
systemctl daemon-reload

echo "** Installed successfully! Personalize your config & start with 'systemctl --now enable lto'"

# EOF
