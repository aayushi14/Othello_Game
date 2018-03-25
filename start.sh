#!/bin/bash

export PORT=5114

cd ~/www/Othello_Game
./bin/othello stop || true
./bin/othello start
