# HaloSir

HaloSir is the new server for Halo Word, the dictionary extension for Google Chrome.

HaloSir is based on Elixir/Phoenix, and use DETS from Erlang/OTP as storage instead of Redis. The main reason is Redis is consuming too much memory and we don't need that speed of in-memory database. This is also a good practice ground of developing and maintaining a full Elixir app/service.
