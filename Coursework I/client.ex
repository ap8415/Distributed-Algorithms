defmodule Client do

  def start peer_id do
    receive do
      {:bind, peers} -> start_broadcast(peers, peer_id)
    end
  end

  def send_client(neighbours, number_of_broadcasts, peer_id, main_peer, send_state) do
    send_state = for i <- 0..length(neighbours)-1 do
      peer = Enum.at(neighbours, i)
      send peer, {:msg, peer_id}
      Enum.at(send_state, i) + 1
    end

    if (number_of_broadcasts > 0) do
      send_client(neighbours, number_of_broadcasts - 1, peer_id, main_peer, send_state)
    else
      send main_peer, {:sends_finished, send_state}
    end
  end

  defp start_broadcast(neighbours, peer_id) do
    send_state = for _ <- 1..length(neighbours), do: 0
    receive_state = for _ <- 1..length(neighbours), do: 0
    spawn(Client, :send_client, [neighbours, 1000, peer_id, self(), send_state])
    receive_client(peer_id, send_state, receive_state, 5000, false)
  end

  defp receive_client(peer_id, send_state, receive_state, count, sends_finished) do
    {send_state, receive_state, sends_finished} = receive do
      {:sends_finished, final_send_state} ->
        {final_send_state, receive_state, true}
      {:msg, sender_id} ->
        {send_state, List.replace_at(receive_state, sender_id,
          Enum.at(receive_state, sender_id) + 1), sends_finished}
    end
    if (count > 0 or !sends_finished) do
      receive_client(peer_id, send_state, receive_state, count - 1, sends_finished)
    else
      IO.puts inspect(Enum.zip(send_state, receive_state))
    end
  end

end
