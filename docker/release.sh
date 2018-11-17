#!/usr/bin/env bash

set -ex

. ~/.asdf/asdf.sh

asdf current

mix local.hex --force
mix local.rebar --force

export MIX_ENV=prod

mix deps.get --only prod
mix release --profile=halosir:prod

mkdir /artifact
cp /_build/prod/rel/halosir/releases/*/halosir.tar.gz /artifact/
