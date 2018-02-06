elixirc client.ex
elixirc system1.ex

elixir -e System1.start

rm -f Elixir.Client.beam
rm -f Elixir.Server.beam
