defmodule System1 do

  def start do
     # Later on, input these via cmdline
    number_of_peers = 5
    timeout = 3000
    max_broadcasts = 1000000
    peers = for i <- 1..number_of_peers, do: spawn(Client, :start, [i-1])
    for c <- peers do
      send c, {:bind, peers}
      send c, {:broadcast, timeout, max_broadcasts}
    end
  end

end
