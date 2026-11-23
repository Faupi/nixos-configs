#!/usr/bin/env zsh
#shellcheck shell=bash

# If running inside kitty, wrap ssh with its handler so that remotes don't need terminal definitions to work properly

if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ssh="kitten ssh"
  alias ssh-native="command ssh"
fi
