defmodule Twitter do
   use GenServer, restart: :permanent, timeout: :infinity

   def start_link(state) do
      GenServer.start_link(__MODULE__, state)
   end

   def init([]) do

    {:ok, []}
   end


   def handle_call({:get_tweets, user_ids}) do

    {:reply, tweets, [], :infinity}
   end

   def handle_info({:deliver_tweet, from_user_id}, []) do

   {:noreply, []}
   end

   def handle_info({:add_tweet, from_user_id}, []) do

   {:noreply, []}
   end

   def handle_call({:subscribe, user_id, subscriber_id}) do

    {:reply, :subscribed, []}
   end

   def handle_info({:delete_account, user_id}) do

    {:noreply, []}
   end

end
