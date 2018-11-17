#!/usr/bin/env bash

set -ex

. ~/.asdf/asdf.sh
asdf current

mix deps.get
mix test

MIX_ENV=prod mix release --profile=halosir:prod

mkdir /artifact
cp _build/prod/rel/halosir/releases/*/halosir.tar.gz /artifact/
