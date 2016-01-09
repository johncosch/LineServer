#!/bin/bash -x

if [ -f "$1" ]
then
	export LINE_SERVER_FILE="$1"
	puma -C config/puma.rb
else
    echo "A valid file is required."
fi

