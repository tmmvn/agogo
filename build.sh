#!/bin/sh

if ! mrbc -Bapp agogo.rb; then
echo "Error building agogo (mrbc)."
exit 1
fi
if ! gcc -std=c99 -L/opt/local/lib/mruby -I/opt/local/include -Imruby/include app_stub.c -o agogo -lmruby -lm; then
	echo "Error building agogo (gcc)."
	exit 1
fi
echo "agogo built successfully."
