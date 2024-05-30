#!/bin/bash

USR=git
PRJ=git-bare-example
GIT_HOME=/var/repo
WORK_HOME=$GIT_HOME/work-tree
BASE_DIR=$GIT_HOME/$PRJ.git
WORK_TREE=$WORK_HOME/$PRJ

create_user () {
  useradd -m -d $GIT_HOME -s /bin/bash $USR
  sudo su - $USR /bin/bash -c "ssh-keygen -q -t rsa -N '' <<< $'\ny' >/dev/null 2>&1"
  sudo su - $USR /bin/bash -c "mkdir -p $WORK_HOME"
  sudo su - $USR /bin/bash -c "mkdir -p $BASE_DIR"
  sudo su - $USR /bin/bash -c "cd $BASE_DIR && git init --bare"
}

create_post_receive_hook () {
  ORIGIN=/tmp/$PRJ-$$
  TARGET=$BASE_DIR/hooks/post-receive
  cat > $ORIGIN <<EOT
#!/bin/sh
PRJ=$PRJ
GIT_HOME=$GIT_HOME
WORK_HOME=\$GIT_HOME/work-tree
WORK_TREE=\$WORK_HOME/\$PRJ
BASE_DIR=\$GIT_HOME/\$PRJ.git

rm -rf $WORK_TREE
mkdir -p $WORK_TREE

git --work-tree=$WORK_TREE --git-dir=$BASE_DIR checkout -f main
sudo /usr/local/bin/deploy

EOT

  chmod +x $ORIGIN
  sudo mv $ORIGIN $TARGET
}

create_deploy () {
  ORIGIN=/tmp/deploy-$$
  TARGET=/usr/local/bin/deploy

  cat > $ORIGIN <<EOT
#!/bin/sh
sudo cp -rP $WORK_TREE /home/ex-user

EOT
  
  chmod +x $ORIGIN
  sudo mv $ORIGIN $TARGET
}

create_sudoer () {
  ORIGIN=/tmp/sudoer-$$
  TARGET=/etc/sudoers.d/100-git
  cat > $ORIGIN <<EOT
git ALL=(ALL) NOPASSWD: /usr/local/bin/

EOT

  sudo mv $ORIGIN $TARGET
}

if [[ "$EUID" == "0" ]]; then
  create_user
  create_post_receive_hook
  create_deploy
  create_sudoer
else
  echo "Please run as root"
  exit
fi
