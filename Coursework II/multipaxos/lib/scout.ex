defmodule Scout do

  def start leader, acceptors, ballot_num do
    for a <- acceptors, do: send a, {:phase_1a, self(), ballot_num}
    next(leader, MapSet.new(acceptors), length(acceptors), MapSet.new(), ballot_num)
  end

  defp next leader, waitfor, no_of_acceptors, pvalues, ballot_num do
    receive do
      {:phase_1b, acceptor, b, accepted} ->
        if (DAC.compare_ballots(ballot_num, b) == 0) do
          pvalues = Enum.into(accepted, pvalues)
          waitfor = MapSet.delete(waitfor, acceptor)
          if (MapSet.size(waitfor) < no_of_acceptors / 2) do
            send leader, {:adopted, b, pvalues}
          else
            next leader, waitfor, no_of_acceptors, pvalues, ballot_num
          end
        else
          send leader, {:preempted, b}
        end
    end
  end

end
