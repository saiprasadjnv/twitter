## This agent maintains the list of active users

defmodule ActiveUsers do
  use Agent
  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: {:global, :activeUsers})
  end

  def isAlive(pid, user_id) do
    Agent.get(pid, fn state -> user_id in state end, :infinity)
  end

  def addUser(pid, user_id) do
    Agent.update(pid, fn state -> state ++ [user_id] end, :infinity)
  end

  def deleteUser(pid,user_id) do
    Agent.update(pid, fn state -> state -- [user_id] end, :infinity)
  end

  def getUsers(pid) do
    Agent.get(pid, fn state -> state end, :infinity)
  end

  def numUsersAlive(pid) do
    Agent.get(pid, fn state -> length(state) end, :infinity)
  end

  def getRandomUserID(pid) do
    Agent.get(pid, fn state -> Enum.random(state) end, :infinity)
  end

  def getArandomUser(pid, id) do
    Agent.get(pid, fn state -> Enum.random(state -- [id]) end, :infinity)
  end
end
