elixirc client.ex
elixirc system1.ex

elixir -e System1.start

del -Force Elixir.Client.beam
del -Force Elixir.Server.beam
