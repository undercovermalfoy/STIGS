#!/bin/bash

#####################
# Aditi Shah 
# IS 480
# Final project to fix STIGS from CAT I and CAT II
######################
# CAT I STIGS
# Updates andupgrades since they apply when it comes to ssh and sshd.service later on
sudo apt-get update
sudo apt-get upgrade

# V-238380 Disable Ctrl-Alt-Delete sequence for the command line
sudo systemctl disable ctrl-alt-del.target
sudo systemctl mask ctrl-alt-del.target
sudo systemctl daemon-reload
sudo systemctl status ctrl-alt-del.target

echo "V-238380 has now been fixed, Ctrl-Alt-Delete sequence disabled for command line"

# V-238201 mapping the authenticated identity
# Set "use_mappers=pwent" in "/etc/pam_pkcs11/pam_pkcs11.conf" or add it to the list if already present
PAM_PKCS11_CONF="/etc/pam_pkcs11/pam_pkcs11.conf"
EXAMPLE_CONF="/usr/share/doc/libpam-pkcs11/examples/pam_pkcs11.conf.example.gz"
# Check if /etc/pam_pkcs11 directory exists, create if not
if [ ! -d "/etc/pam_pkcs11" ]; then
  sudo mkdir /etc/pam_pkcs11
fi
# Check if /etc/pam_pkcs11/pam_pkcs11.conf exists
if [ ! -f "$PAM_PKCS11_CONF" ]; then
  # If not, copy the example configuration file and modify accordingly
  sudo zcat "$EXAMPLE_CONF" | sudo tee "$PAM_PKCS11_CONF"
  # Add "use_mappers=pwent" to the configuration
  sudo sed -i 's/\(#use_mappers.*\)/\1,pwent/' "$PAM_PKCS11_CONF"
  echo "PAM_PKCS11 configuration file created and modified."
else
  # If the file already exists, add "use_mappers=pwent" to the existing configuration
  sudo sed -i '/^use_mappers/ s/$/,pwent/' "$PAM_PKCS11_CONF"
  echo "PAM_PKCS11 configuration file modified."
fi
grep use_mappers /etc/pam_pkcs11/pam_pkcs11.conf 
echo "V-238201 has now been fixed"

# V-238215 checking for ssh and sshd.service
#Install the "ssh" meta-package on the system with the following command:
sudo apt install ssh
#Enable the "ssh" service to start automatically on reboot with the following command: 
sudo systemctl enable sshd.service
#ensure the "ssh" service is running
sudo systemctl start sshd.service
sudo dpkg -l | grep openssh
sudo systemctl status sshd.service | egrep -i "(active|loaded)" 
echo "V-238215 has been fixed and sshd.service now works"

# Moving onto CAT II
# V-238200 installing vlock since it was not installed prior
sudo apt-get install vlock
dpkg -l | grep vlock 
echo "V-238200 is now fixed and vlock is installed"

# V-238207 terminating user session after inactivity timeouts have expired
# Configure the operating system to automatically terminate a user session after inactivity timeouts have expired or at shutdown.
TMOUT_FILE="/etc/profile.d/99-terminal_tmout.sh"
TMOUT_VALUE=600
# Check if the TMOUT file exists, create if not
if [ ! -f "$TMOUT_FILE" ]; then
  echo "TMOUT=$TMOUT_VALUE" | sudo tee "$TMOUT_FILE"
  echo "TMOUT file created and modified."
else
  # If the file already exists, modify or append the TMOUT value
  sudo sed -i "/^TMOUT=/ s/.*/TMOUT=$TMOUT_VALUE/" "$TMOUT_FILE"
  echo "TMOUT file modified."
fi
grep -E "\bTMOUT=[0-9]+" /etc/bash.bashrc /etc/profile.d/* 
echo "V-238207 is now fixed"
