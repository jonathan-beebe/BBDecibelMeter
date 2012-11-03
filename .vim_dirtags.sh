#!/bin/bash
cd $1
echo "tagging $1"

ctags * \
--exclude=.git \
--langdef=objc \
--langmap=objc:.m.h
