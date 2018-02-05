defmodule App do

  def start(pl_component) do
    for _ <- 1..100 do
      send pl_component, {:send}
    end
    send pl_component, {:stop, self()}
    IO.puts "finished 1"
    receive do
      {:state, contents} -> IO.puts inspect(contents)
    end
    IO.puts "finished 2"
  end

end
