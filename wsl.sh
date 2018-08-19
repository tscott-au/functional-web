#! /bin/bash
result=${PWD##*/}
rsync -a --delete --exclude={deps/,_build/} ./ ~/dev_build/elixir/$result
cd ~/dev_build/elixir/$result
$1 $2 $3 $4 $5
elixir --version