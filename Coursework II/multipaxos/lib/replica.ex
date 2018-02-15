defmodule Replica do

  def start _, database, _ do
    receive do {:bind, leaders} -> next database, leaders, 1, 1, [], {}, [] end
  end

  def next database, leaders, slot_in, slot_out, requests, proposals, decisions do
    receive do
      {:client_request, {client, sent, transaction}} ->
        propose(database, leaders, slot_in, slot_out, [transaction | requests], proposals, decisions)
      {:leader_decision, slot, c} ->
        decisions = [{slot, c} | decisions]
        for d <- decisions do
          {slot, c_1} = d
          if (slot == slot_out) do
            {c_2, proposals} = Map.pop(proposals, slot_out)
            if (c_2 != nil) do
              if (c_2 != c_1), do: requests = [c_2 | requests]
            end
            perform(c_1)
          end
        end
    end
  end

  def perform(c_1) do

  end

  def propose database, leaders, slot_in, slot_out, requests, proposals, decisions do
    if (slot_in < slot_out + DAC.window and length(requests) > 0) do
      if is_reconfig(slot_in - DAC.window) do
        update_leaders()
      end
      if no_decision_at(slot_in) do
        [r | requests] = requests
        proposals = Map.put(proposals, slot_in, r)
        for leader <- leaders do
          send leader, {:propose, slot_in, r}
        end
        propose(database, leaders, slot_in + 1, slot_out, requests, proposals, decisions)
      else
        propose(database, leaders, slot_in + 1, slot_out, requests, proposals, decisions)
      end
    else
      next(database, leaders, slot_in, slot_out, requests, proposals, decisions)
    end
  end

  def no_decision_at(number) do

  end

  def is_reconfig(number) do

  end

  def update_leaders do

  end

end
