#!/bin/bash -e
PROJECT_ROOT=$(git rev-parse --show-toplevel)
pandoc $1.md -o ./$1.tex
sed -i -e 's/{https://github\.com/stakedtechnologies/PolkadotWP/blob/master/img/(.+)}/{$1}/g' ./*.tex
rm -rf ${SRC}/*-e
