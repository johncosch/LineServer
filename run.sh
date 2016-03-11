#!/bin/bash -x

if [ -f "$1" ]
then
  export LINE_SERVER_FILE="$1"
  rackup
else
    echo "A valid file is required."
fi

