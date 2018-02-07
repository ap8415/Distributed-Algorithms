defmodule Peer do

  def start id, system do
    receive_app = spawn(App, :receive_fn, [id])
    receive_beb = spawn(BEB, :receive_fn, [receive_app])
    receive_lpl = spawn(LPL, :receive_fn, [receive_beb])

    send_lpl = spawn(LPL, :send_fn, [receive_lpl])
    send_beb = spawn(BEB, :send_fn, [id, send_lpl])
    send_app = spawn(App, :send_fn, [send_beb])

    send system, {:lpl, id, receive_lpl}

    lpl_map = receive do
      {:all_lpls, lpl_map} -> lpl_map
    end

    {timeout, max_broadcasts} = receive do
      {:broadcast, timeout, max_broadcasts} -> {timeout, max_broadcasts}
    end

    IO.puts timeout

    send send_app, {:metadata, max_broadcasts}
    send send_lpl, {:metadata, lpl_map, timeout}
    send send_beb, {:metadata, map_size(lpl_map)}
    send receive_app, {:metadata, map_size(lpl_map), timeout}
    send receive_beb, {:metadata, timeout}
    send receive_lpl, {:metadata, timeout}
  end

end
