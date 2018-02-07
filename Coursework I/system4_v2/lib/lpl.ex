defmodule LPL do

  def receive_fn receive_beb do
    timeout = receive do
      {:metadata, timeout} -> timeout
    end

    end_time = timeout + :os.system_time(:milli_seconds)
    next_receive(receive_beb, end_time)
  end

  def next_receive(beb, end_time) do
    if (:os.system_time(:milli_seconds) > end_time) do
      receive do
        {:timeout, send_state} -> send beb, {:timeout, send_state}
      end
    else
      receive do
        {:message, id} ->
          send beb, {:lpl_deliver, id}
          next_receive(beb, end_time)
        {:timeout, send_state} -> send beb, {:timeout, send_state}
      end
    end
  end

  def send_fn receive_lpl do
    {lpl_map, timeout} = receive do
      {:metadata, lpl_map, timeout} -> {lpl_map, timeout}
    end

    reliability = 20 # number from 0 to 100
    end_time = timeout + :os.system_time(:milli_seconds)
    :timer.send_after(timeout, {:timeout})
    empty_state = for _ <- 1..map_size(lpl_map), do: 0
    next_send(empty_state, lpl_map, end_time, receive_lpl, reliability)
  end

  def next_send(send_state, lpl_map, end_time, receive_lpl, reliability) do
    if (:os.system_time(:milli_seconds) > end_time) do
      send receive_lpl, {:timeout, send_state}
    else
      receive do
        {:lpl_send, to, from} ->
          if (goes_through(reliability)) do
            send Map.get(lpl_map, to), {:message, from}
          end
          new_state = List.replace_at(send_state, to, Enum.at(send_state, to) + 1)
          next_send(new_state, lpl_map, end_time, receive_lpl, reliability)
        {:timeout} -> send receive_lpl, {:timeout, send_state}
      end
    end
  end

  defp goes_through(reliability) do
    reliability <= :rand.uniform(100)
  end

end
