elixirc pl.ex
elixirc app.ex
elixirc peer.ex
elixirc system2.ex

elixir -e System2.start > garbage.txt

rm -f Elixir.System2.beam
rm -f Elixir.PL.beam
rm -f Elixir.Peer.beam
rm -f Elixir.App.beam
