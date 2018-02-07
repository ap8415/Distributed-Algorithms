defmodule BEB do

  def receive_fn receive_app do
    timeout = receive do
      {:metadata, timeout} -> timeout
    end

    end_time = timeout + :os.system_time(:milli_seconds)
    receive_next(receive_app, end_time)
  end

  def receive_next(app, end_time) do
    if (:os.system_time(:milli_seconds) > end_time) do
      await_timeout(app)
    else
      receive do
        {:lpl_deliver, from} -> send app, {:beb_deliver, from}
        {:timeout, send_state} -> send app, {:timeout, send_state}
      end
      receive_next(app, end_time)
    end
  end

  def await_timeout(app) do
    receive do
      {:timeout, send_state} -> send app, {:timeout, send_state}
    end
  end

  def send_fn id, send_lpl do
    no_of_peers = receive do
      {:metadata, no_of_peers} -> no_of_peers
    end
    next_send(id, send_lpl, no_of_peers)
  end

  def next_send(id, lpl, no_of_peers) do
    receive do
      {:beb_broadcast} ->
        for i <- 1..no_of_peers do
          send lpl, {:lpl_send, i-1, id}
        end
    end
    next_send(id, lpl, no_of_peers)
  end

end
