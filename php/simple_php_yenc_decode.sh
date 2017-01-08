#!/bin/sh

gcc `php-config --includes` -fpic -c source/yenc_decode_wrap.cpp

if [ ! -e yenc_decode_wrap.o ]; then
	echo "Error creating yenc_decode_wrap.o!"
	exit 1
fi

gcc -fpic -c source/yenc_decode.cpp -lboost_regex

if [ ! -e yenc_decode.o ]; then
	echo "Error creating yenc_decode.o!"
	exit 2
fi

EXTENSIONS=`php-config --extension-dir`

if [ ! -e ${EXTENSIONS} ]; then
	echo "Error locating extensions directory ${EXTENSIONS}!"
	exit 3
fi

gcc -shared *.o -o ${EXTENSIONS}/simple_php_yenc_decode.so -lboost_regex

rm yenc_decode.o
rm yenc_decode_wrap.o

if [ ! -e ${EXTENSIONS}/simple_php_yenc_decode.so ]; then
	echo "Error creating ${EXTENSIONS}/simple_php_yenc_decode.so!"
	exit 4
else
	echo "The extension was compiled successfully."
fi

if [ -e /etc/php5/conf.d/simple_php_yenc_decode.ini ]; then
	echo "Error: This file (/etc/php/conf.d/simple_php_yenc_decode.ini) already exists, if the contents look like this (change it if not): extension=${EXTENSIONS}/simple_php_yenc_decode.so"
	exit 5
else
	echo "extension=${EXTENSIONS}/simple_php_yenc_decode.so" > ./simple_php_yenc_decode.ini
	mv ./simple_php_yenc_decode.ini /etc/php5/conf.d/simple_php_yenc_decode.ini
	if [ ! -e /etc/php5/conf.d/simple_php_yenc_decode.ini ]; then
		echo "Error creating (/etc/php/conf.d/simple_php_yenc_decode.ini). You can manually make this file and put this content in it: extension=${EXTENSIONS}/simple_php_yenc_decode.so"
		exit 6
	fi
	echo "Everything was successful, you should now be able to use the extension in PHP."
fi
