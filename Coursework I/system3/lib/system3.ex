defmodule System3 do

  def start do
    {number_of_peers, _ } = Integer.parse(Enum.at(System.argv() , 0));
    {max_broadcasts, _ } = Integer.parse(Enum.at(System.argv() , 1));
    {timeout, _ } = Integer.parse(Enum.at(System.argv() , 2));
    {local, _} = Integer.parse(Enum.at(System.argv() , 3)); # 0 for local, 1 for Docker network

    peers = for i <- 1..number_of_peers do
      if local == 0 do
        spawn(Peer, :start, [i-1, self()])
      else
        Node.spawn(:'node#{i}@container#{i}.localdomain', Peer, :start, [i-1, self()])
      end
    end

    initialize_pls(number_of_peers, %{}, peers)
    for peer <- peers, do: send peer, {:broadcast, timeout, max_broadcasts}
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
