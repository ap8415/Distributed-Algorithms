defmodule System4 do

  def start do
    {number_of_peers, _ } = Integer.parse(Enum.at(System.argv() , 0));
    {max_broadcasts, _ } = Integer.parse(Enum.at(System.argv() , 1));
    {timeout, _ } = Integer.parse(Enum.at(System.argv() , 2));
    {reliability, _ } =  Integer.parse(Enum.at(System.argv() , 3));
    {local, _} = Integer.parse(Enum.at(System.argv() , 4)); # 0 for local, 1 for Docker network

    peers = for i <- 1..number_of_peers do
      if local == 0 do
        spawn(Peer, :start, [i-1, self(), reliability])
      else
        Node.spawn(:'node#{i}@container#{i}.localdomain', Peer, :start, [i-1, self(), reliability])
      end
    end

    initialize_lpls(number_of_peers, %{}, peers)
    for peer <- peers, do: send peer, {:broadcast, timeout, max_broadcasts}
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
