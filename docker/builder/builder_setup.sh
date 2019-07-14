#!/usr/bin/env bash

set -ex

# Prepare GitHub repo access
mkdir /root/.ssh/
touch /root/.ssh/known_hosts
ssh-keyscan github.com >> /root/.ssh/known_hosts

# Install unzip and setup locales for Elixir
apt-get update
apt-get install -y --no-install-recommends unzip locales

locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8

# Install Erlang and Elixir
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.2

. ~/.asdf/asdf.sh
asdf plugin-add erlang
asdf plugin-add elixir
asdf install
asdf install

mix local.hex --force
mix local.rebar --force
