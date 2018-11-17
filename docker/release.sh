#!/usr/bin/env bash

set -ex

. ~/.asdf/asdf.sh

asdf current

export MIX_ENV=prod

mix deps.get --only prod
mix release --profile=halosir:prod

mkdir /artifact
cp _build/prod/rel/halosir/releases/*/halosir.tar.gz /artifact/
