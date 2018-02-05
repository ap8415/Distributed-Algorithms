defmodule Server do

  def start do
    peers = 5 # Later on, input this via cmdline.
    clients = for _ <- 1..peers, do: spawn(Client, :start, [])
    :timer.sleep(100)
  end

end
