defmodule Twitter do
   use GenServer, restart: :temporary, timeout: 180000

   def start_link(state) do
      IO.puts "Started Twitter"
      GenServer.start_link(__MODULE__, state, name: {:global, :twitter})
   end

   def init([]) do
    ###add ets tables for subscriptions, Tweets, Hash Tags, Mentions
    users = :ets.new(:users, [:set, :private, :named_table])
    subscribers = :ets.new(:subscribers, [:set, :public, :named_table])
    tweets = :ets.new(:tweets, [:set, :public, :named_table])
    hashTags = :ets.new(:hashTags, [:set, :public, :named_table])
    mentions = :ets.new(:mentions, [:set, :public, :named_table])
    {:ok, []}
   end

   def handle_info({:register, user_id, user_info}, state) do
      IO.puts "Registered user #{user_id}, #{inspect(user_info)}"
      :ets.insert(:users, {user_id, user_info})
      :ets.insert(:tweets, {user_id, []})
      :ets.insert(:mentions, {user_id, []})
      {:noreply, state}
   end

   #def handle_call({:get_tweets, user_ids}) do

    #{:reply, tweets, [], :infinity}
   #end

   def handle_info({:deliver_tweet, user_id, text, mentions}, []) do
     if mentions != 0 do
        for i <- mentions do
          pid = :global.whereis_name(i)
          send(pid, {:livetweet, user_id, text})
        end
     end
     mysubscibers = :ets.lookup_element(:subscribers, user_id, 2)
     agent = :global.whereis_name(:activeUsers)
     for i <- mysubscribers do
         if ActiveUsers.isAlive(agent, i), do: send(i, {:livetweet, user_id, text})
     end
     {:noreply, []}
   end

   def handle_info({:tweet, user_id, text}, []) do
    tweetID = user_id * 1000 + (for i<- 1..999, do: i) |> Enum.random()
    addTweet = :ets.lookup_element(:tweets, user_id, 2) ++ [{tweetID, text}]
    :ets.update(:tweets, user_id, {2, addTweet})
   {:noreply, []}
   end

   def handle_info({:hashTag, hash, user_id, text}, []) do
      if :ets.member(:hashTag, hash) do
         addTweet = :ets.lookup_element(:hashTag, hash, 2) ++ [{user_id, text}]
         :ets.update_element(:hashTag, hash, {2, addTweet})
         else
           :ets.insert(:hashTag, {hash, [{user_id, text}]})
      end
   {:noreply, []}
   end

   def handle_info({:mention, mention, user_id, text}, []) do
     addTweet = :ets.lookup_element(:mentions, mention, 2) ++ [{user_id, text}]
     :ets.update_element(:mentions, mention, {2, addTweet})
   {:noreply, []}
   end

   def handle_info({:subscribe, user_id, subscribed_id}) do
       addNewSubscriber = :ets.lookup_element(:subscribers, subscribed_id, 2) ++ [user_id]
       :ets.update_element(:subscribers, subscribed_id, {2, addNewSubscriber})
    {:noreply, []}
   end

   def handle_info({:delete_account, user_id}) do
       :ets.delete(:users, user_id)
    {:noreply, []}
   end

end
