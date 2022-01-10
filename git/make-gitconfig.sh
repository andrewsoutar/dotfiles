#!/bin/sh
set -e

git config --file "$1" user.name "Andrew Soutar"
git config --file "$1" user.email "andrew@andrewsoutar.com"

git config --file "$1" github.user "andrewsoutar"
