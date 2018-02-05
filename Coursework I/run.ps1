elixirc client.ex
elixirc server.ex

elixir -e Server.start

del -Force Elixir.Client.beam
del -Force Elixir.Server.beam
