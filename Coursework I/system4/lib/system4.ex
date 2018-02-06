defmodule System4 do

  def start do
     # Later on, input these via cmdline
    number_of_peers = 5
    timeout = 3000
    max_broadcasts = 1000000
    peers = for i <- 0..number_of_peers - 1 do
      spawn(Peer, :start, [i, self()])
    end
    for peer <- peers, do: send peer, {:broadcast, timeout, max_broadcasts}
    initialize_lpls(number_of_peers, %{}, peers)
  end

  defp initialize_lpls(ctr, lpl_map, peers) do
    if (ctr == 0) do
      broadcast_lpls(lpl_map, peers)
    else
      receive do
      {:lpl, id, lpl_component} ->
        initialize_lpls(ctr - 1, Map.put(lpl_map, id, lpl_component), peers)
      end
    end
  end

  defp broadcast_lpls(lpl_map, peers) do
    for peer <- peers, do: send peer, {:all_lpls, lpl_map}
  end

end
