# Andrei-Bogdan Puiu (ap8415) and Maurizio Zen (mz4715)
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Monitor do

def start config do
  Process.send_after self(), :print, config.print_after
  next config, 0, Map.new, Map.new, Map.new, Map.new, Map.new
end # start

defp next config, clock, requests, updates, transactions, scouts, commanders do
  receive do
  { :db_update, db, seqnum, transaction } ->
    { :move, amount, from, to } = transaction

    done = Map.get updates, db, 0

    if seqnum != done + 1  do
      IO.puts "  ** error db #{db}: seq #{seqnum} expecting #{done+1}"
      System.halt
    end

    transactions =
      case Map.get transactions, seqnum do
      nil ->
        # IO.puts "db #{db} seq #{seqnum} #{done}"
        Map.put transactions, seqnum, %{ amount: amount, from: from, to: to }

      t -> # already logged - check transaction
        if amount != t.amount or from != t.from or to != t.to do
	  IO.puts " ** error db #{db}.#{done} [#{amount},#{from},#{to}] " <>
            "= log #{done}/#{Map.size transactions} [#{t.amount},#{t.from},#{t.to}]"
          System.halt
        end
        transactions
      end # case

    updates = Map.put updates, db, seqnum
    next config, clock, requests, updates, transactions, scouts, commanders

  { :client_request, server_num } ->  # requests by replica
    seen = Map.get requests, server_num, 0
    requests = Map.put requests, server_num, seen + 1
    next config, clock, requests, updates, transactions, scouts, commanders

  { :new_commander, server_num } ->   # commanders
    seen = Map.get commanders, server_num, 0
    commanders = Map.put commanders, server_num, seen + 1
    next config, clock, requests, updates, transactions, scouts, commanders

  { :new_scout, server_num } ->   # commanders
    seen = Map.get scouts, server_num, 0
    scouts = Map.put scouts, server_num, seen + 1
    next config, clock, requests, updates, transactions, scouts, commanders

  :print ->
    clock = clock + config.print_after
    sorted = updates |> Map.to_list |> List.keysort(0)
    IO.puts "time = #{clock}  updates done = #{inspect sorted}"
    sorted = requests |> Map.to_list |> List.keysort(0)
    IO.puts "time = #{clock} requests seen = #{inspect sorted}"
    sorted = scouts |> Map.to_list |> List.keysort(0)
    IO.puts "time = #{clock} scouts = #{inspect sorted}"
    sorted = commanders |> Map.to_list |> List.keysort(0)
    IO.puts "time = #{clock} commanders = #{inspect sorted}"
    IO.puts ""
    Process.send_after self(), :print, config.print_after
    next config, clock, requests, updates, transactions, scouts, commanders

  # ** ADD ADDITIONAL MESSAGES HERE

  _ ->
    IO.puts "monitor: unexpected message"
    System.halt
  end # receive
end # next

end # Monitor
