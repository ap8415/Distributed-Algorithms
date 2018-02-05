defmodule Peer do

  def start id, timeout, max_broadcasts, system do
    # Initialize App component and PL component
    # Send PL component back to system2
    # Await for return of all PL's
    # Send them to its PL; bind PL and App
    pl_component = spawn(PL, :start, [id])
    send system, {:pl, id, pl_component}
    receive do
      {:all_pls, pl_map} ->
        send pl_component, {:all_pls, pl_map}
        App.start(pl_component, timeout, max_broadcasts)
    end
  end

end
