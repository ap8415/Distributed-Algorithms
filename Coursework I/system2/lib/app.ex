defmodule App do

  def start(id, pl, no_of_peers, timeout, max_broadcasts) do
    send pl, {:bind_app, self()}
    start_broadcast(id, pl, no_of_peers, timeout, max_broadcasts)
  end

  # The broadcast strategy used is to split each client into two threads;
  # the original one for receiving, and a new one for sending messages.
  defp start_broadcast(peer_id, pl, no_of_peers, timeout, max_broadcasts) do
    empty_state = for _ <- 1..no_of_peers, do: 0
    end_time = :os.system_time(:milli_seconds) + timeout
    :timer.send_after(timeout, {:timeout})
    spawn(App, :send_client,
            [peer_id, pl, no_of_peers, end_time, max_broadcasts, self(), empty_state])
    receive_client(peer_id, empty_state, end_time)
  end

  def send_client(peer_id, pl, no_of_peers, end_time, broadcasts_left, main_peer, send_state) do
    if (broadcasts_left == 0 or :os.system_time(:milli_seconds) > end_time) do
      send main_peer, {:sends_finished, send_state}
    else
      send_state = for i <- 0..no_of_peers - 1 do
        send pl, {:pl_send, i}
        Enum.at(send_state, i) + 1
      end
      send_client(peer_id, pl, no_of_peers, end_time, broadcasts_left - 1, main_peer, send_state)
    end
  end

  defp receive_client(peer_id, receive_state, end_time) do
    {receive_state, timed_out} = receive do
      {:pl_deliver, id} ->
        {List.replace_at(receive_state, id, Enum.at(receive_state, id) + 1), false}
      {:timeout} -> {receive_state, true}
    end
    if (:os.system_time(:milli_seconds) < end_time and !timed_out) do
      receive_client(peer_id, receive_state, end_time)
    else
      send_state = get_send_state()
      output_peer(peer_id, send_state, receive_state)
    end
  end

  # Helper functions

  defp get_send_state() do
    receive do
        {:sends_finished, final_send_state} -> final_send_state
    end
  end

  defp output_peer(peer_id, send_state, receive_state) do
    IO.puts ("#{peer_id}: #{inspect(Enum.zip(send_state, receive_state))}")
  end

end
