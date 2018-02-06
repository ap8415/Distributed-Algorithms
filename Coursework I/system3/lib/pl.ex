defmodule PL do

  def start id do
    receive do
      {:metadata, pl_map, timeout} -> bind_beb(id, pl_map, timeout)
    end
  end

  defp bind_beb(id, pl_map, timeout) do
    receive do
      {:bind_beb, beb} ->
        empty_state = for _ <- 1..map_size(pl_map), do: 0
        end_time = :os.system_time(:milli_seconds) + timeout
        next(id, pl_map, beb, empty_state, end_time)
    end
  end

  defp next(self_id, pl_map, beb, send_state, end_time) do
    if (:os.system_time(:milli_seconds) > end_time) do
      await_timeout(beb, send_state)
    else
      send_state = receive do
        {:pl_send, id} ->
          send Map.get(pl_map, id), {:message, self_id}
          List.replace_at(send_state, id, Enum.at(send_state, id) + 1)
        {:message, id} ->
          send beb, {:pl_deliver, id}
          send_state
        {:timeout} ->
          timeout(beb, send_state)
      end
      next(self_id, pl_map, beb, send_state, end_time)
    end
  end

  defp await_timeout(beb, send_state) do
    receive do
      {:timeout} -> timeout(beb, send_state)
    end
  end

  defp timeout(beb, send_state) do
    send beb, {:send_state, send_state}
  end

end
