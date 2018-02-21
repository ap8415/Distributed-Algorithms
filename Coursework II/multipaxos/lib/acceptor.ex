# Andrei-Bogdan Puiu (ap8415) and Maurizio Zen (mz4715)

defmodule Acceptor do

  def start _ do
    # -1 is used instead of the symbol in the paper
    # for the initial value of a ballot
    next -1, MapSet.new()
  end

  defp next ballot_num, accepted do
    receive do
      {:phase_1a, leader, b} ->
        ballot_num = if DAC.compare_ballots(b, ballot_num) > 0, do: b, else: ballot_num
        send leader, {:phase_1b, self(), ballot_num, accepted}
        next ballot_num, accepted
      {:phase_2a, leader, {b, slot, command}} ->
        accepted = if DAC.compare_ballots(b, ballot_num) > 0 do
          MapSet.put accepted, {b, slot, command}
        else
          accepted
        end
        send leader, {:phase_2b, self(), ballot_num}
        next ballot_num, accepted
    end
  end
end
