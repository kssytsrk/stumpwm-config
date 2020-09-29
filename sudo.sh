#! /bin/bash
IFS= read -rs PASSWD
sudo -k
if sudo -lS &> /dev/null << EOF
$PASSWD
EOF
then
    echo "0"
else
    echo "1"
fi
