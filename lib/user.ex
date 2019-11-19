defmodule Client do
  use GenServer, restart: :temporary, timeout: 100000
  import Commons

  def start_link([]) do
    GenServer.start_link(__MODULE__, [id, numObjects, agent,neighbs, objects], name: {:global, id})
  end

  def init([id, numObjects, agent,neighbs, objects]) do
    NodesRecord.addNode(agent, id)
    {:ok, [id, numObjects, agent,neighbs, objects]}
  end

end
