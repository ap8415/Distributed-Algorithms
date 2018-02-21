# Andrei-Bogdan Puiu (ap8415) and Maurizio Zen (mz4715)

defmodule Leader do

  def start _ do
    active = false
    ballot_num = {0, self()}
    proposals = []

    {acceptors, replicas} = receive do
      {:bind, acceptors, replicas} -> {acceptors, replicas}
    end

    spawn(Scout, :start, [self(), acceptors, ballot_num])
    next proposals, active, ballot_num, acceptors, replicas, 0
  end

  defp next proposals, active, ballot_num, acceptors, replicas, spawned do
    receive do
      {:ping, other} -> send other, {:pong, self()}
      {:propose, s, c} ->
        {spawned, proposals} = if length(Enum.filter(proposals, fn({s1, _}) -> s1 == s end)) == 0 do
          spawned = if active do
            spawn(Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}])
            spawned + 1
          else
            spawned
          end
          {spawned, [{s, c} | proposals]}
        else
          {spawned, proposals}
        end
        next proposals, active, ballot_num, acceptors, replicas, spawned
      {:adopted, ballot_num, pvals} ->
        proposals = update(proposals, pvals)
        for {s, c} <- proposals do
          spawn(Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}])
        end
        active = true
        next proposals, active, ballot_num, acceptors, replicas, spawned + 1
      {:preempted, b} ->
        if (DAC.compare_ballots(b, ballot_num) > 0) do
          {r, l} = b
          ping(l)
          ballot_num = {r + 1, self()}
          spawn(Scout, :start, [self(), acceptors, ballot_num])
          next proposals, false, ballot_num, acceptors, replicas, spawned
        else
          next proposals, active, ballot_num, acceptors, replicas, spawned
        end
    end
  end

  defp update proposals, pvals do
    pvals = pmax(pvals)
    Enum.filter(
      proposals,
      fn({s, _}) -> (length(Enum.filter(pvals, fn({s1, _}) -> s == s1 end)) == 0) end
    )
  end

  defp pmax pvals do
    pvals = Enum.filter(
      pvals,
      fn({b, s, _}) ->
        List.foldl(
          Enum.map(pvals, fn({b1, s1, _}) ->
            (if (s1 == s), do: b1 <= b, else: true) end),
          true,
          fn(x, acc) -> x and acc end
        ) end
      )
    Enum.map(pvals, fn({_, s, c}) -> {s, c} end)
  end

  defp ping other_leader do
    send other_leader, {:ping, self()}
    :timer.sleep(5)
    receive do
      {:pong, other_leader} -> ping other_leader
    after 5 -> "The leader goes on"
    end
  end

end
