defmodule PLP_Process do

  def start peer_id do
    receive do
      {:bind, plp_neighbours} -> next peer_id, plp_neighbours
    end
  end

  def next peer_id, plp_neighbours

end
