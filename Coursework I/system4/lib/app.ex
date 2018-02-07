# Andrei-Bogdan Puiu (ap8415)
defmodule App do

  def start id do
    receive do
      {:bind_beb, beb} -> await_system_request(id, beb)
    end
  end

  defp await_system_request(id, beb) do
    receive do
      {:broadcast_data, no_of_peers, timeout, max_broadcasts} ->
        end_time = :os.system_time(:milli_seconds) + timeout
        :timer.send_after(timeout, {:timeout})
        # Create process to initiate max_broadcasts broadcasts.
        spawn(App, :send_client, [beb, max_broadcasts])
        empty_state = for _ <- 1..no_of_peers, do: 0
        receive_client(id, empty_state, end_time, beb)
    end
  end

  def send_client(beb, broadcasts_left) do
    if (broadcasts_left > 0) do
      send beb, {:beb_broadcast}
      send_client(beb, broadcasts_left - 1)
    end
  end

  def receive_client(id, receive_state, end_time, beb) do
    {receive_state, timed_out} = receive do
      {:beb_deliver, from} ->
        {List.replace_at(receive_state, from, Enum.at(receive_state, from) + 1), false}
      {:timeout} -> {receive_state, true}
    end
    if (:os.system_time(:milli_seconds) < end_time and !timed_out) do
      receive_client(id, receive_state, end_time, beb)
    else
      send beb, {:timeout}
      send_state = get_send_state()
      output_peer(id, send_state, receive_state)
    end
  end

  # Helper functions

  defp get_send_state() do
    receive do
      {:send_state, final_send_state} -> final_send_state
    end
  end

  defp output_peer(id, send_state, receive_state) do
    IO.puts ("#{id}: #{inspect(Enum.zip(send_state, receive_state))}")
  end

end
