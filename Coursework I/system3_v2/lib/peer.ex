# Andrei-Bogdan Puiu (ap8415)
defmodule Peer do

  def start id, system do
    receive_app = spawn(App, :receive_fn, [id])
    receive_beb = spawn(BEB, :receive_fn, [receive_app])
    receive_pl = spawn(PL, :receive_fn, [receive_beb])

    send_pl = spawn(PL, :send_fn, [receive_pl])
    send_beb = spawn(BEB, :send_fn, [id, send_pl])
    send_app = spawn(App, :send_fn, [send_beb])

    send system, {:pl, id, receive_pl}

    pl_map = receive do
      {:all_pls, pl_map} -> pl_map
    end

    {timeout, max_broadcasts} = receive do
      {:broadcast, timeout, max_broadcasts} -> {timeout, max_broadcasts}
    end

    send send_app, {:broadcast_data, max_broadcasts}
    send send_pl, {:broadcast_data, pl_map, timeout}
    send send_beb, {:broadcast_data, map_size(pl_map)}
    send receive_app, {:broadcast_data, map_size(pl_map), timeout}
    send receive_beb, {:broadcast_data, timeout}
    send receive_pl, {:broadcast_data, timeout}
  end

end
