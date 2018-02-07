defmodule Peer do

  def start id, system, reliability do
    beb = spawn(BEB, :start, [])
    lpl = spawn(LPL, :start, [id, reliability])
    app = spawn(App, :start, [id])

    send system, {:lpl, id, lpl}
    send app, {:bind_beb, beb}
    send lpl, {:bind_beb, beb}
    send beb, {:bind, app, lpl}

    lpl_map = receive do
      {:all_lpls, lpl_map} -> lpl_map
    end

    {timeout, max_broadcasts} = receive do
      {:broadcast, timeout, max_broadcasts} -> {timeout, max_broadcasts}
    end

    send lpl, {:broadcast_data, lpl_map, timeout}
    send beb, {:broadcast_data, map_size(lpl_map), timeout}
    send app, {:broadcast_data, map_size(lpl_map), timeout, max_broadcasts}
  end

end
