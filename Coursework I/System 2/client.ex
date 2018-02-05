defmodule Client do

  def start peer_id do
    receive do
      {:broadcast, timeout, max_broadcasts} ->
        end_time = :os.system_time(:milli_seconds) + timeout
        plp_process = spawn(PLP_Process, :start, [peer_id])
        start_broadcast(peer_id, end_time, max_broadcasts, plp_process)
    end
  end

  defp start_broadcast(peer_id, end_time, max_broadcasts, plp_process) do
    plp_peers_map = %{}
    for _ <- 1..5 do
      receive do
        {:plp_process, id, process} -> {id, process}
      end
    end
    # send_state = for _ <- 1..length(neighbours), do: 0
    # receive_state = for _ <- 1..length(neighbours), do: 0


  end

end

  # The broadcast strategy used is to split each client into two threads;
  # the original one for receiving, and a new one for sending messages.
#   defp start_broadcast(peer_id, neighbours, end_time, max_broadcasts) do
#     send_state = for _ <- 1..length(neighbours), do: 0
#     receive_state = for _ <- 1..length(neighbours), do: 0
#     spawn(Client, :send_client,
#             [peer_id, neighbours, end_time, max_broadcasts, self(), send_state])
#     receive_client(peer_id, send_state, receive_state, false,max_broadcasts * length(neighbours), end_time)
#   end
#
#   def send_client(peer_id, neighbours, end_time, broadcasts_left, main_peer, send_state) do
#     if (broadcasts_left == 0 or :os.system_time(:milli_seconds) > end_time) do
#       send main_peer, {:sends_finished, send_state}
#     else
#       send_state = for i <- 0..length(neighbours)-1 do
#         peer = Enum.at(neighbours, i)
#         send peer, {:msg, peer_id}
#         Enum.at(send_state, i) + 1
#       end
#       send_client(peer_id, neighbours, end_time, broadcasts_left - 1, main_peer, send_state)
#     end
#   end
#
#   defp receive_client(peer_id, send_state, receive_state, sends_finished, count, end_time) do
#     {send_state, receive_state, sends_finished} = receive do
#       {:sends_finished, final_send_state} ->
#         {final_send_state, receive_state, true}
#       {:msg, sender_id} ->
#         {send_state, List.replace_at(receive_state, sender_id,
#           Enum.at(receive_state, sender_id) + 1), sends_finished}
#     end
#     if (:os.system_time(:milli_seconds) < end_time and count > 0) do
#       receive_client(peer_id, send_state, receive_state, sends_finished, count - 1, end_time)
#     else
#       send_state = if sends_finished do
#         send_state
#       else
#         receive do
#           {:sends_finished, final_send_state} -> final_send_state
#         end
#       end
#       IO.puts ("#{peer_id}: #{inspect(Enum.zip(send_state, receive_state))}")
#     end
#   end
#
# end
