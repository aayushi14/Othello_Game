#!/bin/bash

export PORT=5114
export MIX_ENV=prod
export GIT_PATH=/home/othello/Othello_Game

PWD=`pwd`
if [ $PWD != $GIT_PATH ]; then
	echo "Error: Must check out git repo to $GIT_PATH"
	echo "  Current directory is $PWD"
	exit 1
fi

if [ $USER != "othello" ]; then
	echo "Error: must run as user 'othello'"
	echo "  Current user is $USER"
	exit 2
fi

mix deps.get
(cd assets && npm install)
(cd assets && ./node_modules/brunch/bin/brunch b -p)
mix phx.digest
mix release --env=prod

mkdir -p ~/www
mkdir -p ~/old

NOW=`date +%s`
if [ -d ~/www/Othello_Game ]; then
	echo mv ~/www/Othello_Game ~/old/$NOW
	mv ~/www/Othello_Game ~/old/$NOW
fi

mkdir -p ~/www/Othello_Game
REL_TAR=~/Othello_Game/_build/prod/rel/othello/releases/0.0.1/othello.tar.gz
(cd ~/www/Othello_Game && tar xzvf $REL_TAR)

crontab - <<CRONTAB
@reboot bash /home/othello/Othello_Game/start.sh
CRONTAB

#. start.sh
