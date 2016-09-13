# HaloSir

[![CircleCI](https://circleci.com/gh/ElaWorkshop/halosir/tree/master.svg?style=svg)](https://circleci.com/gh/ElaWorkshop/halosir/tree/master)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/ElaWorkshop/halosir.svg)](https://beta.hexfaktor.org/github/ElaWorkshop/halosir)

HaloSir is the new server for Halo Word, the dictionary extension for Google Chrome.

HaloSir is based on Elixir/Phoenix, and use DETS from Erlang/OTP as storage instead of Redis. The main reason is Redis is consuming too much memory and we don't need that speed of an in-memory database. This is also a good practice ground of developing and maintaining a full Elixir app/service.
