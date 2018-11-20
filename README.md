# HaloSir

[![Build Status](https://travis-ci.org/HaloWordApp/halosir.svg?branch=master)](https://travis-ci.org/HaloWordApp/halosir)

HaloSir is the new server for [Halo Word](https://github.com/HaloWordApp/haloword), the English -> Chinese dictionary as an extension for Google Chrome.

HaloSir is based on Elixir/Phoenix, and use DETS from Erlang/OTP as storage instead of Redis. The main reason is Redis is consuming too much memory and we don't need that speed of an in-memory database. This is also a good practice ground of developing and maintaining a full Elixir app/service.

### Deployment

The OTP release building process is automated through [CircleCI](.circleci/config.yml). Output tarballs are stored [here](https://github.com/HaloWordApp/halosir/releases).

To deploy HaloSir, just:

- Extract the tarball
- Put runtime configs under `{tarball root}/config/secret.exs`, which should replace secret keys and any other production settings
- Put existing cache under `{tarball root}/data` if exist
