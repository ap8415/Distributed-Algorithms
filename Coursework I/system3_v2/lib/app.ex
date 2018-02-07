defmodule App do

  def receive_fn id do
    {no_of_peers, timeout} = receive do
      {:broadcast_data, no_of_peers, timeout} -> {no_of_peers, timeout}
    end

    end_time = timeout + :os.system_time(:milli_seconds)
    empty_state = for _ <- 1..no_of_peers, do: 0
    receive_next(empty_state, end_time, id)
  end

  def receive_next(receive_state, end_time, id) do
    if (:os.system_time(:milli_seconds) > end_time) do
      receive do
        {:timeout, send_state} -> output_peer(id, send_state, receive_state)
      end
    else
      receive do
      {:beb_deliver, from} ->
        receive_next(
          List.replace_at(
            receive_state, from,
            Enum.at(receive_state, from) + 1),
          end_time,
          id)
      {:timeout, send_state} ->
        output_peer(id, send_state, receive_state)
      end
    end
  end

  def send_fn send_beb do
    max_broadcasts = receive do
      {:broadcast_data, max_broadcasts} -> max_broadcasts
    end
    send_next(send_beb, max_broadcasts)
  end

  def send_next(beb, broadcasts_left) do
    if (broadcasts_left > 0) do
      send beb, {:beb_broadcast}
      send_next(beb, broadcasts_left - 1)
    end
  end

  defp output_peer(id, send_state, receive_state) do
    IO.puts ("#{id}: #{inspect(Enum.zip(send_state, receive_state))}")
  end

end
