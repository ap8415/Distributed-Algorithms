defmodule Client do

  def start peer_id do
    receive do
      {:bind, peers} -> next(peer_id, peers)
    end
  end

  defp next(peer_id, peers) do
    receive do
      {:broadcast, timeout, max_broadcasts} ->
        end_time = :os.system_time(:milli_seconds) + timeout
        start_broadcast(peer_id, peers, end_time, max_broadcasts)
    end
  end

  # The broadcast strategy used is to split each client into two threads;
  # the original one for receiving, and a new one for sending messages.
  defp start_broadcast(peer_id, neighbours, end_time, max_broadcasts) do
    send_state = for _ <- 1..length(neighbours), do: 0
    receive_state = for _ <- 1..length(neighbours), do: 0
    spawn(Client, :send_client,
            [peer_id, neighbours, end_time, max_broadcasts, self(), send_state])
    receive_client(peer_id, receive_state, end_time)
  end

  def send_client(peer_id, neighbours, end_time, broadcasts_left, main_peer, send_state) do
    if (broadcasts_left == 0 or :os.system_time(:milli_seconds) > end_time) do
      send main_peer, {:sends_finished, send_state}
    else
      send_state = for i <- 0..length(neighbours)-1 do
        peer = Enum.at(neighbours, i)
        send peer, {:msg, peer_id}
        Enum.at(send_state, i) + 1
      end
      send_client(peer_id, neighbours, end_time, broadcasts_left - 1, main_peer, send_state)
    end
  end

  defp receive_client(peer_id, receive_state, end_time) do
    receive_state = receive do
      {:msg, id} ->
        List.replace_at(receive_state, id, Enum.at(receive_state, id) + 1)
    after
      # If nothing arrives in 10ms, then we timeout the receive to avoid
      # situations when system timeout is reached, but the peer is stuck
      # in the receive, waiting for non-existent new messages.
      10 -> receive_state
    end
    if (:os.system_time(:milli_seconds) < end_time) do
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
