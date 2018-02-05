defmodule Main do

  def main do
    spawn(Server, :start, [])
    :timer.sleep(1000)
  end

end
