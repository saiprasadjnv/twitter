defmodule Client do
  use GenServer, restart: :temporary, timeout: 1000
  import Services

  def start_link([id, numTweets, myTweets, iSubscribed]) do
    IO.puts "Started User #{inspect(id)}"
    GenServer.start_link(__MODULE__, [id, numTweets, myTweets, iSubscribed], name: {:global, id})
  end

  def init([id, numTweets, myTweets, iSubscribed]) do
    Process.sleep(20)
    register(id)
    login(id)
    tweet = Task.start(fn -> tweeting(id, numTweets) end)
    {:ok, [id, numTweets, myTweets, iSubscribed]}
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
    updateTweets = myTweets ++ [{user_id, text}]
  {:noreply, [id, numTweets, myTweets, iSubscribed]}
  end

  def tweeting(id, numTweets) when numTweets != 0 do
      msg = "I will be posting #{numTweets} tweets more"
      tweet(id, msg)
      Process.sleep(10)
      tweeting(id, numTweets-1)
   end

end
