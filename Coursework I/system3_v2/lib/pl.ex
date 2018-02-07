# Andrei-Bogdan Puiu (ap8415)
defmodule PL do

  def receive_fn receive_beb do
    timeout = receive do
      {:broadcast_data, timeout} -> timeout
    end

    end_time = timeout + :os.system_time(:milli_seconds)
    receive_next(receive_beb, end_time)
  end

  def receive_next(beb, end_time) do
    if (:os.system_time(:milli_seconds) > end_time) do
      receive do
        {:timeout, send_state} -> send beb, {:timeout, send_state}
      end
    else
      receive do
        {:message, id} ->
          send beb, {:pl_deliver, id}
          receive_next(beb, end_time)
        {:timeout, send_state} -> send beb, {:timeout, send_state}
      end
    end
  end

  def send_fn receive_pl do
    {pl_map, timeout} = receive do
      {:broadcast_data, pl_map, timeout} -> {pl_map, timeout}
    end

    end_time = timeout + :os.system_time(:milli_seconds)
    :timer.send_after(timeout, {:timeout})
    empty_state = for _ <- 1..map_size(pl_map), do: 0
    send_next(empty_state, pl_map, end_time, receive_pl)
  end

  def send_next(send_state, pl_map, end_time, receive_pl) do
    if (:os.system_time(:milli_seconds) > end_time) do
      send receive_pl, {:timeout, send_state}
    else
      receive do
        {:pl_send, to, from} ->
          send Map.get(pl_map, to), {:message, from}
          new_state = List.replace_at(send_state, to, Enum.at(send_state, to) + 1)
          send_next(new_state, pl_map, end_time, receive_pl)
        {:timeout} -> send receive_pl, {:timeout, send_state}
      end
    end
  end

end
