# Andrei-Bogdan Puiu (ap8415) and Maurizio Zen (mz4715)

defmodule Leader do

  def start config, monitor do
    active = false
    ballot_num = {0, self()}
    proposals = %{}

    {acceptors, replicas} = receive do
      {:bind, acceptors, replicas} -> {acceptors, replicas}
    end

    send monitor, {:new_scout, config.server_num}
    spawn(Scout, :start, [self(), acceptors, ballot_num])
    next config, proposals, active, ballot_num, acceptors, replicas, monitor
  end

  defp next config, proposals, active, ballot_num, acceptors, replicas, monitor do
    receive do
      {:propose, s, c} ->
        proposals = if proposals[s] == nil do
          if active do
            send monitor, {:new_commander, config.server_num}
            spawn(Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}])
          end
          Map.put(proposals, s, c)
        else
          proposals
        end
        next config, proposals, active, ballot_num, acceptors, replicas, monitor
      {:adopted, ballot_num, pvals} ->
        proposals = update(proposals, pvals)
        for {s, c} <- proposals do
          send monitor, {:new_commander, config.server_num}
          spawn(Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}])
        end
        active = true
        next config, proposals, active, ballot_num, acceptors, replicas, monitor
      {:preempted, b} ->
        # If preempted by another ballot, the leader sleeps for a random
        # amount of time to let a consensus happen.
        Process.sleep(:rand.uniform(100))
        if (DAC.compare_ballots(b, ballot_num) > 0) do
          {r, _} = b
          ballot_num = {r + 1, self()}
          send monitor, {:new_scout, config.server_num}
          spawn(Scout, :start, [self(), acceptors, ballot_num])
          next config, proposals, false, ballot_num, acceptors, replicas, monitor
        else
          next config, proposals, active, ballot_num, acceptors, replicas, monitor
        end
    end
  end

  defp update proposals, pvals do
    pvals = pmax(pvals)

    Enum.reduce(proposals, pvals,
      fn({slot, command}, pvalues) ->
        pvalues = if pvalues[slot] == nil do
          Map.put(pvalues, slot, command)
        else
          pvalues
        end
        pvalues
      end)
  end

  defp pmax pvals do
    IO.puts MapSet.size pvals
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
    Map.new(Enum.map(pvals, fn({_, s, c}) -> {s, c} end))
  end

end
