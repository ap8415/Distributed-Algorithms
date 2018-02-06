defmodule App do

  def start(pl, timeout, max_broadcasts) do
    finish_time = :os.system_time(:milli_seconds) + timeout
    send pl, {:bind_app, self()}

  end


end
