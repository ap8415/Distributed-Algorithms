elixirc client.ex
elixirc server.ex
elixirc main.ex

elixir -e Main.main

del -Force Elixir.Client.beam
del -Force Elixir.Server.beam
del -Force Elixir.Main.beam
