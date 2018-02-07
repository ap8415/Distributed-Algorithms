# Andrei-Bogdan Puiu (ap8415)
defmodule Peer do

  def start id, system do
    # Initialize App component and PL component
    # Send PL component back to system2
    # Await for return of all PL's
    # Send them to its PL; bind PL and App
    pl = spawn(PL, :start, [id])
    send system, {:pl, id, pl}
    {timeout, max_broadcasts} = receive do
      {:broadcast, t_out, max_b} -> {t_out, max_b}
    end
    receive do
      {:all_pls, pl_map} ->
        send pl, {:all_pls, pl_map}
        App.start(id, pl, map_size(pl_map), timeout, max_broadcasts)
    end
  end

end
