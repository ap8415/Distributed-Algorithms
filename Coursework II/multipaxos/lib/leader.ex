defmodule Leader do

  def start acceptors, replicas do
    active = false
    ballot_num = (0, self())
    proposals = []

    {acceptors, replicas} receive do
      {:bind, acceptors, replicas} -> {acceptors, replicas}
    end

    spawn(Scout, :start, [self(), acceptors, ballot_num])
    next proposals, active, ballot_num, acceptors, replicas
  end

  defp next proposals, active, ballot_num, acceptors, replicas do
    receive do
      {:propose, s, c} ->
        proposals = if length(filter(proposals, {s1, c1} -> s1 == s)) == 0 do
          if active do
            spawn(Commander, :start, [self(), acceptors, replicas, {ballot_num, s, c}])
          end
          [{s, c} | proposals]
        else
          proposals
        end
        next proposals, active, ballot_num, acceptors, replicas
      {:adopted, ballot_num, pvals} ->
        # TODO this
      {:preempted, b} ->
        if compare_ballots(b, ballot_num) > 0 do
          {r, l} = b
          ballot_num = {r + 1, self()}
          spawn(Scout, :start, [self(), acceptors, ballot_num])
          next proposals, false, ballot_num, acceptors, replicas
        else
          next proposals, active, ballot_num, acceptors, replicas
        end
    end
  end



end
