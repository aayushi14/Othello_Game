#!/bin/bash

export PORT=5114

cd ~/www/Othello_Game
./bin/Othello_Game stop || true
./bin/Othello_Game start
