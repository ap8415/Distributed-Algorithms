# Andrei-Bogdan Puiu (ap8415)
defmodule Peer do

  def start id, system do
    beb = spawn(BEB, :start, [])
    pl = spawn(PL, :start, [id])
    app = spawn(App, :start, [id])

    send system, {:pl, id, pl}
    send app, {:bind_beb, beb}
    send pl, {:bind_beb, beb}
    send beb, {:bind, app, pl}

    pl_map = receive do
      {:all_pls, pl_map} -> pl_map
    end

    {timeout, max_broadcasts} = receive do
      {:broadcast, timeout, max_broadcasts} -> {timeout, max_broadcasts}
    end

    send pl, {:broadcast_data, pl_map, timeout}
    send beb, {:broadcast_data, map_size(pl_map), timeout}
    send app, {:broadcast_data, map_size(pl_map), timeout, max_broadcasts}

  end

end
