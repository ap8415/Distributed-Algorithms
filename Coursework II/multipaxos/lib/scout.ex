defmodule Scout do

  def start leader, acceptors, ballot_num do
    for a <- acceptors, do: send a, {:phase_1a, self(), ballot_num}
    next(leader, MapSet.new(acceptors), length(acceptors), [], ballot_num)
  end

  defp next leader, waitfor, acceptors_no, pvalues, ballot_num do
    receive do
      {:phase_1b, acceptor, b, accepted} ->
        if (compare_ballots(ballot_num,b) == 0) do
          pvalues = [accepted | pvalues]
          waitfor = MapSet.delete(waitfor, acceptor)
          if (MapSet.size(waitfor) < acceptors_no / 2) do
            send leader, {:adopted, b, pvalues}
          else
            next leader, waitfor, acceptors_no, pvalues, ballot_num
          end
        else
          send leader, {:preempted, b}
        end
    end
  end

end
