#!/bin/bash -x

bundle install --without test

echo "The line server was successfully build please use 'bash run.sh < absolute path to file >' to start the server"