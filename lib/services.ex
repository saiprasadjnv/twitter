defmodule Services do
   def register(id) do
     twitter = :global.whereis_name(:twitter)
     send(twitter, {:register, id, %{:name => "Tom#{id}", :age => 23, :city => Gainesville}})
   end

   def login(id) do
     agent = :global.whereis_name(:activeUsers)
     ActiveUsers.addUser(agent, id)
   end

   def subscribe(fav_id, user_id) do

   end

   def tweet(id, text) do
     twitter = :global.whereis_name(:twitter)
     hashes = checkForHashtags(text)
     mentions = checkForMentions(text)
     send(twitter, {:tweet, id, text})
     send(twitter, {:deliver_tweet, id, text, mentions})
     if hashes != 0, do: for hash<- hashes, do:  send(twitter, {:hashTag, hash, id, text})
     if mentions !=0, do: for mention <- mentions, do: send(twitter, {:mention, mention, id, text})
    #  send(:twitter)
   end

   def getTweets(mode, key) when mode == :subscribed do

   end

   def getTweets(mode, key) when mode == :hash_tag do

   end

   def getTweets(mode, key) when mode == :mentioned_me do

   end

   def reTweet(tweetID) do

   end

   def logout(id) do
     agent = :global.whereis_name(:activeUsers)
     ActiveUsers.deleteUser(agent, id)
   end

   defp checkForHashtags(text) do
      words = String.split(text, [" ", "&", "/"])
      #IO.inspect words
      hashes = Enum.filter(words, fn x -> String.at(x,0)=="#" end)
      #IO.puts "HashTags identified #{inspect(hashes)}"
      a = if length(hashes) == 0 do
              0
            else
            #  IO.puts "Hashes identified #{inspect(hashes)}"
              hashes
          end
      a
   end

   defp checkForMentions(text) do
      words = String.split(text, [" ", "&", "/"])
      #IO.inspect words
      mentions = Enum.filter(words, fn x -> String.at(x,0)=="@" end)
      mentions = Enum.map(mentions, fn x -> String.slice(x,1..-1) |> String.to_integer() end)
      #mentions = Enum.map(mentions, fn x -> String.to_integer(x) end)
      #IO.puts "Mentions identified #{inspect(mentions)}"
      a = if length(mentions) == 0 do
              0
            else
              #IO.puts  "mentions identified #{inspect(mentions)}"
              mentions
          end
      a
   end


end
