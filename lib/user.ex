defmodule Client do
  use GenServer, restart: :temporary, timeout: 10000
  import Services

  def start_link([id, numTweets, myTweets, iSubscribed]) do
    IO.puts "Started User #{inspect(id)}"
    GenServer.start_link(__MODULE__, [id, numTweets, myTweets, iSubscribed], name: {:global, id})
  end

  def init([id, numTweets, myTweets, iSubscribed]) do
    Process.sleep(20)
    register(id)
    login(id)
    #tweet = Task.start(fn -> tweeting(id, numTweets) end)
    {:ok, [id, numTweets, myTweets, iSubscribed]}
  end

  def handle_cast(:startTweeting, [id, numTweets, myTweets, iSubscribed]) do
    tweet = Task.start(fn -> tweeting(id, numTweets) end)
    {:noreply, [id, numTweets, myTweets, iSubscribed]}
  end

  def handle_info(:register, [id, numTweets, myTweets, iSubscribed]) do
     register(id)
     Process.sleep(5)
     {:noreply, [id, numTweets, myTweets, iSubscribed]}
  end

  def handle_info(:timeout, [id, numTweets, myTweets, iSubscribed]) do
     logout(id)
     Process.sleep(10)
     Process.exit(self(), :normal)
     {:noreply, [id, numTweets, myTweets, iSubscribed]}
  end

  def handle_info({:livetweet, user_id, text}, [id, numTweets, myTweets, iSubscribed]) do
    IO.puts "Received live tweet from the user #{user_id}, the tweet said #{inspect(text)}"
    updateTweets = myTweets ++ [{user_id, text}]
  {:noreply, [id, numTweets, myTweets, iSubscribed]}
  end

  def handle_cast(:selectYourFavorites, [id, numTweets, myTweets, iSubscribed]) do
    agent = :global.whereis_name(:activeUsers)
     aliveUsers =  ActiveUsers.getUsers(agent)
     numFavs = :rand.uniform(length(aliveUsers))
     myFavs = Enum.shuffle(aliveUsers) |> Enum.slice(1..numFavs) |> Enum.reject(fn x-> x==id end)
     twitter = :global.whereis_name(:twitter)
     for fav <-myFavs, do: send(twitter, {:subscribe, id, fav})
    {:noreply, [id, numTweets, myTweets, myFavs]}
  end


  def handle_cast(:queryAllYourTweets, [id, numTweets, myTweets, iSubscribed]) do
     twitter = :global.whereis_name(:twitter)
     mytweets = GenServer.call(twitter, {:sendAllMyTweets, id, iSubscribed})
     if mytweets != [], do: IO.puts "I queried and received all my tweets"
     {:noreply, [id, numTweets, myTweets, iSubscribed]}
  end


  def tweeting(id, numTweets) when numTweets != 0 do
      msg = "I will be posting #{numTweets-1} more tweets"
      tweet(id, msg)
      Process.sleep(10)
      tweeting(id, numTweets-1)
   end

 def tweeting(id, numTweets) when numTweets == 0 do
    Process.sleep(100)
    :done
 end

end
