defmodule Commander do

  def start leader, acceptors, replicas, command do
    for a <- acceptors, do: send a, {:phase_2a, self(), command}
    next(leader, MapSet.new(acceptors), length(acceptors), replicas, command)
  end

  defp next leader, waitfor, acceptors_no, replicas, command do
    receive do
      {:phase_2b, acceptor, ballot_num} ->
        {b, s, c} = command
        if (DAC.compare_ballots(ballot_num, b) == 0) do
          waitfor = MapSet.delete(waitfor, acceptor)
          if (MapSet.size(waitfor) < acceptors_no / 2) do
            for r <- replicas, do: send r, {:decision, s, c}
          else
            next(leader, waitfor, acceptors_no, replicas, command)
          end
        else
          send leader, {:preempted, b}
        end
    end
  end

end
