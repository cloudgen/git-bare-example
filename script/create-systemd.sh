#!/bin/sh

APP=example
USR=ex-user
PRJ=git-bare-example

create_user () {
  useradd -m -s /bin/bash $USR
  sudo su - $USR /bin/bash -c "ssh-keygen -q -t rsa -N '' <<< $'\ny' >/dev/null 2>&1"
  sudo su - $USR /bin/bash -c "mkdir -p /home/$USR/git-bare-example/src"
  sudo su - $USR /bin/bash -c "touch /home/$USR/git-bare/example/src/main.py"
}

create_systemd () {
  ORIGINAL=/tmp/$APP-$$
  TARGET=/etc/systemd/system/$APP.service
  cat > $ORIGINAL <<EOF
[Unit]
Description=$APP

[Service]
User=ex-user
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/$USR
ExecStart=/usr/bin/python3 /home/$USR/$PRJ/src/main.py

[Install]
WantedBy=multi-user.target

EOF
  chmod +x $ORIGINAL
  sudo mv $ORIGINAL $TARGET
  sudo systemctl daemon-reload
  sudo systemctl enable $APP
}


if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi
create_user
create_systemd

