defmodule System2 do

  def start do
     # Later on, input these via cmdline
    number_of_peers = 5
    timeout = 3000
    max_broadcasts = 100
    peers = for i <- 0..number_of_peers - 1 do
      spawn(Peer, :start, [i, self()])
    end
    initialize_pls(number_of_peers, %{}, peers)
    :timer.sleep(1000)
  end

  defp initialize_pls(ctr, pl_map, peers) do
    if (ctr == 0) do
      broadcast_pls(pl_map, peers)
    else
      receive do
      {:pl, id, pl_component} ->
        initialize_pls(ctr - 1, Map.put(pl_map, id, pl_component), peers)
      end
    end
  end

  defp broadcast_pls(pl_map, peers) do
    for peer <- peers, do: send peer, {:all_pls, pl_map}
  end

end
