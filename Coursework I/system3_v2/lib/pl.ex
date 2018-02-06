defmodule PL do

  def receive_fn receive_beb do
    timeout = receive do
      {:metadata, timeout} -> timeout
    end

    end_time = timeout + :os.system_time(:milli_seconds)
    next_receive(receive_beb, end_time)
  end

  def next_receive(beb, end_time) do
    if (:os.system_time(:milli_seconds) > end_time) do
      receive do
        {:timeout, send_state} -> send beb, {:timeout, send_state}
      end
    else
      receive do
        {:message, id} ->
          send beb, {:pl_deliver, id}
          next_receive(beb, end_time)
        {:timeout, send_state} -> send beb, {:timeout, send_state}
      end
    end
  end

  def send_fn receive_pl do
    {pl_map, timeout} = receive do
      {:metadata, pl_map, timeout} -> {pl_map, timeout}
    end

    end_time = timeout + :os.system_time(:milli_seconds)
    :timer.send_after(timeout, {:timeout})
    empty_state = for _ <- 1..map_size(pl_map), do: 0
    next_send(empty_state, pl_map, end_time, receive_pl)
  end

  def next_send(send_state, pl_map, end_time, receive_pl) do
    if (:os.system_time(:milli_seconds) > end_time) do
      send receive_pl, {:timeout, send_state}
    else
      receive do
        {:pl_send, to, from} ->
          send Map.get(pl_map, to), {:message, from}
          new_state = List.replace_at(send_state, to, Enum.at(send_state, to) + 1)
          next_send(new_state, pl_map, end_time, receive_pl)
        {:timeout} -> send receive_pl, {:timeout, send_state}
      end
    end
  end

end
