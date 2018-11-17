#!/usr/bin/env bash

set -ex

# Prepare GitHub repo access
mkdir /root/.ssh/
touch /root/.ssh/known_hosts
ssh-keyscan github.com >> /root/.ssh/known_hosts

# Install unzip for Elixir
apt-get update
apt-get install -y --no-install-recommends unzip

# Install Erlang and Elixir
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.1

. ~/.asdf/asdf.sh
asdf plugin-add erlang
asdf plugin-add elixir
asdf install
asdf install
