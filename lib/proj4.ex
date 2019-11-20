defmodule Project4 do

  def start_project(numUsers, numTweets) do
    {:ok, agent} = ActiveUsers.start_link([])
    {:ok, twitter} = Twitter.start_link([])
    {:ok, _supervisor} = TwitterSupervisor.start_link([numUsers, numTweets])
    Process.sleep(100)
    #testQueryTweets(agent)
    Process.sleep(50)
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
