### This program simulates the end user

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
    tweets = Task.start(fn -> tweeting(id, numTweets) end)
    {:noreply, [id, numTweets, myTweets, iSubscribed]}
  end

  def handle_cast(:getMentions,[id, numTweets, myTweets, iSubscribed]) do
     twitter = :global.whereis_name(:twitter)
     tweets = GenServer.call(twitter, {:sendMentionedTweets,id})
     len = length(tweets)
     IO.puts "I (#{id}) am mentioned in #{len} tweets :)"
     {:noreply, [id, numTweets, myTweets ++ tweets, iSubscribed]}
  end

  def handle_cast(:getSomehashes, [id, numTweets, myTweets, iSubscribed]) do
     twitter = :global.whereis_name(:twitter)
      ilikeHashes = []
      ilikeHashes = ilikeHashes ++ (if rem(id, 2) !=0 , do: ["#Imeven"], else: ["#ImOdd"])
      ilikeHashes = ilikeHashes ++ (if rem(id,10) == 0 , do: ["#IendWithZero"], else: [])
      ilikeHashes = ilikeHashes ++ (if :math.sqrt(id) - (:math.sqrt(id) |> floor) == 0.0 , do: ["#ImPerfect"], else: [])
      tweets = for hash <- ilikeHashes, do: GenServer.call(twitter, {:sendHashedTweets, hash, id})
      len = List.flatten(tweets) |> length()
      IO.puts "I (#{id}) like #{len} tweets that have hashTags :)"
     {:noreply, [id, numTweets, myTweets ++ tweets, iSubscribed]}
  end

  def handle_cast(:deleteAccount, [id, numTweets, myTweets, iSubscribed]) do
    twitter = :global.whereis_name(:twitter)
    send(twitter, {:delete_account, id})
    logout(id)
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
  {:noreply, [id, numTweets, updateTweets, iSubscribed]}
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

  def handle_cast(:doSomeMentions, [id, numTweets, myTweets, iSubscribed]) do
     mentions_task = Task.start(fn -> doSomeMentions(id, 10) end)
     {:noreply, [id, numTweets, myTweets, iSubscribed]}
  end

  def handle_cast(:retweet, [id, numTweets, myTweets, iSubscribed]) do
     retweets = Enum.shuffle(myTweets) |> Enum.slice(1..10)
     IO.inspect retweets
     msgs = Enum.map(retweets, fn x -> "Retweeting the tweet from "<> (elem(x,0) |> Integer.to_string()) <> " : " <> elem(x,1)  end)
     IO.inspect Enum.at(msgs, 0)
     for msg <- msgs, do: tweet(id, msg)
     {:noreply, [id, numTweets, myTweets, iSubscribed]}
  end

  def handle_cast(:hashTagTweets, [id, numTweets, myTweets, iSubscribed]) do
     if rem(id,2) == 0 do
        msg = "#Imeven I am even cuz my id is #{id}"
        tweet(id, msg)
      else
        msg = "#ImOdd I am odd cuz my id is #{id}"
        tweet(id,msg)
      end
    if rem(id,10) == 0 do
      msg = "#IendWithZero My id ends with zero :) #{id}"
      tweet(id, msg)
    end
    if :math.sqrt(id) - (:math.sqrt(id) |> floor) == 0.0 do
      msg = "#ImPerfect I am perfect cuz my ID is a perfect square #{id}"
      tweet(id, msg)
    end
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

 def doSomeMentions(id, num) when num == 0 do
    :done
 end

 def doSomeMentions(id, num) when num !=0 do
  agent = :global.whereis_name(:activeUsers)
  randomuser = ActiveUsers.getArandomUser(agent, id)
  msg = "@#{randomuser} :  I mentioned you in my tweet Tom#{randomuser}"
  tweet(id, msg)
  Process.sleep(5)
  doSomeMentions(id, num-1)
 end

end
