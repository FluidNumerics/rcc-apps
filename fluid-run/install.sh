#!/bin/bash
#
#
# //////////////////////////////////////////////////////////////// #


mkdir /apps/workspace
chmod ugo=rwx -R /apps/workspace

# Modify default bashrc to source profile, even for non-interactive shell
echo -e "source /etc/profile \n$(cat /etc/bash.bashrc)" > /etc/bash.bashrc

cat /dev/null > /var/log/messages
