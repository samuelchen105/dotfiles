#!/usr/bin/env bash

echo "Creating config directory..."
mkdir -p ~/.config/fish

echo "Linking config file..."
stow -S -t $HOME fish && source ~/.config/fish/config.fish
