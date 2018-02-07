defmodule BEB do

  def start do
    receive do
      {:bind, app, lpl} ->
        receive do
          {:broadcast_data, processes, timeout} ->
            end_time = :os.system_time(:milli_seconds) + timeout
            next(processes, app, lpl, end_time)
        end
    end
  end

  def next(processes, app, lpl, end_time) do
    if (:os.system_time(:milli_seconds) > end_time) do
      await_timeout(app, lpl)
    else
      receive do
        {:beb_broadcast} ->
          for i <- 0..processes - 1 do
            send lpl, {:lpl_send, i}
          end
        {:lpl_deliver, from} ->
            send app, {:beb_deliver, from}
        {:timeout} -> timeout(app, lpl)
      end
      next processes, app, lpl, end_time
    end
  end

  def await_timeout(app, lpl) do
    receive do
      {:timeout} -> timeout(app, lpl)
    end
  end

  def timeout(app, lpl) do
    send lpl, {:timeout}
    receive do
      {:send_state, send_state} -> send app, {:send_state, send_state}
    end
  end

end
