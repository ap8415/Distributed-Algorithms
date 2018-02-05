defmodule Server do

  def start do
    peers = 4 # Later on, input this via cmdline; no of peers = $peers + 1
    clients = for i <- 0..peers, do: spawn(Client, :start, [i])
    for c <- clients do
      send c, {:bind, clients}
    end
    :timer.sleep(100)
  end

end
