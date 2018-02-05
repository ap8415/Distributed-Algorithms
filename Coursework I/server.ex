defmodule Server do

  def start do
    number_of_peers = 5 # Later on, input this via cmdline; no of peers = $peers + 1
    peers = for i <- 1..number_of_peers, do: spawn(Client, :start, [i-1])
    for c <- peers do
      send c, {:bind, peers}
    end
    :timer.sleep(1000)
  end

end
