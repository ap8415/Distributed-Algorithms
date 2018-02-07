# Andrei-Bogdan Puiu (ap8415)
defmodule PL do

  def start id do
    receive do
      {:all_pls, pl_map} -> bind_app(id, pl_map)
    end
  end

  defp bind_app(id, pl_map) do
    receive do
      {:bind_app, app} -> next id, pl_map, app
    end
  end

  defp next(self_id, pl_map, app) do
    receive do
      {:pl_send, id} ->
        send Map.get(pl_map, id), {:message, self_id}
      {:message, id} ->
        send app, {:pl_deliver, id}
    end
    next(self_id, pl_map, app)
  end

end
