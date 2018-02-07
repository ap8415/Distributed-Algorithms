# Andrei-Bogdan Puiu (ap8415)
defmodule System1 do

  def start() do
    {number_of_peers, _ } = Integer.parse(Enum.at(System.argv() , 0));
    {max_broadcasts, _ } = Integer.parse(Enum.at(System.argv() , 1));
    {timeout, _ } = Integer.parse(Enum.at(System.argv() , 2));
    {local, _} = Integer.parse(Enum.at(System.argv() , 3)); # 0 for local, 1 for Docker network

    peers = for i <- 1..number_of_peers do
      if local == 0 do
        spawn(Client, :start, [i-1])
      else
        Node.spawn(:'node#{i}@container#{i}.localdomain', Client, :start, [i-1])
      end
    end

    for peer <- peers do
      send peer, {:bind, peers}
      send peer, {:broadcast, timeout, max_broadcasts}
    end
  end

end
