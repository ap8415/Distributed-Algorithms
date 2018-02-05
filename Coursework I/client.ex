defmodule Client do

  def start index do
    receive do
      {:bind, peers} ->
        state = for _ <- peers, do: {0, 0}
        next peers, index, List.to_tuple(state), 100
    end
  end

  def next_send peers, index, state, ctr do
    if (ctr > 0) do
      i = 0
      for p <- peers do
         send p, {:msg, index}
         state = increment(state, i, 0)
         IO.puts inspect(state)
         i = i + 1
      end
      next peers, index, state, ctr-1
    else
      IO.puts inspect(state)
    end
  end

  def next peers, index, state, ctr do
    if (ctr > 0) do
      i = 0
      for p <- peers do
         send p, {:msg, index}
         state = increment(state, i, 0)
         IO.puts inspect(state)
         i = i + 1
       end
      for p <- peers do
        receive do
          {:msg, index} ->
            state = increment(state, index, 1)
            IO.puts inspect(state)
        end
      end
      next peers, index, state, ctr-1
    else
      IO.puts inspect(state)
    end
  end

  def increment state, index, pos do
    v = elem(state, index)
    v2 = put_elem(v, pos, elem(v, pos) + 1)
    put_elem(state, index, v2)
  end

end
