#!/bin/bash

path=$(readlink -f ./cmds)
cd _site
lftp -f $path
