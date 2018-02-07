# Andrei-Bogdan Puiu (ap8415)
defmodule LPL do

  def start id, reliability do
    receive do
      {:broadcast_data, lpl_map, timeout} -> bind_beb(id, lpl_map, timeout, reliability)
    end
  end

  defp bind_beb(id, lpl_map, timeout, reliability) do
    receive do
      {:bind_beb, beb} ->
        empty_state = for _ <- 1..map_size(lpl_map), do: 0
        end_time = :os.system_time(:milli_seconds) + timeout
        next(id, lpl_map, beb, empty_state, end_time, reliability)
    end
  end

  defp next(self_id, lpl_map, beb, send_state, end_time, reliability) do
    if (:os.system_time(:milli_seconds) > end_time) do
      await_timeout(beb, send_state)
    else
      send_state = receive do
        {:lpl_send, id} ->
          if (goes_through(reliability)) do
            send Map.get(lpl_map, id), {:message, self_id}
          end
          List.replace_at(send_state, id, Enum.at(send_state, id) + 1)
        {:message, id} ->
          send beb, {:lpl_deliver, id}
          send_state
        {:timeout} ->
          timeout(beb, send_state)
      end
      next(self_id, lpl_map, beb, send_state, end_time, reliability)
    end
  end

  defp await_timeout(beb, send_state) do
    receive do
      {:timeout} -> timeout(beb, send_state)
    end
  end

  defp goes_through(reliability) do
    reliability >= :rand.uniform(100)
  end

  defp timeout(beb, send_state) do
    send beb, {:send_state, send_state}
  end

end
