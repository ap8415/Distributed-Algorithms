defmodule Leader do

  def start _ do
    active = false
    ballot_num = {0, self()}
    proposals = []

    {acceptors, replicas} = receive do
      {:bind, acceptors, replicas} -> {acceptors, replicas}
    end

    spawn(Scout, :start, [self(), acceptors, ballot_num])
    next proposals, active, ballot_num, acceptors, replicas
  end

  defp next proposals, active, ballot_num, acceptors, replicas do
    receive do
      {:propose, s, c} ->
        proposals = if length(Enum.filter(proposals, fn({s1, c1}) -> s1 == s end)) == 0 do
          if active do
            spawn(Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}])
          end
          [{s, c} | proposals]
        else
          proposals
        end
        next proposals, active, ballot_num, acceptors, replicas
      {:adopted, ballot_num, pvals} ->
        proposals = update(proposals, pvals)
        for {s, c} <- proposals do
          spawn(Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}])
        end
        active = true
        next proposals, active, ballot_num, acceptors, replicas
      {:preempted, b} ->
        if (DAC.compare_ballots(b, ballot_num) >= 0) do
          {r, l} = b
          ballot_num = {r + 1, self()}
          spawn(Scout, :start, [self(), acceptors, ballot_num])
          next proposals, false, ballot_num, acceptors, replicas
        else
          next proposals, active, ballot_num, acceptors, replicas
        end
    end
  end

  defp update proposals, pvals do
    pvals = pmax(pvals)
    proposals = Enum.filter(
      proposals,
      fn({s, c}) -> (length(Enum.filter(pvals, fn({s1, c1}) -> s == s1 end)) == 0) end
    )
  end

  defp pmax pvals do
    pvals = Enum.filter(
      pvals,
      fn({b, s, c}) ->
        List.foldl(
          Enum.map(pvals, fn({b1, s1, c1}) ->
            (if (s1 == s), do: b1 <= b, else: true) end),
          true,
          fn(x, acc) -> x and acc end
        ) end
      )
    pvals = Enum.map(pvals, fn({b, s, c}) -> {s, c} end)

  end



end
