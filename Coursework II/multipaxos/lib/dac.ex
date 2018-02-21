# Andrei-Bogdan Puiu (ap8415) and Maurizio Zen (mz4715)
# distributed algorithms, n.dulay, 25 jan 18
# helper functions v2

defmodule DAC do

# ---------------------
def node_ip_addr do
  {:ok, interfaces} = :inet.getif()		# get interfaces
  {address, _gateway, _mask}  = hd interfaces	# get data for 1st interface
  {a, b, c, d} = address   			# get octets for address
  "#{a}.#{b}.#{c}.#{d}"
end

def lookup name do
  addresses = :inet_res.lookup name, :in, :a
  {a, b, c, d} = hd addresses   # get octets for 1st ipv4 address
  :"#{a}.#{b}.#{c}.#{d}"
end

# ---------------------
def node_name(:single,  _,   _), do: node() 	# return local elixir node
def node_name(:docker, name, n), do: :'#{name}#{n}@#{name}#{n}.localdomain'
def node_name(:ssh, _, _n),      do: System.halt 1  # omitted

def node_spawn node, module, function, args do
  if Node.connect node do
    Process.sleep 5   	# in case Node needs time to load modules
    Node.spawn node, module, function, args
  else
    Process.sleep 100	# retry in 100ms
    node_spawn node, module, function, args
  end
end

# ---------------------
def random(n),             do: Enum.random 1..n
def random_seed(n),        do: :rand.seed(:exsplus, {n, n, n})
def random_seed(a, b, c),  do: :rand.seed(:exsplus, {a, b, c})
def adler32(x),            do: :erlang.adler32(x)
def unzip3(triples),	     do: :lists.unzip3 triples
def window,                do: 10    # Window of slots for replica.

# ---------------------

def get_config do
  # get version of configuration given by 1st arg
  config = Configuration.version String.to_integer(Enum.at System.argv, 0)

  # add type of setup (single | docker | ssh)
  config = Map.put config, :setup, :'#{Enum.at System.argv, 1}'

  # add no. of servers and clients
  config = Map.put config, :n_servers, String.to_integer(Enum.at System.argv, 2)
  config = Map.put config, :n_clients, String.to_integer(Enum.at System.argv, 3)

  config
end

# ---------------------

def compare_ballots(b1, b2) do
  cond do
    b1 == b2 -> 0
    b1 == -1 -> -1
    b2 == -1 -> 1
    true ->
      {n1, l1} = b1
      {n2, l2} = b2
      if (n1 == n2) do
        if l1 > l2, do: 1, else: -1
      else
        if n1 > n2, do: 1, else: -1
      end
  end
end

end # module -----------------------
