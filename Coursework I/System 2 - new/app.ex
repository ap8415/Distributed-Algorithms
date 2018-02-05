defmodule App do

  def start(pl_component, timeout, max_broadcasts) do
    finish_time = :os.system_time(:milli_seconds) + timeout
    send pl_component, {:timeout, finish_time, self()}
    for _ <- 1..max_broadcasts do
      send pl_component, {:send}
    end
    :timer.sleep(timeout)
    send pl_component, {:stop, self()}
    IO.puts "finished 1"
    receive do
      {:state, contents} -> IO.puts inspect(contents)
    end
    IO.puts "finished 2"
  end
end
