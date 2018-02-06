defmodule Testsys do

  def start do
    proc = spawn(Testsys, :dracula, [])
    for i <- 1..100, do: spawn(Testsys, :flooder, [proc, i])

  end

  def flooder proc,i do
    if (i==1) do
      flooder2(proc)
    else
      flooder1(proc)
    end
  end

  def flooder1 proc do
    send proc, {:pula}
    flooder1(proc)
  end

  def flooder2 proc do
    send proc, {:pizda}
    flooder2(proc)
  end

  def dracula do
    receive do
      {:pizda} -> IO.puts "TU SUGI PULA"
      {:pula} -> IO.puts "EU SUG SANGE"
    end
    dracula()
  end


end
