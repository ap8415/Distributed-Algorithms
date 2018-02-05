defmodule PL do

  def start id do
    receive do
      {:all_pls, pl_map} -> handler(id, pl_map)
    end
  end

  defp handler(id, pl_map) do
    # Make 2 processes, one for sending, one for broadcasting.
    # Here, handle message passing to both.
    empty_state = for _ <- 1..map_size(pl_map), do: 0
    sender = spawn(PL, :send_msgs, [id, pl_map, empty_state])
    receiver = spawn(PL, :receive_msg, [empty_state])
    handler_loop(sender, receiver)
  end

  defp handler_loop(sender, receiver) do
    receive do
      {:stop, app} ->
        send sender, {:stop, self()}
        send receiver, {:stop, self()}
        {send_state, receive_state} =
          {receive do
            {:send_state, state1} -> state1
          end, receive do
            {:receive_state, state2} -> state2
          end}
        send app, {:state, Enum.zip(send_state, receive_state)}
      {:send} ->
        send sender, {:send}
        handler_loop(sender, receiver)
      {:msg, id} ->
        send receiver, {:receive, id}
        handler_loop(sender, receiver)
    end
  end

  def send_msgs(id, pl_map, send_state) do
    receive do
      {:send} ->
        send_state = for i <- 0..map_size(pl_map) - 1 do
          pl = Map.get(pl_map, i)
          send pl, {:msg, id}
          Enum.at(send_state, i) + 1
        end
        send_msgs(id, pl_map, send_state)
      {:stop, host} -> send host, {:send_state, send_state}
    end
  end

  def receive_msg(receive_state) do
    receive do
      {:receive, id} ->
        receive_msg(List.replace_at(receive_state, id,
          Enum.at(receive_state, id) + 1))
      {:stop, host} -> send host, {:receive_state, receive_state}
    end
  end

end
