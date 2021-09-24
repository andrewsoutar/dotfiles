#!/bin/bash

set -o errexit -o nounset -o pipefail
shopt -s inherit_errexit extglob

if [ -e /run/.toolboxenv ] || [ -e /.flatpak-info ]; then
    exec flatpak-spawn --host -- "${0##*/}" "$@"
else
    exec "$(PATH="${PATH##@(|*:)${0%/*}:}" type -p "${0##*/}")" "$@"
fi
