# Andrei-Bogdan Puiu (ap8415)
defmodule PL do

  def start id do
    receive do
      {:broadcast_data, pl_map, timeout} -> bind_beb(id, pl_map, timeout)
    end
  end

  defp bind_beb(id, pl_map, timeout) do
    receive do
      {:bind_beb, beb} ->
        empty_state = for _ <- 1..map_size(pl_map), do: 0
        end_time = :os.system_time(:milli_seconds) + timeout
        sender = spawn(PL, :send_pl, [pl_map, id, empty_state, end_time])
        next(beb, end_time, sender)
    end
  end

  def send_pl(pl_map, id, send_state, end_time) do
    if (:os.system_time(:milli_seconds) > end_time) do
      receive do
        {:timeout, beb} -> send beb, {:send_state, send_state}
      end
    else
      receive do
        {:pl_send, from} ->
          send Map.get(pl_map, from), {:message, id}
          new_state = List.replace_at(send_state, from, Enum.at(send_state, from) + 1)
          send_pl(pl_map, id, new_state, end_time)
        {:timeout, beb} ->
          send beb, {:send_state, send_state}
      end
    end
  end

  defp next(beb, end_time, sender) do
    if (:os.system_time(:milli_seconds) > end_time) do
      await_timeout(beb, sender)
    else
      receive do
        {:message, id} ->
          send beb, {:pl_deliver, id}
        {:pl_send, id} ->
          send sender, {:pl_send, id}
        {:timeout} ->
          timeout(beb, sender)
      end
      next(beb, end_time, sender)
    end
  end

  defp await_timeout(beb, sender) do
    receive do
      {:timeout} -> timeout(beb, sender)
    end
  end

  defp timeout(beb, sender) do
    send sender, {:timeout, beb}
  end

end
