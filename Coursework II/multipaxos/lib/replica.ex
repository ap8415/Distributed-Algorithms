defmodule Replica do

  def start _, database, _ do
    receive do {:bind, leaders} -> next database, leaders, 1, 1, [], %{}, [] end
  end

  def next database, leaders, slot_in, slot_out, requests, proposals, decisions do
    receive do
      {:request, command} ->
        propose(database, leaders, slot_in, slot_out, [command | requests], proposals, decisions)
      {:decision, slot, c} ->
        decisions = [{slot, c} | decisions]
        {slot_out, proposals, requests}
          = decision_loop(decisions, slot_out, proposals, requests, database)
        next(database, leaders, slot_in, slot_out, requests, proposals, decisions)
    end
  end

  def decision_loop(decisions, slot_out, proposals, requests, db) do
    if (length(decisions) == 0) do
      {slot_out, proposals, requests}
    else
      [d | remaining] = decisions
      {slot, c_1} = d
      {s_out, prop, req} =
        if (slot == slot_out) do
          {c_2, proposals} = Map.pop(proposals, slot_out)
          requests = if (c_2 != nil and c_2 != c_1) do
            [c_2 | requests]
          else
            requests
          end
          perform(c_1, db, decisions, slot_out)
          decision_loop(remaining, slot_out + 1, proposals, requests, db)
        else
          decision_loop(remaining, slot_out, proposals, requests, db)
        end
    end
  end

  def perform({client, cid, op}, db, decisions, slot_out) do
    decision = {client, cid, op}
    {s, _} = Enum.find(decisions, {nil, nil}, fn({s, d}) -> s < slot_out and d == decision end)
    if (s == nil) do
      result = execute(op, db)
      send client, {:reply, cid, result}
    end
  end

  # Assumes only move commands are implemented.
  def execute(op, db) do
    send db, {:execute, op, self()}
    receive do
      {:db_result, result} -> result
    end
  end

  def propose database, leaders, slot_in, slot_out, requests, proposals, decisions do
    if (slot_in < slot_out + DAC.window and length(requests) > 0) do
      {_, {_, _, op}} = Enum.find(decisions, {nil, {nil, nil, nil}},
          fn({s, _}) -> s == slot_in - DAC.window end)
      if is_reconfig(op) do
        update_leaders()
      end
      proposals = if Enum.find(decisions, fn({s, _}) -> s == slot_in end) == nil do
        [command | requests] = requests
        proposals = Map.put(proposals, slot_in, command)
        for leader <- leaders do
          send leader, {:propose, slot_in, command}
        end
        proposals
      else
        proposals
      end
      propose(database, leaders, slot_in + 1, slot_out, requests, proposals, decisions)
    else
      next(database, leaders, slot_in, slot_out, requests, proposals, decisions)
    end
  end

  def is_reconfig(operation) do
    false
  end

  def update_leaders do

  end

end
