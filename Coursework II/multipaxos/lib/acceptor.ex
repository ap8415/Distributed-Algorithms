defmodule Acceptor do

  def start config do
    # Initial ballot num is placeholder
    next -1, []
  end

  defp next ballot_num, accepted do
    receive do
      {:phase_1a, leader, b} ->
        ballot_num = if DAC.compare_ballots(b, ballot_num) > 0, do: b, else: ballot_num
        send leader, {:phase_1b, self(), ballot_num, accepted}
        next ballot_num, accepted
      {:phase_2a, leader, {b, slot, command}} ->
        accepted = if DAC.compare_ballots(b, ballot_num) > 0 do
          [{b, slot, command} | accepted]
        else
          accepted
        end
        send leader, {:phase_2b, self(), ballot_num}
        next ballot_num, accepted
    end
  end
end
