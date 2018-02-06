defmodule Peer do

  def start id, system do
    beb = spawn(BEB, :start, [])
    lpl = spawn(LPL, :start, [id])
    app = spawn(App, :start, [id])
    send system, {:lpl, id, lpl}
    send app, {:bind_beb, beb}
    send lpl, {:bind_beb, beb}
    send beb, {:bind, app, lpl}
    {timeout, max_broadcasts} = receive do
      {:broadcast, t_out, max_b} -> {t_out, max_b}
    end
    receive do
      {:all_lpls, lpl_map} ->
        send lpl, {:metadata, lpl_map, timeout}
        send beb, {:metadata, map_size(lpl_map), timeout}
        send app, {:metadata, map_size(lpl_map), timeout, max_broadcasts}
    end
  end

end
