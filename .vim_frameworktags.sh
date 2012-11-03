#!/bin/bash

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "\nBegin tagging $DIR \n"

cd /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.0.sdk/System/Library/Frameworks

	echo "tagging $i"

	ctags -f $DIR/tags.ios6 -R \
		--exclude=.git \
		--langdef=objc \
		--langmap=objc:.m.h \
		--tag-relative=yes \
		--totals=yes

echo "\nEnd tagging\n"
