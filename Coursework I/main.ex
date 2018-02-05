defmodule Main do

  def main do
    spawn(Server, :start, [])
    :timer.sleep(10000)
  end

end
