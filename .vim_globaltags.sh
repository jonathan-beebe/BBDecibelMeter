#!/bin/bash

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "\nBegin tagging $DIR \n"

# find -L * -type d -exec "$DIR/.vim_dirtags.sh" {} \;

find -L * -type d \
-not -wholename '*.git*' \
-not -wholename '*assets*' \
-not -wholename '*gii*' \
-not -name 'logs' \
-not -wholename 'yii-*' \
-not -wholename '*framework/messages*' \
-not -wholename '*framework/i18n*' \
-exec "$DIR/.vim_dirtags.sh" {} \;

ctags --file-scope=no -R \
--exclude=.git \
--langdef=objc \
--langmap=objc:.m.h \
--totals=yes

echo "\nEnd tagging\n"
