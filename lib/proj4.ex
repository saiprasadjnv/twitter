defmodule Project4 do

  def start_project(numUsers, numTweets) do
    {:ok, agent} = ActiveUsers.start_link([])
    {:ok, twitter} = Twitter.start_link([])
    {:ok, supervisor} = TwitterSupervisor.start_link([numUsers, numTweets])
    Process.sleep(10)
    users = Supervisor.which_children(supervisor)|> Enum.map(fn {_,c,_,_}-> c end)
    for pid <- users, do: spawn(fn -> GenServer.cast(pid, :selectYourFavorites) end) |> Process.monitor()
    Process.sleep(100)
    for pid <- users, do: spawn(fn -> GenServer.cast(pid, :startTweeting) end) |> Process.monitor()
    Process.sleep(999)
    for pid <- users, do: spawn(fn -> GenServer.cast(pid, :doSomeMentions) end) |> Process.monitor()
    Process.sleep(999)
    for pid <- users, do: spawn(fn -> GenServer.cast(pid, :hashTagTweets) end) |> Process.monitor()
    Process.sleep(999)
    for pid <- users, do: spawn(fn -> GenServer.cast(pid, :queryAllYourTweets) end) |> Process.monitor()
    Process.sleep(3000)
    for pid <- users, do: spawn(fn -> GenServer.cast(pid, :getMentions) end) |> Process.monitor()
    Process.sleep(3000)
    for pid <- users, do: spawn(fn -> GenServer.cast(pid, :getSomehashes) end) |> Process.monitor()
    Process.sleep(3000)
    for pid <- users, do: spawn(fn -> GenServer.cast(pid, :deleteAccount) end) |> Process.monitor()
    waitUntilFinish(agent)
  end

  def testQueryTweets(agent) do
    randomUser = ActiveUsers.getRandomUserID(agent)
    userPID = :global.whereis_name(randomUser)
    response = GenServer.call(userPID, :queryAllTweets)
  end

  def waitUntilFinish(agent) do
    Process.sleep(20)
    activeUsers = ActiveUsers.numUsersAlive(agent)
    if activeUsers != 0, do: waitUntilFinish(agent)
  end

end
