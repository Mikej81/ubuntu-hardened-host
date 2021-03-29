# todo

- echo '* hard maxlogins 10' >> /etc/security/limits.conf
- sudo apt-get remove telnet
- sed -i 's|PASS_MIN_DAYS.*|PASS_MIN_DAYS   1|g' /etc/login.defs
- sed -i 's|PASS_MAX_DAYS.*|PASS_MAX_DAYS   60|g' /etc/login.defs
- echo "CREATE_HOME yes" >> /etc/login.defs
- printf '#!/bin/bash\nTMOUT=900\nreadonly TMOUT\nexport TMOUT' > /etc/profile.d/autologout.sh
- chmod 755 /etc/profile.d/autologout.sh
- mkdir /etc/dconf/db/local.d/
- printf '[org/gnome/settings-daemon/plugins/media-keys]\nlogout="" ' > /etc/dconf/db/local.d/00-disable-CAD
- dconf update
- echo "install usb-storage /bin/true" >> /etc/modprobe.d/disable_usb_storage.conf
