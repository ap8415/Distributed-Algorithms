defmodule BEB do

  def start do
    receive do
      {:bind, app, pl} ->
        receive do
          {:broadcast_data, processes, timeout} ->
            end_time = :os.system_time(:milli_seconds) + timeout
            next(processes, app, pl, end_time)
        end
    end
  end

  def next(processes, app, pl, end_time) do
    if (:os.system_time(:milli_seconds) > end_time) do
      await_timeout(app, pl)
    else
      receive do
        {:beb_broadcast} ->
          for i <- 0..processes - 1 do
            send pl, {:pl_send, i}
          end
        {:pl_deliver, from} ->
            send app, {:beb_deliver, from}
        {:timeout} -> timeout(app, pl)
      end
      next processes, app, pl, end_time
    end
  end

  def await_timeout(app, pl) do
    receive do
      {:timeout} -> timeout(app, pl)
    end
  end

  def timeout(app, pl) do
    send pl, {:timeout}
    receive do
      {:send_state, send_state} -> send app, {:send_state, send_state}
    end
  end

end
