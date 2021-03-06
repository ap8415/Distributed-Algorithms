# Andrei-Bogdan Puiu (ap8415) and Maurizio Zen (mz4715)
defmodule Replica do

  def start config, database, monitor do
    receive do {:bind, leaders} -> next config, database, leaders, 1, 1, [], %{}, %{}, monitor end
  end

  def next config, database, leaders, slot_in, slot_out, requests, proposals, decisions, monitor do
    receive do
      {:request, command} ->
        # We log when requests arrive to the replica.
        # It takes time for them to be sent to the leader.
        send monitor, {:client_request, config.server_num}

        propose(config, database, leaders, slot_in, slot_out, [command | requests], proposals, decisions, monitor)
      {:decision, slot, c} ->
        decisions = Map.put(decisions, slot, c)

        {slot_out, proposals, requests}
          = decision_loop(decisions, slot_out, proposals, requests, database)

        next(config, database, leaders, slot_in, slot_out, requests, proposals, decisions, monitor)
      after 10 ->
        # When the slot window (defined at DAC.window) is small (which should
        # usually be the case), all {:request, cmd} messages are received by
        # the replica, but the replica hasn't yet proposed them all to leader.
        #
        # If that happens, this after clause makes sure that the replica can
        # keep calling 'propose' until the request list is empty.
        propose(config, database, leaders, slot_in, slot_out, requests, proposals, decisions, monitor)
    end
  end

  def propose config, database, leaders, slot_in, slot_out, requests, proposals, decisions, monitor do
    if (slot_in < slot_out + config.window and length(requests) > 0) do
      #{_, {_, _, op}} = Enum.find(decisions, {nil, {nil, nil, nil}},
    #      fn({s, _}) -> s == slot_in - config.window end)

    #  if is_reconfig(op) do
  #      update_leaders()
  #    end

      {requests, proposals} = if Map.get(decisions, slot_in) == nil do
        [command | requests] = requests
        proposals = Map.put(proposals, slot_in, command)
        for leader <- leaders do
          send leader, {:propose, slot_in, command}
        end
        {requests, proposals}
      else
        {requests, proposals}
      end
      propose(config, database, leaders, slot_in + 1, slot_out, requests, proposals, decisions, monitor)
    else
      next(config, database, leaders, slot_in, slot_out, requests, proposals, decisions, monitor)
    end
  end

  def decision_loop(decisions, slot_out, proposals, requests, db) do
    if decisions[slot_out] != nil do
      c_1 = decisions[slot_out]
      {c_2, proposals} = Map.pop(proposals, slot_out)
      requests = if (c_2 != nil and c_2 != c_1) do
        [c_2 | requests]
      else
        requests
      end
      perform(c_1, db, decisions, slot_out)
      decision_loop(decisions, slot_out + 1, proposals, requests, db)
    else
      {slot_out, proposals, requests}
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

  def is_reconfig(_) do
    false
  end

  def update_leaders do

  end

end
