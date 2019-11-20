defmodule TwitterSupervisor do
  use Supervisor
  def start_link(state) do
     Supervisor.start_link(__MODULE__, state, name: {:global, :supervisor})
  end

  @impl true
  def init([numUsers, numTweets]) do
    #twitter = worker(Twitter, [[]], [restart: :temporary, timeout: 180000, id: :twitter])
    Process.sleep(10)
    children = for x <- 1..numUsers, do: worker(Client, [[1000+x, numTweets, [], []]], [restart: :temporary, timeout: 180000, id: 10000*x + x])
    #Supervisor.init(children ++ [twitter], strategy: :one_for_one, restart: :temporary)
    Supervisor.init(children, strategy: :one_for_one, restart: :temporary)
  end
 end
